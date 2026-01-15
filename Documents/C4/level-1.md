
# 🗺️ C4 Level 1 – System Context Diagram

## 1. Overview
The **Nozie Platform** is a microservices-based streaming system providing user management, content delivery, and secure payment processing.

## 2. Scope
- **Internal**: Identity, Movie Metadata, Subscriptions, Payments, Notifications.
- **External Interfaces**: Social Auth (Google/FB), Payments (Stripe), Metadata (TMDB), Delivery (CDN).

## 3. PlantUML Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-office/C4-PlantUML/master/C4_Context.puml

Person(customer, "Customer", "Uses the platform to watch movies.")
System(nozie, "Nozie Platform", "Video streaming and subscription system.")
System_Ext(stripe, "Stripe", "Payment gateway.")
System_Ext(tmdb, "TMDB", "Movie metadata provider.")
System_Ext(cdn, "CDN", "Video content delivery.")

Rel(customer, nozie, "Browses and watches movies", "HTTPS")
Rel(nozie, stripe, "Processes payments", "API")
Rel(nozie, tmdb, "Fetches movie details", "API")
Rel(nozie, cdn, "Streams video", "HLS/DASH")
@enduml
```