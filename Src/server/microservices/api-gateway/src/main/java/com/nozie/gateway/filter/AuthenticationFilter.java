package com.nozie.gateway.filter;

import com.nozie.gateway.config.RouteValidator;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;

@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(AuthenticationFilter.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    private final ReactiveRedisTemplate<String, String> redisTemplate;

    @Autowired
    public AuthenticationFilter(ReactiveRedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        String method = request.getMethod().name();

        // Generate correlation ID for tracing
        String correlationId = UUID.randomUUID().toString();

        log.info("[{}] Processing request: {} {}", correlationId, method, path);

        // Skip authentication for open endpoints
        if (!RouteValidator.isSecured(path)) {
            log.debug("[{}] Open endpoint, skipping authentication: {}", correlationId, path);
            return chain.filter(addCorrelationId(exchange, correlationId));
        }

        // Check for Authorization header
        if (!request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
            log.warn("[{}] Missing Authorization header for secured endpoint: {}", correlationId, path);
            return onError(exchange, "Missing Authorization header", HttpStatus.UNAUTHORIZED);
        }

        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("[{}] Invalid Authorization header format", correlationId);
            return onError(exchange, "Invalid Authorization header format", HttpStatus.UNAUTHORIZED);
        }

        String token = authHeader.substring(7);

        try {
            Claims claims = validateToken(token);

            String jti = claims.getId();
            String userId = claims.getSubject();
            String username = claims.get("username", String.class);
            @SuppressWarnings("unchecked")
            List<String> roles = claims.get("roles", List.class);
            @SuppressWarnings("unchecked")
            List<String> permissions = claims.get("permissions", List.class);

            String rolesStr = roles != null ? String.join(",", roles) : "";
            String permissionsStr = permissions != null ? String.join(",", permissions) : "";

            final String finalCorrelationId = correlationId;

            // Check blacklist (Redis) - reactive
            if (jti != null) {
                return redisTemplate.hasKey("token:blacklist:" + jti)
                        .flatMap(isBlacklisted -> {
                            if (Boolean.TRUE.equals(isBlacklisted)) {
                                log.warn("[{}] Token is blacklisted: {}", finalCorrelationId, jti);
                                return onError(exchange, "Token has been revoked", HttpStatus.UNAUTHORIZED);
                            }
                            return continueWithRequest(exchange, chain, request, userId, username, rolesStr,
                                    permissionsStr, finalCorrelationId);
                        })
                        .onErrorResume(e -> {
                            log.warn("Redis check failed, allowing request: {}", e.getMessage());
                            return continueWithRequest(exchange, chain, request, userId, username, rolesStr,
                                    permissionsStr, finalCorrelationId);
                        });
            }

            return continueWithRequest(exchange, chain, request, userId, username, rolesStr, permissionsStr,
                    correlationId);

        } catch (ExpiredJwtException e) {
            log.warn("[{}] Token expired: {}", correlationId, e.getMessage());
            return onError(exchange, "Token has expired", HttpStatus.UNAUTHORIZED);
        } catch (JwtException | IllegalArgumentException e) {
            log.error("[{}] Token validation failed: {}", correlationId, e.getMessage());
            return onError(exchange, "Invalid token", HttpStatus.UNAUTHORIZED);
        }
    }

    private Mono<Void> continueWithRequest(ServerWebExchange exchange, GatewayFilterChain chain,
            ServerHttpRequest request, String userId, String username,
            String rolesStr, String permissionsStr, String correlationId) {
        log.info("[{}] Token validated. User: {}, Roles: {}", correlationId, username, rolesStr);

        ServerHttpRequest modifiedRequest = request.mutate()
                .header("X-User-Id", userId)
                .header("X-User-Name", username != null ? username : "")
                .header("X-User-Roles", rolesStr)
                .header("X-User-Permissions", permissionsStr)
                .header("X-Correlation-Id", correlationId)
                .build();

        return chain.filter(exchange.mutate().request(modifiedRequest).build());
    }

    private Claims validateToken(String token) {
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private ServerWebExchange addCorrelationId(ServerWebExchange exchange, String correlationId) {
        ServerHttpRequest request = exchange.getRequest().mutate()
                .header("X-Correlation-Id", correlationId)
                .build();
        return exchange.mutate().request(request).build();
    }

    private Mono<Void> onError(ServerWebExchange exchange, String message, HttpStatus status) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(status);
        response.getHeaders().add("Content-Type", "application/json");

        String body = String.format("{\"success\":false,\"message\":\"%s\"}", message);

        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }

    @Override
    public int getOrder() {
        return -100;
    }
}
