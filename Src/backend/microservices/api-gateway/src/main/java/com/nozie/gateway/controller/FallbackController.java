package com.nozie.gateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Fallback Controller for Circuit Breaker.
 * Provides fallback responses when services are unavailable.
 */
@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/movies")
    public ResponseEntity<Map<String, Object>> movieServiceFallback() {
        return buildFallbackResponse("Movie Service is currently unavailable. Please try again later.");
    }

    @GetMapping("/customers")
    public ResponseEntity<Map<String, Object>> customerServiceFallback() {
        return buildFallbackResponse("Customer Service is currently unavailable. Please try again later.");
    }

    @GetMapping("/payments")
    public ResponseEntity<Map<String, Object>> paymentServiceFallback() {
        return buildFallbackResponse("Payment Service is currently unavailable. Please try again later.");
    }

    @GetMapping("/notifications")
    public ResponseEntity<Map<String, Object>> notificationServiceFallback() {
        return buildFallbackResponse("Notification Service is currently unavailable. Please try again later.");
    }

    private ResponseEntity<Map<String, Object>> buildFallbackResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        response.put("status", HttpStatus.SERVICE_UNAVAILABLE.value());
        return new ResponseEntity<>(response, HttpStatus.SERVICE_UNAVAILABLE);
    }
}

