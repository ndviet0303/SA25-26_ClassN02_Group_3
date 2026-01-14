package com.nozie.gateway.config;

import java.util.List;

public class RouteValidator {

    public static final List<String> openApiEndpoints = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/api/auth/validate",
            "/actuator",
            "/fallback");

    public static boolean isSecured(String path) {
        return openApiEndpoints.stream()
                .noneMatch(uri -> path.startsWith(uri));
    }
}
