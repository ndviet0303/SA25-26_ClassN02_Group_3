package com.nozie.gateway.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.time.Duration;

@Component
public class RateLimitFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(RateLimitFilter.class);

    // Rate limit configuration
    private static final int DEFAULT_REQUESTS_PER_MINUTE = 100;
    private static final int LOGIN_REQUESTS_PER_MINUTE = 5;
    private static final int USER_REQUESTS_PER_MINUTE = 200;

    private final ReactiveRedisTemplate<String, String> redisTemplate;

    @Autowired
    public RateLimitFilter(ReactiveRedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        String clientIp = getClientIP(request);
        String userId = request.getHeaders().getFirst("X-User-Id");

        // Special rate limit for login endpoint
        if (path.equals("/api/auth/login")) {
            return checkRateLimit("login:" + clientIp, LOGIN_REQUESTS_PER_MINUTE)
                    .flatMap(allowed -> {
                        if (!allowed) {
                            log.warn("Rate limit exceeded for login from IP: {}", clientIp);
                            return onError(exchange, "Too many login attempts. Please try again later.");
                        }
                        return chain.filter(exchange);
                    })
                    .onErrorResume(e -> {
                        log.error("Rate limit check failed: {}", e.getMessage());
                        return chain.filter(exchange);
                    });
        }

        // User-based rate limit (if authenticated)
        String rateLimitKey = (userId != null && !userId.isEmpty()) ? "user:" + userId : "ip:" + clientIp;
        int maxRequests = (userId != null && !userId.isEmpty()) ? USER_REQUESTS_PER_MINUTE
                : DEFAULT_REQUESTS_PER_MINUTE;

        return checkRateLimit(rateLimitKey, maxRequests)
                .flatMap(allowed -> {
                    if (!allowed) {
                        log.warn("Rate limit exceeded for: {}", rateLimitKey);
                        return onError(exchange, "Rate limit exceeded. Please slow down.");
                    }
                    return chain.filter(exchange);
                })
                .onErrorResume(e -> {
                    log.error("Rate limit check failed: {}", e.getMessage());
                    return chain.filter(exchange);
                });
    }

    private Mono<Boolean> checkRateLimit(String key, int maxRequests) {
        String redisKey = "ratelimit:" + key;

        return redisTemplate.opsForValue().increment(redisKey)
                .flatMap(currentCount -> {
                    if (currentCount != null && currentCount == 1) {
                        return redisTemplate.expire(redisKey, Duration.ofMinutes(1))
                                .map(success -> currentCount <= maxRequests);
                    }
                    return Mono.just(currentCount == null || currentCount <= maxRequests);
                });
    }

    private String getClientIP(ServerHttpRequest request) {
        String xForwardedFor = request.getHeaders().getFirst("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIP = request.getHeaders().getFirst("X-Real-IP");
        if (xRealIP != null && !xRealIP.isEmpty()) {
            return xRealIP;
        }
        return request.getRemoteAddress() != null ? request.getRemoteAddress().getAddress().getHostAddress()
                : "unknown";
    }

    private Mono<Void> onError(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
        response.getHeaders().add("Content-Type", "application/json");
        response.getHeaders().add("Retry-After", "60");

        String body = String.format("{\"success\":false,\"message\":\"%s\"}", message);

        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }

    @Override
    public int getOrder() {
        return -110;
    }
}
