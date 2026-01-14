package com.nozie.gateway.config;

import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class RouteValidator {

    private static final List<String> openApiEndpoints = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/api/auth/refresh",
            "/api/auth/validate",
            "/actuator",
            "/fallback",
            "/health");

    public static boolean isSecured(String path) {
        if (path == null) {
            return true;
        }

        for (String endpoint : openApiEndpoints) {
            if (path.equals(endpoint) || path.startsWith(endpoint + "/")) {
                return false;
            }
        }

        // Also check for actuator paths
        if (path.startsWith("/actuator")) {
            return false;
        }

        return true;
    }

    public static boolean isAdminRoute(String path) {
        return path != null && path.startsWith("/api/admin");
    }
}
