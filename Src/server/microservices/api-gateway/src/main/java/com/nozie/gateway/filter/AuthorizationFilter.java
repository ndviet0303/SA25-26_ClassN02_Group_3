package com.nozie.gateway.filter;

import com.nozie.gateway.config.RouteValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.*;

@Component
public class AuthorizationFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(AuthorizationFilter.class);

    // Route-based authorization rules
    private static final Map<String, Set<String>> ROUTE_ROLE_REQUIREMENTS = new HashMap<>();

    static {
        // Admin routes require ADMIN role
        ROUTE_ROLE_REQUIREMENTS.put("/api/admin/**", Set.of("ADMIN"));

        // Movie write operations require ADMIN or MODERATOR
        ROUTE_ROLE_REQUIREMENTS.put("POST:/api/movies", Set.of("ADMIN", "MODERATOR"));
        ROUTE_ROLE_REQUIREMENTS.put("PUT:/api/movies/**", Set.of("ADMIN", "MODERATOR"));
        ROUTE_ROLE_REQUIREMENTS.put("DELETE:/api/movies/**", Set.of("ADMIN"));

        // Payment admin operations
        ROUTE_ROLE_REQUIREMENTS.put("DELETE:/api/payments/**", Set.of("ADMIN"));
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        String method = request.getMethod().name();
        String correlationId = request.getHeaders().getFirst("X-Correlation-Id");

        // Skip authorization for open endpoints
        if (!RouteValidator.isSecured(path)) {
            return chain.filter(exchange);
        }

        // Get user roles from header (set by AuthenticationFilter)
        String rolesHeader = request.getHeaders().getFirst("X-User-Roles");
        Set<String> userRoles = new HashSet<>();
        if (rolesHeader != null && !rolesHeader.isEmpty()) {
            userRoles.addAll(Arrays.asList(rolesHeader.split(",")));
        }

        // Check route authorization
        String routeKey = findMatchingRoute(method, path);
        if (routeKey != null) {
            Set<String> requiredRoles = ROUTE_ROLE_REQUIREMENTS.get(routeKey);
            if (requiredRoles != null && !hasAnyRole(userRoles, requiredRoles)) {
                log.warn("[{}] Access denied. User roles: {}, Required: {}",
                        correlationId, userRoles, requiredRoles);
                return onError(exchange, "Access denied. Insufficient permissions.");
            }
        }

        log.debug("[{}] Authorization passed for {} {}", correlationId, method, path);
        return chain.filter(exchange);
    }

    private String findMatchingRoute(String method, String path) {
        // Check method-specific routes first
        String methodPath = method + ":" + path;
        for (String routeKey : ROUTE_ROLE_REQUIREMENTS.keySet()) {
            if (routeKey.contains(":")) {
                String[] parts = routeKey.split(":");
                String routeMethod = parts[0];
                String routePath = parts[1];

                if (routeMethod.equals(method) && matchesPath(path, routePath)) {
                    return routeKey;
                }
            }
        }

        // Check path-only routes
        for (String routeKey : ROUTE_ROLE_REQUIREMENTS.keySet()) {
            if (!routeKey.contains(":") && matchesPath(path, routeKey)) {
                return routeKey;
            }
        }

        return null;
    }

    private boolean matchesPath(String path, String pattern) {
        if (pattern.endsWith("/**")) {
            String prefix = pattern.substring(0, pattern.length() - 3);
            return path.startsWith(prefix);
        }
        return path.equals(pattern);
    }

    private boolean hasAnyRole(Set<String> userRoles, Set<String> requiredRoles) {
        for (String required : requiredRoles) {
            if (userRoles.contains(required)) {
                return true;
            }
        }
        return false;
    }

    private Mono<Void> onError(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.FORBIDDEN);
        response.getHeaders().add("Content-Type", "application/json");

        String body = String.format("{\"success\":false,\"message\":\"%s\"}", message);

        return response.writeWith(Mono.just(response.bufferFactory().wrap(body.getBytes())));
    }

    @Override
    public int getOrder() {
        return -90; // Run after AuthenticationFilter (-100) but before other filters
    }
}
