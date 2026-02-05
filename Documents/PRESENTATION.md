# Nozie – Movie Streaming & Subscription Platform  
## Project Presentation Script (English)

**Course:** Software Architecture  
**Team:** Group 03 – Class N02 (Nhật, Việt, Minh, Nhất)  
**Date:** February 2026  

---

## 1. Title & Introduction

**Slide: Title**

**What to say:**

"Good [morning/afternoon]. We are Group 03, Class N02, and today we present our project: **Nozie – a Movie Streaming and Subscription Platform** built with a **Microservices architecture**.

In this presentation we will cover: project goals and requirements, our architectural choices—Microservices and Event-Driven Architecture—the technical stack, the main flows in the system, and what we learned along the way.

In one sentence: **Nozie is a streaming platform designed and implemented with a Microservices architecture, combining REST APIs, an API Gateway, and Event-Driven communication for scalability and high availability.**"

---

## 2. Executive Summary

**Slide: Executive Summary**

**What to say:**

"Nozie is a **movie streaming and subscription platform** built on **Microservices** and **Event-Driven Architecture**, or EDA.

We have five core services. The **Identity Service** handles registration, login with credentials or OAuth, JWT tokens, and sessions. The **Movie Service** provides the catalog, search, watch—with a subscription check—and recommendations. The **Customer Service** manages profiles, watchlist, viewing history, and subscription status. The **Payment Service** integrates Stripe Checkout, webhooks, and subscription activation. The **Notification Service** sends transactional emails and alerts—and importantly, these are triggered by events and do **not** block the payment response.

All services are coordinated through an **API Gateway**, **Eureka** for service discovery, **Spring Cloud Config** for configuration, and **RabbitMQ** for events. Our main quality goals are **Scalability**, **Availability**, and **Modifiability**.

A key point: the payment API responds quickly because we send notifications **asynchronously** via RabbitMQ—that was a deliberate architectural decision."

---

## 3. Project Requirements & Goals

**Slide: Functional Requirements (FRs)**

**What to say:**

"On the requirements side, we have six main functional requirements. FR-01: users can register and log in with credentials or OAuth. FR-02: users can browse the movie catalog, search, and view movie details. FR-03: users can subscribe and pay via Stripe using a Checkout Session. FR-04 is critical: after a successful payment, the system must update subscription status and send notifications **without blocking** the payment response. FR-05: the API Gateway must route requests and validate JWT for protected routes. And FR-06: microservices register with Eureka and get their configuration from the Config Server."

**Slide: Non-Functional Requirements & ASRs**

**What to say:**

"For non-functional requirements: we need **Scalability**—so we can scale each service independently, for example add more Movie Service instances under load, with load balancing via Eureka. **Availability** means that if one service fails—say Notification—the payment flow must not break; we use Circuit Breaker and fallbacks to limit cascade failures. **Modifiability** means adding a new service or changing APIs and events should not require changing the whole system, which we achieve with EDA and the Gateway. **Security** is handled by JWT validation at the Gateway and by keeping secrets and config in Config Server and environment variables.

Two **Architecturally Significant Requirements** drove our design. First, **High Scalability**: the system must handle traffic spikes—like a new movie release or a promotion—without blocking the whole platform. That led us to Microservices, Database-per-Service, Event-Driven design, and independent scaling. Second, **Payment must not be blocked by notifications**: the payment API response time must be independent of how long it takes to send email or push. That led us to Event-Driven design—Payment publishes an event, Notification consumes it asynchronously. These two ASRs directly drove our choice of Microservices and RabbitMQ for decoupling."

---

## 4. Use Case Overview

**Slide: Use Case Model (27 Use Cases)**

**What to say:**

"We modelled **27 use cases** grouped by bounded context. Under **Identity** we have Register, Login, Social Login, Two-Factor Auth, Logout, Change Password, Session management, Roles, Audit Logs, and Profile. Under **Movie**: Browse Catalog, Search, Watch Movie, Watchlist, Rate and Review, Recommendations, Content Management, and TMDB Sync. Under **Customer**: View Plans, Check Membership, Viewing History, and Membership Rules. Under **Payment**: Checkout and Pay, Stripe Webhook, Billing History, and Refund. Under **Notification**: Transactional Alert, Marketing Push, and Security Alert.

Two relationships are important. **Watch Movie** *includes* **Check Membership**—so before playing we always check subscription; that enforces premium versus free content. **Checkout** *extends* **Transactional Alert**—after payment we send a notification. The full use case specs are in our repository under Architecture, UC."

---

## 5. Architectural Design

**Slide: Architecture – Microservices + Event-Driven**

**What to say:**

"Our architecture combines **Microservices** and **Event-Driven Architecture**. Each bounded context—Identity, Movie, Customer, Payment, Notification—is a separate service with its **own database**. We follow Database-per-Service strictly: services are deployed and scaled independently.

For **asynchronous** flows we use **RabbitMQ**. For example, when payment or subscription succeeds, the Payment Service publishes an event; Customer Service and Notification Service consume it and process **without blocking** the payment response. For **synchronous** calls—like Payment validating the customer or the plan—we use **Spring Cloud OpenFeign** and **Eureka** for service discovery."

**Slide: System Context (C4 Level 1)**

**What to say:**

"At the system context level, the **Nozie Platform** is the main system; inside it we have the API Gateway and all microservices. The main **actor** is the Customer—browsing, subscribing, paying. **External systems** are Stripe for payments, OAuth for Google and Facebook, TMDB for movie metadata, and a CDN for video streaming. **Communication** is twofold: synchronous over HTTPS and REST through the Gateway, and asynchronous via events through RabbitMQ. Our C4 Level 1 diagram in the repo shows this clearly."

---

## 6. Technical Stack & Data Model

**Slide: Technology Stack**

**What to say:**

"On the technical stack: we use **Spring Cloud Gateway** for the API Gateway—routing, JWT, CORS, and Resilience4j. **Netflix Eureka** for service discovery and **Spring Cloud Config Server** for centralized configuration. Identity Service is Spring Boot with PostgreSQL, JWT, and Redis for sessions and token blacklist. Movie Service is Spring Boot with MongoDB. Customer Service is Spring Boot, PostgreSQL, and acts as a RabbitMQ consumer. Payment Service is Spring Boot, PostgreSQL, Stripe SDK, OpenFeign for calling other services, and it publishes to RabbitMQ. Notification Service consumes from RabbitMQ and can use MongoDB or Redis. The message broker is **RabbitMQ** with Topic and Direct exchanges. We use **Redis** for cache and session, and we deploy everything with **Docker** and **Docker Compose**.

On the data model: each service owns its own schema—Identity has users and roles, Movie has movies and metadata, Customer has customers and subscriptions, Payment has subscriptions, plans, and Stripe IDs, Notification has logs and templates. There is **no shared database** between services; that is a strict rule—no service ever accesses another service’s database."

---

## 7. Key Flows

**Slide: API Gateway Routing**

**What to say:**

"The client talks only to the **API Gateway**—single entry point. Routes are path-based: slash api auth goes to Identity Service, api movies to Movie Service, api customers to Customer Service, api payments to Payment Service, and api notifications to Notification Service. For security: public routes like login and register do not require a JWT. Protected routes require a valid JWT, and the Gateway validates the token before forwarding the request."

**Slide: Payment → Event → Notification (EDA)**

**What to say:**

"Here is the main Event-Driven flow. First, the customer completes payment on Stripe. Stripe sends a webhook to our Payment Service with the event *checkout.session.completed*. The Payment Service validates the webhook, activates the subscription in its own database, and **publishes** a *SubscriptionActivatedEvent* to RabbitMQ. **Customer Service** consumes that event and updates subscription status and the Stripe customer ID. **Notification Service** also consumes it and sends the confirmation email—or logs it in our dev setup. The important point: the **HTTP response** for the payment is returned quickly; the email and subscription updates happen **asynchronously**. This is how we prove that payment is not blocked by notifications—we can show in a demo that the payment returns in milliseconds while the consumer logs appear a moment later."

---

## 8. Implementation Highlights

**Slide: Layered Structure (e.g. Movie Service)**

**What to say:**

"Inside each service we use a layered structure. In Movie Service, for example: the **presentation** layer has REST controllers for Catalog, Streaming, and Recommendations. The **business logic** layer has CatalogService, StreamingService, AccessControlService, and RecommendationService. The **persistence** layer has repositories for Movie, Genre, Country, MovieReview, and so on, talking to MongoDB. The request flow is always **Controller to Service to Repository to database**. Controllers never call repositories directly. We established this in Labs 2 and 3; Labs 4 through 7 added microservices, the Gateway, and EDA. Our Flutter client from weeks 9 and 10 connects to the Gateway for auth, catalog, watch, and subscription."

**Slide: Security & Resilience**

**What to say:**

"For security and resilience: **JWT** is issued by the Identity Service and validated at the Gateway for all protected routes. We use **Circuit Breaker** from Resilience4j on our Feign clients—for example when Payment calls Customer—so that if a downstream service is slow or down we don’t get cascade failures. For RabbitMQ, our consumers use **retry with exponential backoff**, and failed messages can go to a **Dead Letter Exchange** so we can inspect them later."

---

## 9. Testing & Verification

**Slide: Verification – Subscription & Notification E2E**

**What to say:**

"We verified the subscription and notification flow end-to-end. Step 1: we send a POST to create a Checkout Session with valid customer and plan IDs—we get 200 and the Stripe checkout URL. Step 2: we simulate the Stripe webhook *checkout.session.completed*—the Payment Service processes it, publishes the event, and updates its DB; we see the event on RabbitMQ and the subscription activated. Step 3: we check Customer Service—subscription and Stripe customer ID are updated, confirmed in DB and logs. Step 4: Notification Service’s consumer receives the event and sends the email or logs it—we see that in the consumer log. Step 5: we call checkout with an invalid customer ID—Payment uses Feign to call Customer, gets 404, and returns 400 Bad Request as expected. So the happy path and the error path both work."

**Slide: Gateway & JWT**

**What to say:**

"For the Gateway and JWT: calling slash api movies without a token—if that route is public—returns 200. Calling slash api customers slash me without a token, which is protected, returns 401 Unauthorized. With a valid JWT, the same endpoint returns 200 and the request is forwarded to customer-service. We have screenshots from Postman or Bruno and logs from the Gateway and services as evidence."

---

## 10. Conclusion & Future Work

**Slide: Conclusion**

**What to say:**

"In conclusion, Nozie successfully implements a **Microservices** architecture with **Event-Driven** communication. We have the API Gateway, Eureka, Config Server, five core services—Identity, Movie, Customer, Payment, Notification—plus RabbitMQ and Redis. We addressed the main quality attributes: **Scalability** through independent scaling and Database-per-Service; **Availability** through isolated failures, Circuit Breaker, and async notifications; and **Modifiability** so that new services and contract changes do not require rewriting the whole system."

**Slide: Lessons Learned**

**What to say:**

"Three lessons stand out. First, **EDA and decoupling**: moving notifications and subscription updates out of the payment request made the payment API fast and stable, and RabbitMQ ensures we don’t lose messages when a consumer is temporarily slow. Second, **Feign and Eureka**: calling services by name with built-in load balancing reduced manual configuration and made scaling simpler. Third, **Config Server**: changing timeouts, URLs, and feature flags without rebuilding services works well across dev, test, and prod."

**Slide: Future Improvements**

**What to say:**

"For future work we would add **observability**—distributed tracing with Zipkin or Micrometer and metrics with Prometheus and Grafana across all services. We would complete **caching** with Redis for the Movie catalog and Identity authority, with clear invalidation when data changes. For **deployment**, we would standardize Docker Compose for dev and consider Kubernetes and CI/CD for production. For **security**, we would rotate secrets like JWT and Stripe keys via Config Server or a vault and keep no secrets in the repository."

---

## 11. Q&A and References

**Slide: References**

**What to say:**

"All project docs are in our repository: the Architecture folder, PLAN dot md, Use cases under Architecture slash UC, the Sample Project Report, and Lab reports 1 to 4 in the Labs folder.

Thank you for your attention. We are happy to take your questions. If you’d like, we can run a short demo: login, browse movies, play a title with the subscription check, then go through subscribe with Stripe and show that the payment response is immediate while the notification is handled asynchronously. Thank you."

---

*End of presentation script. Each **Slide** has a matching **What to say** paragraph to read or adapt while presenting.*
