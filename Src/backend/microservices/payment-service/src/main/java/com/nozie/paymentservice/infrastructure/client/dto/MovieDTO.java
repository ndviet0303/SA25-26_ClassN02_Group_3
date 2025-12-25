package com.nozie.paymentservice.infrastructure.client.dto;

import java.math.BigDecimal;

/**
 * Minimal Movie DTO for inter-service communication.
 */
public class MovieDTO {
    private String id;
    private String title;
    private BigDecimal price;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }
}
