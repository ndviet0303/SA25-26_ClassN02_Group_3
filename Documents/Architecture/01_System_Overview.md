
# 🏛️ System Overview: Nozie Microservices Ecosystem

## 1. Architectural Philosophy
The Nozie platform follows a **Domain-Driven Design (DDD)** approach, decomposed into autonomous microservices. The core philosophy is **Scalability**, **Separation of Concerns**, and **High Availability**.

## 2. Core Components
- **Identity Service**: Trust & Security.
- **Movie Service**: Catalog & Discovery.
- **Payment Service**: Revenue & Transactions.
- **Customer Service**: Relationship & Subscription.
- **Notification Service**: Engagement & Alerting.

## 3. Communication Patterns
- **Synchronous (Request/Response)**: Managed via **Spring Cloud OpenFeign** for real-time validation (e.g., Payment verifying User status).
- **Asynchronous (Event-Driven)**: Powered by **RabbitMQ** for decoupling long-running or non-blocking tasks (e.g., Post-payment notifications).

## 4. Deployment & Infrastructure
- **Containerization**: All services and infrastructure dependencies (PostgreSQL, MongoDB, Redis, RabbitMQ) are managed via **Docker**.
- **Service Discovery**: **Netflix Eureka** handles service registry, allowing dynamic scaling without static IPs.
- **Centralized Configuration**: **Spring Cloud Config** provides environmentally decoupled settings.
