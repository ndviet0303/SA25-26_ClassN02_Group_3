# Lab Report 04: Communication between Microservices

**Group:** 03  
**Class:** N02  
**Application Name:** Nozie - Movie Streaming Platform  

---

## 1. Introduction
The objective of Lab 04 is to implement and manage communication between microservices within the Nozie platform. This includes setting up an API Gateway for request routing, service discovery using Eureka, and implementing both synchronous (OpenFeign) and asynchronous (RabbitMQ) communication patterns to ensure system scalability and resilience.

## 2. System Architecture
The current architecture consists of the following components:
- **Config Server (Port 8888):** Centralized configuration management.
- **Discovery Server (Port 8761):** Eureka server for service registration and discovery.
- **API Gateway (Port 8080):** Entry point for all client requests, providing routing and load balancing.
- **Movie Service (Port 8081):** Manages movie metadata (MongoDB).
- **Customer Service (Port 8082):** Manages user profiles (PostgreSQL).
- **Payment Service (Port 8083):** Handles transactions and coordinates with other services (PostgreSQL).
- **Notification Service (Port 8084):** Handles user notifications asynchronously (MongoDB + Redis).

## 3. Implementation Details

### 3.1 Service Discovery (Eureka)
All microservices are configured as Eureka clients. They register themselves upon startup and heartbeats are managed to maintain an accurate service registry.
- **Status:** Self-preservation mode is disabled for local development to ensure fast registry updates.

### 3.2 API Gateway Routing
The API Gateway routes requests to downstream services based on path predicates:
- `/api/movies/**` -> `movie-service`
- `/api/customers/**` -> `customer-service`
- `/api/payments/**` -> `payment-service`
- `/api/notifications/**` -> `notification-service`

### 3.3 Synchronous Communication (OpenFeign)
When creating a payment, the `payment-service` must validate that the movie and customer exist.
- **Tool:** Spring Cloud OpenFeign.
- **Flow:**
  1. `payment-service` calls `movie-service/api/movies/{id}`.
  2. `payment-service` calls `customer-service/api/customers/{id}`.
- **Error Handling:** If either service returns a 404 or fails, the payment transaction is aborted.

### 3.4 Asynchronous Communication (RabbitMQ)
Once a payment is successfully processed, the system must send a receipt/notification without making the user wait for the email process.
- **Tool:** RabbitMQ (Topic Exchange).
- **Flow:**
  1. `payment-service` publishes a `PaymentSucceededEvent` to `payment.exchange` with routing key `payment.succeeded`.
  2. `notification-service` listens to the `payment.notification.queue` bound to that exchange.
  3. `notification-service` consumes the event and triggers the email sending logic.
- **Benefit:** Decouples the critical payment path from the non-critical notification path.

## 4. Testing and Results

### 4.1 Synchronous Validation Test
By attempting to create a payment for a non-existent movie ID, we verified that the `payment-service` correctly received an error from `movie-service` via Feign and returned a `400 Bad Request`.

### 4.2 End-to-End Async Test
1. **Trigger:** Sent a POST request to `/api/payments/create`.
2. **Payment Log:** `Sending payment succeeded event to RabbitMQ...`
3. **Notification Log:** `Received payment succeeded event from RabbitMQ: PaymentSucceededEvent{...}`
4. **Verification:** The transaction was saved in the PostgreSQL database, and the notification was logged as "Sent" in the console.

## 5. Conclusion
Lab 04 successfully integrated the core communication infrastructure. The use of Feign simplifies internal REST calls, while RabbitMQ ensures that the system remains responsive by handling background tasks asynchronously.
