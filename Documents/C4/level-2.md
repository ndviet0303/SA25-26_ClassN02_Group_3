
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

System_Boundary(nozie, "Nozie Platform") {
    Container(gateway, "API Gateway", "Spring Cloud", "Authentication & Routing")
    Container(identity, "Identity Service", "Java/Spring", "User management")
    Container(movie, "Movie Service", "Java/Spring", "Catalog management")
    Container(notify, "Notification Service", "Java/Spring", "Event handling")
    ContainerDb(db1, "SQL DB", "PostgreSQL", "Relational data")
    ContainerDb(db2, "NoSQL DB", "MongoDB", "Metadata & Logs")
    Container(mq, "RabbitMQ", "Message Broker", "Async messaging")
}

Rel(gateway, identity, "Authenticates", "JSON/HTTP")
Rel(identity, db1, "Persists", "JDBC")
Rel(movie, db2, "Persists", "BSON")
Rel(mq, notify, "Trigger", "AMQP")
@enduml
```
