package com.nozie.paymentservice.infrastructure.client;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.infrastructure.client.dto.MovieDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Feign Client for Movie Service.
 */
@FeignClient(name = "movie-service")
public interface MovieClient {

    @GetMapping("/api/movies/{id}")
    ApiResponse<MovieDTO> getMovieById(@PathVariable("id") Long id);
}
