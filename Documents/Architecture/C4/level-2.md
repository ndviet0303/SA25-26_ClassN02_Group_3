
# 🏗️ C4 Level 2 – Container Diagram

## 1. Architecture
Decoupled microservices architecture utilizing **Java 21**, **Spring Cloud**, and specialized databases for high availability and scalability.

## 2. Core Containers
- **API Gateway**: Entry point for JWT validation and routing.
- **Identity Service**: Auth & Profiles (**PostgreSQL**).
- **Movie Service**: Catalog & Search (**MongoDB**).
- **Payment Service**: Transaction handling (**PostgreSQL**).
- **Notification Service**: Event-driven alerts (**MongoDB**).
- **Message Broker**: **RabbitMQ** for async service communication.

## 3. PlantUML Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-office/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title Advanced Container Diagram (Optimized Architecture)

Person(user, "Customer", "Uses Web/Mobile app to stream movies.")

System_Boundary(nozie_boundary, "Nozie Platform") {
    
    Container(app, "Web/Mobile App", "React/Flutter", "High-performance UI")
    
    Container(gateway, "API Gateway", "Spring Cloud Gateway", "Auth, Routing, Rate Limiting")
    ContainerDb(redis, "Global Cache", "Redis 7.2", "Blacklist, Rate Limit, and Hot Metadata")

    '--- Performance Services ---
    Container(identity, "Identity Service", "Java 21", "Manages Auth & Enriched Profiles")
    ContainerDb(id_db, "Identity DB", "PostgreSQL", "Relational data")

    Container(movie, "Movie Service", "Java 21", "Optimized Video Catalog Management")
    ContainerDb(movie_db, "Movie DB", "MongoDB", "Flexible metadata storage")

    Container(payment, "Payment Service", "Java 21", "Transactional Gateway for Stripe")
    ContainerDb(pay_db, "Payment DB", "PostgreSQL", "Transaction logs")

    '--- Async & Resilience ---
    Container(rabbitmq, "Message Broker", "RabbitMQ", "Event-driven backbone for service decoupling")
    Container(notify, "Notification Service", "Java 21", "Async alert processor")
}

System_Ext(stripe, "Stripe API", "External Payment Gateway")
System_Ext(cdn, "CDN", "Edge delivery for high-bitrate video")

'--- Critical Optimized Flows ---
Rel(user, app, "Uses", "HTTPS")
Rel(app, gateway, "API Calls", "HTTPS/JSON")

'-- Optimization: Cache-aside at Gateway
Rel(gateway, redis, "1. Verify Token/Rate Limit", "Jedis (Low Latency)")

'-- Optimization: Read-optimized Retrieval
Rel(movie, redis, "Cache Hot Movies", "Jedis")
Rel(movie, movie_db, "DB Fallback", "BSON")

'-- Optimization: Event-Driven Payment Flow
Rel(payment, stripe, "Charge", "HTTPS")
Rel(payment, rabbitmq, "Publish 'payment.success'", "AMQP")
Rel(rabbitmq, notify, "Consume event", "AMQP")
Rel(rabbitmq, identity, "Update subscription", "AMQP")

Rel(movie, cdn, "Serve Video", "Signed URL")

@enduml
```
