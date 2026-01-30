# 🏗️ Microservice Infrastructure: Core Pillars

The Nozie platform relies on a robust cloud-native infrastructure designed for high availability, service independence, and centralized management.

## 1. Service Discovery & Registry (Discovery Server)
- **Technology**: Netflix Eureka
- **Role**: Acts as a phonebook for all microservices. 
- **Mechanism**:
  - Each microservice (Identity, Movie, etc.) registers its IP and Port with Eureka upon startup.
  - Services use **Service IDs** (e.g., `identity-service`) to communicate instead of hardcoded IPs.
  - Facilitates **Client-side Load Balancing** via Spring Cloud LoadBalancer.

## 2. Centralized Configuration (Config Server)
- **Technology**: Spring Cloud Config
- **Role**: Externalizes configuration for all environments.
- **Benefits**:
  - Update configurations (like timeout values or secrets) without rebuilding/redeploying services.
  - Supports different profiles (dev, test, prod).
  - All services fetch their `application.yml` from this central server at bootstrap.

## 3. Intelligent API Gateway (Edge Service)
- **Technology**: Spring Cloud Gateway
- **Role**: The single entry point for all client requests (Flutter App, Postman).
- **Core Functions**:
  - **Dynamic Routing**: Routes `/api/auth/**` to `identity-service`, `/api/movies/**` to `movie-service`, etc.
  - **Global Security**: Implements `AuthenticationFilter` to validate JWT tokens before passing it to downstream services.
  - **Resilience**: Integrated with **Resilience4j** for Circuit Breaking and Fallbacks.
  - **CORS Handling**: Global policy management for secure cross-origin requests.

## 4. Polyglot Persistence Layer
We use multiple database technologies chosen for specific domain needs:
- **PostgreSQL (Relational)**: Used by `identity-service`, `customer-service`, and `payment-service` for ACID compliance and complex relationships (Users, Roles, Transactions).
- **MongoDB (NoSQL/Document)**: Used by `movie-service` and `notification-service` for flexible schema requirements (Movie metadata, nested attributes) and high-volume writes.
- **Redis (Cache/Session)**: 
  - Centralized storage for User Sessions in `identity-service`.
  - Rate limiting and metadata caching in `api-gateway`.

## 5. Event-Driven Messaging (Message Broker)
- **Technology**: RabbitMQ
- **Role**: Decouples services via asynchronous communication.
- **Workflow Example**:
  1. `payment-service` completes a transaction.
  2. It publishes a `PaymentEvent` to the `payment-exchange`.
  3. `notification-service` listens to a specific queue and sends a Push Notification to the user.
- **Outcome**: Ensures the payment process is not blocked by slow notification delivery.

## 6. Containerization & Orchestration
- **Runtime**: Docker & Docker Compose
- **Role**: Ensures parity between Development and Production environments.
- **Infrastructure Stack**: 
  - Includes Zipkin (Tracing), Prometheus/Grafana (Metrics), and ELK Stack (Logging) for comprehensive observability.
