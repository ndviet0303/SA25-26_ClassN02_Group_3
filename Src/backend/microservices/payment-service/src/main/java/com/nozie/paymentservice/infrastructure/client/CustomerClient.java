package com.nozie.paymentservice.infrastructure.client;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.infrastructure.client.dto.CustomerDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Feign Client for Customer Service.
 */
@FeignClient(name = "customer-service")
public interface CustomerClient {

    @GetMapping("/api/customers/{id}")
    ApiResponse<CustomerDTO> getCustomerById(@PathVariable("id") Long id);
}
