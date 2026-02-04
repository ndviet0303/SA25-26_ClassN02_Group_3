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
            "/api/auth/forgot-password",
            "/api/auth/reset-password",
            "/api/auth/check-username",
            "/api/auth/check-email",
            "/api/auth/verify-email",
            "/api/auth/resend-verification",
            "/api/subscriptions/webhook",
            "/api/subscriptions/plans",
            "/api/payments/webhook",
            "/api/movies",
            "/api/genres",
            "/api/countries",
            "/api/years",
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
