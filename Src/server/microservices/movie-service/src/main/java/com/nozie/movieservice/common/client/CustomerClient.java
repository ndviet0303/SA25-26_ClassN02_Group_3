package com.nozie.movieservice.common.client;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.common.dto.WatchlistItemDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "customer-service", path = "/api/customers")
public interface CustomerClient {

    @GetMapping("/user/{userId}/watchlist")
    ApiResponse<List<WatchlistItemDto>> getWatchlistByUserId(@PathVariable("userId") Long userId);
}
