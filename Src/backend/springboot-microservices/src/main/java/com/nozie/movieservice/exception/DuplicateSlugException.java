package com.nozie.movieservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Custom exception for duplicate slug scenarios.
 * Thrown by Service layer (Layer 2) when trying to create/update with existing slug.
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class DuplicateSlugException extends RuntimeException {

    public DuplicateSlugException(String slug) {
        super("Movie with slug '" + slug + "' already exists");
    }
}

