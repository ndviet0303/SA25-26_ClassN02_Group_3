package com.nozie.movieservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Custom exception for Movie not found scenarios.
 * Thrown by Service layer (Layer 2) when movie is not found.
 */
@ResponseStatus(HttpStatus.NOT_FOUND)
public class MovieNotFoundException extends RuntimeException {

    public MovieNotFoundException(Long id) {
        super("Movie not found with id: " + id);
    }

    public MovieNotFoundException(String slug) {
        super("Movie not found with slug: " + slug);
    }

    public MovieNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}

