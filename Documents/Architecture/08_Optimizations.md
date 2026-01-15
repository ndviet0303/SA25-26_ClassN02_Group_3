
# ⚡ System Optimizations & Architectural Patterns

## 1. High-Performance Caching (Cache-aside Pattern)
To minimize database latency and handle high traffic:
- **Service**: `Movie Service` & `Identity Service`.
- **Logic**: 
    - Popular movies and categories are cached in **Redis** with a TTL (Time-To-Live).
    - User authorities (Roles/Permissions) are cached at the **API Gateway** level or within `Identity Service` to avoid redundant JWT decoding/DB hits.
- **Eviction Strategy**: Cache is invalidated or updated upon content updates (Write-through or TTL expiration).

## 2. Event-Driven Architecture (EDA)
Decoupling services for better scalability and reliability:
- **Broker**: **RabbitMQ**.
- **Key Flows**:
    - **Payment Succeeded**: `Payment Service` emits `order.paid` event -> `Customer Service` updates VIP status -> `Notification Service` sends email/push.
    - **User Registered**: `Identity Service` emits `user.created` event -> `Notification Service` sends welcome email -> `Customer Service` initializes default subscription.
- **Benefit**: Improved system resilience. If the email service is down, the event remains in the queue for later processing.

## 3. Resilience & Fault Tolerance
Protecting the system from cascading failures:
- **Circuit Breaker (Resilience4j)**: Implemented on the **API Gateway** and **Service-to-Service** (Feign) calls.
- **Rate Limiting**: Redis-based rate limiting to prevent API abuse and DoS attacks.
- **Fallback Logic**: If a non-critical service (like Recommendations) fails, the system returns a default "Trending" list instead of an error.

## 4. Database Scaling & Performance
- **Mongo Optimization**: Compound indexes for `(title, release_date, genre)` in the Movie collection.
- **SQL Optimization**: Using **Database Indexing** on frequently queried columns (`user_id`, `email`, `transaction_id`) and optimizing JPA queries to prevent N+1 issues.

## 5. Observability & Monitoring
- **Distributed Tracing**: Integration with **Micrometer Tracing** and **Zipkin**. Each request carries a `Correlation-ID` to track its journey across services.
- **Centralized Logging**: Structured logging (JSON format) and correlation IDs for efficient debugging across the distributed system.
