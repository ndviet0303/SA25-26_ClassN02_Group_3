
# 🛡️ System Resilience & Fault Tolerance

## 1. Bulkhead & Isolation
Services are isolated by process and resource. Failure in the `Recommendation Service` does not block users from watching movies they have already purchased.

## 2. Circuit Breaker (Resilience4j)
- **Monitoring**: Observes the success/failure rate of remote calls (Feign).
- **State Switch**: If failure exceeds 50%, the circuit opens, immediately failing subsequent requests to allow the downstream service to recover.
- **Example**: `Payment Service` calling `Customer Service`. If `Customer Service` is slow, the circuit opens to prevent the `Payment Service` from exhausting its thread pool.

## 3. Graceful Fallbacks
- When a service is unavailable, users receive a degraded but functional experience.
- **Movie Catalog**: If the search engine is down, fallback to a "Default Popular Movie" static list from the database.

## 4. Rate Limiting
- **Gateway Level**: Prevents brute-force on `/login` and DDoS on `/streaming`.
- **Logic**: Bucket-token algorithm implemented via Redis.

## 5. Observability
- **Logs**: Centralized via Docker logging or ELK stack readiness.
- **Trace**: Correlation IDs across all HTTP headers and AMQP properties.
