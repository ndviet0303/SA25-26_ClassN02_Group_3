# 5. Server Implementation

## 5.1 Layered Architecture Implementation (CRUD per Labs 2–3)

Each microservice follows a **DDD-oriented layered structure**: API → Application → Domain → Infrastructure. Request flow is strictly top-down.

**Payment Service (example):**

| Layer | Package | Responsibility |
|-------|---------|----------------|
| **API** | `api.controller`, `api.dto` | `SubscriptionController`: REST endpoints (`/api/subscriptions/plans`, `/subscribe`, `/active/{userId}`, `/current/{userId}`, `/history/{userId}`, `/cancel/{userId}`, `/webhook`). Maps request/response DTOs; no business logic. |
| **Application** | `application.service` | `SubscriptionApplicationService`: use cases (create checkout session, validate user via Feign, handle Stripe webhook, activate subscription, publish `SubscriptionActivatedEvent`). Transaction boundaries and orchestration. |
| **Domain** | `domain.model`, `domain.repository` | `Subscription`, `SubscriptionPlan`, `Transaction`; repository interfaces. Business rules (e.g. `Subscription.activate()`, status transitions). |
| **Infrastructure** | `infrastructure.client`, `infrastructure.messaging`, `infrastructure.stripe` | JPA repository implementations, `CustomerClient`/`MovieClient` (OpenFeign), `PaymentEventProducer` (RabbitMQ), `StripeService`. |

**Customer Service:** `CustomerController` → `CustomerService` → domain model & repository; listeners `UserRegisteredListener`, `SubscriptionEventListener` consume events from RabbitMQ.

**Movie Service:** `CatalogController`, `StreamingController`, `RecommendationController` → `CatalogService`, `StreamingService`, `RecommendationService` → repositories (e.g. `MovieRepository`). Layering is consistent with the above.

**→ Chèn hình 5.1 ngay dưới dòng này:**  
**Figure 5.1** – Request flow (sequence): Subscribe hoặc webhook qua Controller → ApplicationService → EventProducer.

**Evidence for report:** Describe request path for one flow (e.g. `POST /api/subscriptions/subscribe` → Controller → SubscriptionApplicationService → CustomerClient, StripeService, SubscriptionRepository, then webhook path → `handleCheckoutSessionCompleted` → `eventProducer.sendSubscriptionActivatedEvent`).

**→ Chèn hình 5.2 ngay dưới dòng này:**

**Figure 5.2 – Package Structure**  
*Description:* An IDE screenshot showing the package organization (api, application, domain, infrastructure) within the Payment Service.

**Package tree (Payment Service):**

```
com.nozie.paymentservice/
├── PaymentServiceApplication.java
├── api/
│   ├── controller/
│   │   └── SubscriptionController.java
│   └── dto/
│       ├── SubscriptionRequest.java
│       └── SubscriptionResponse.java
├── application/
│   └── service/
│       └── SubscriptionApplicationService.java
├── domain/
│   ├── model/
│   │   ├── Subscription.java
│   │   ├── SubscriptionPlan.java
│   │   └── Transaction.java
│   └── repository/
│       ├── SubscriptionPlanRepository.java
│       ├── SubscriptionRepository.java
│       └── TransactionRepository.java
└── infrastructure/
    ├── client/
    │   ├── CustomerClient.java
    │   ├── MovieClient.java
    │   └── dto/
    │       ├── CustomerDTO.java
    │       └── MovieDTO.java
    ├── config/
    │   └── RabbitMQConfig.java
    ├── messaging/
    │   └── PaymentEventProducer.java
    └── stripe/
        └── StripeService.java
```

*Trong báo cáo:* Có thể thay cây thư mục trên bằng screenshot IDE (project view) với caption Figure 5.2.

---

## 5.2 Movie Microservice & Database per Service (Lab 5)

**Own database:** Movie Service uses its **own data store**: MongoDB (declared in `pom.xml`: `spring-boot-starter-data-mongodb`); config may override to H2 for local dev. No direct access to Identity, Customer, or Payment databases.

**Main APIs (exposed via Gateway):**

- `GET /api/movies` – list with pagination, filters (type, genre, country, year), search keyword.
- `GET /api/movies/search?q=` – search by keyword.
- `GET /api/movies/{id}` – movie detail.
- Genres/countries/years metadata endpoints.
- Streaming and recommendation endpoints (e.g. play URL, access control).

**Components:** `CatalogController` → `CatalogService` → `MovieRepository` / `MovieRepositoryCustom`; `StreamingController` → `StreamingService`, `AccessControlService`; `RecommendationController` → `RecommendationService`. Optional Feign call to Customer Service for subscription/access checks.

**Isolation testing:** Call Movie Service directly (or via Gateway) with `GET /api/movies`, `GET /api/movies/{id}` to verify it runs independently; document with Postman/curl and optional screenshot.

**→ Chèn hình 5.3 ngay dưới dòng này:**  
**Figure 5.3** – Movie Service boundary và DB riêng (MongoDB); route Gateway `/api/movies/**`.

**→ Chèn hình 5.9 ngay dưới dòng này:**  
**Figure 5.9** – Screenshot Postman/Bruno: GET /api/movies hoặc GET /api/movies/{id} và response.

---

## 5.3 API Gateway & Edge Security (Lab 6)

**Role:** Single entry point for the Flutter client. Routes requests to backend services using **path-based routing** and **Eureka** (`lb://service-id`).

**Routing (from `application.yml`):**

| Path | Service | Notes |
|------|---------|--------|
| `/api/movies/**`, `/api/genres/**`, `/api/countries/**`, `/api/years/**` | movie-service | Circuit breaker → fallback `/fallback/movies` |
| `/api/customers/**` | customer-service | Circuit breaker → `/fallback/customers` |
| `/api/subscriptions/**` | payment-service | Includes `/webhook`; circuit breaker → `/fallback/payments` |
| `/api/notifications/**` | notification-service | Circuit breaker → `/fallback/notifications` |
| `/api/auth/**`, `/api/admin/**` | identity-service | JWT validation for secured paths |

**→ Chèn hình 5.4 ngay dưới dòng này:**  
**Figure 5.4** – API Gateway routing (diagram Client → Gateway → 5 service, hoặc giữ bảng trên làm hình).

**Security (edge):**

- **JWT validation:** `AuthenticationFilter` (GlobalFilter, order -100) reads `Authorization: Bearer <token>`, validates signature and expiry using `jwt.secret`, extracts `userId`, `username`, `roles`, `permissions` and sets headers `X-User-Id`, `X-User-Name`, `X-User-Roles`, `X-User-Permissions`, `X-Correlation-Id` for downstream.
- **Open endpoints (no token required):** `RouteValidator.isSecured(path)` returns false for: `/api/auth/register`, `/api/auth/login`, `/api/auth/refresh`, `/api/auth/validate`, forgot-password, reset-password, check-username/email, verify-email, `/api/subscriptions/webhook`, `/api/subscriptions/plans`, `/api/movies`, `/api/genres`, `/api/countries`, `/api/years`, `/api/recommendations`, `/actuator`, `/fallback`, `/health`. All other paths require a valid JWT.
- **Token revocation:** Optional Redis check `token:blacklist:{jti}`; if blacklisted, returns 401 for secured routes.
- **Admin routes:** `RouteValidator.isAdminRoute(path)` identifies `/api/admin` for future role checks.
- **Resilience:** Resilience4j circuit breakers per service; CORS configured globally.

**→ Chèn hình 5.5 ngay dưới dòng này:**  
**Figure 5.5** – Bảng Open vs Secured endpoints (từ RouteValidator).

**→ Chèn hình 5.6 ngay dưới dòng này:**  
**Figure 5.6** – Flowchart JWT tại Gateway: Request → AuthenticationFilter → validate JWT / Redis blacklist → forward hoặc 401.


---

## 5.4 EDA with RabbitMQ: Payment ↔ Notification (Lab 7)

**Broker:** RabbitMQ (Topic exchanges). Events are published by producers and consumed by listeners in different services so that payment response is not blocked by notification or customer updates.

**Events and flows:**

1. **UserRegisteredEvent**
   - **Producer:** Identity Service – `UserEventProducer.sendUserRegisteredEvent()` → exchange `user.exchange`, routing key `user.registered`.
   - **Consumers:** Customer Service (`UserRegisteredListener`, queue `user.registered.queue`) creates customer record and optional interests; Notification Service (`UserEventConsumer`, queue `user.notification.queue`) sends welcome notification.

2. **SubscriptionActivatedEvent**
   - **Producer:** Payment Service – after Stripe webhook `checkout.session.completed`, `SubscriptionApplicationService.handleCheckoutSessionCompleted()` activates subscription, saves transaction, then `PaymentEventProducer.sendSubscriptionActivatedEvent()` → exchange `payment.exchange`, routing key `subscription.activated`.
   - **Consumers:** Customer Service (`SubscriptionEventListener`, queue `subscription.notification.queue`) updates customer subscription status (FREE/PREMIUM/VIP) and end date; Notification Service (`SubscriptionEventConsumer`, same queue) creates in-app notification “Gói … đã được kích hoạt!”.

3. **PaymentSucceededEvent**
   - **Consumer only (as of codebase):** Notification Service – `PaymentEventConsumer` on queue `payment.notification.queue` (routing key `payment.succeeded`). Producer not present in code; event is defined in `common` for future use (e.g. single-movie purchase receipt).

**Decoupling proof:** Checkout flow returns session URL to client immediately; activation and notifications run asynchronously after Stripe webhook. No blocking of payment API by notification or customer update.

**→ Chèn hình 5.7 ngay dưới dòng này:**  
**Figure 5.7** – Diagram luồng event RabbitMQ: user.exchange + payment.exchange, các queue, producer (Identity, Payment), consumer (Customer, Notification).

**→ Chèn hình 5.8 ngay dưới dòng này:**  
**Figure 5.8** – Sequence Subscription Activation: Stripe webhook → Payment Service → sendSubscriptionActivatedEvent → RabbitMQ → Customer Service + Notification Service.

**→ Chèn hình 5.10 ngay dưới dòng này (tùy chọn):**  
**Figure 5.10** – Screenshot RabbitMQ Management UI (exchanges và queues).


---

## Suggested Diagrams & Figures (for Report / Slides)

Use the list below to insert figures into the report. Each item has a suggested caption and what the image should show.

---

### Section 4 (Architectural Design)

| Fig | Title | Type | Content |
|-----|--------|------|--------|
| **4.1** | Layered Architecture (DDD) – One Service | Diagram | 4 horizontal layers: API → Application → Domain → Infrastructure; example components (Controller, ApplicationService, Aggregate, Repository, RabbitMQ/Feign). Use payment-service or movie-service. |
| **4.2** | Monolith vs Microservices Decomposition | Diagram | Left: single “Nozie Monolith” box. Right: 5 service boxes (Identity, Customer, Movie, Payment, Notification) with arrows to API Gateway and RabbitMQ. |
| **4.3** | C4 Level 1 – System Context | Diagram | One “Nozie” system; actors (Customer, Admin); external systems (Stripe, OAuth2, Mail, R2, CDN/HLS). Use existing `Design/C4/level-1.jpg` if available. |
| **4.4** | C4 Level 2 – Containers | Diagram | API Gateway, 5 microservices, Discovery, Config, RabbitMQ, DBs. Use `level-2.jpg` or redraw from CONTENT. |
| **4.5** | C4 Level 3 – Components (e.g. Payment Service) | Diagram | Inside payment-service: Controller, ApplicationService, Domain, Repositories, EventProducer, Feign clients. Use `level-3.jpg` or component diagram. |
| **4.6** | Event-Driven Flow – Subscription Activation | Diagram / Sequence | Payment Service → RabbitMQ (subscription.activated) → Customer Service + Notification Service. Optional: sequence Stripe webhook → handleCheckoutSessionCompleted → sendSubscriptionActivatedEvent → consumers. |
| **4.7** | Deployment View | Diagram | Nodes: Client, API Gateway, microservices (containers), Postgres/Mongo/Redis, RabbitMQ, Config, Eureka. Optional: Docker Compose / deployment topology screenshot. |

---

### Section 5 (Server Implementation)

| Fig | Title | Type | Content |
|-----|--------|------|--------|
| **5.1** | Request Flow – Layered (e.g. Subscribe) | Sequence diagram | Flutter → Gateway → Payment Controller → SubscriptionApplicationService → CustomerClient, StripeService, Repository; then Webhook → handleCheckoutSessionCompleted → eventProducer. |
| **5.2** | Payment Service Package Structure | Screenshot or tree | IDE package view: `api`, `application`, `domain`, `infrastructure` with key classes. |
| **5.3** | Movie Service Boundary & DB | Diagram | Box “Movie Service” with Catalog/Streaming/Recommendation; own DB (MongoDB); Gateway route `/api/movies/**`. |
| **5.4** | API Gateway Routing Table | Table or diagram | Path → service mapping (as in 5.3); optional small diagram: Client → Gateway → 5 services with path labels. |
| **5.5** | Open vs Secured Endpoints | Table | Two columns: Open (e.g. /api/auth/login, /api/movies, /api/subscriptions/plans, webhook) and Secured (e.g. /api/customers/me, /api/subscriptions/subscribe, /api/admin/**). |
| **5.6** | JWT Validation Flow at Gateway | Flowchart or sequence | Request → AuthenticationFilter → check Authorization → validate JWT → Redis blacklist? → set X-User-Id, etc. → forward; else 401. |
| **5.7** | RabbitMQ Event Flows | Diagram | Two flows: (1) user.exchange / user.registered → user.registered.queue, user.notification.queue. (2) payment.exchange / subscription.activated → subscription.notification.queue. Label producers (Identity, Payment) and consumers (Customer, Notification). |
| **5.8** | Subscription Activation Sequence | Sequence diagram | Stripe Webhook → Payment Service (handleCheckoutSessionCompleted) → activate subscription, save transaction → sendSubscriptionActivatedEvent → RabbitMQ → Customer Service (update subscription) + Notification Service (create notification). |
| **5.9** | Postman / Bruno – Movie API or Subscribe | Screenshot | One or two requests: e.g. GET /api/movies and POST /api/subscriptions/subscribe (or webhook simulation) with response. |
| **5.10** | RabbitMQ Management UI (optional) | Screenshot | Queues and exchanges (user.exchange, payment.exchange, queues) to show topology. |

---

### Tools & Format

- **Diagrams:** draw.io, Excalidraw, PlantUML, Mermaid (export PNG/SVG).
- **Sequence:** PlantUML sequence or Mermaid `sequenceDiagram`.
- **Screenshots:** IDE (package structure), Postman/Bruno (API test), RabbitMQ console, Gateway logs (optional).
- **Tables:** Can stay in Markdown/Word; “Open vs Secured” and “Routing” work well as tables.

---

### Chỗ chèn ảnh – điền đúng vị trí đã ghi trong bài

Trong bài, mỗi hình đã có **đúng một dòng** dạng: **"→ Chèn hình 5.X ngay dưới dòng này:"**. Điền ảnh vào **ngay dưới** dòng đó (và caption Figure 5.X bên dưới).

| Figure | Vị trí trong file (tìm dòng này, chèn ảnh ngay dưới) |
|--------|------------------------------------------------------|
| **5.1** | Dòng có chữ: **→ Chèn hình 5.1 ngay dưới dòng này:** (mục 5.1, sau bảng 4 lớp). |
| **5.2** | Dòng có chữ: **→ Chèn hình 5.2 ngay dưới dòng này:** (mục 5.1, sau "Evidence for report"). |
| **5.3** | Dòng có chữ: **→ Chèn hình 5.3 ngay dưới dòng này:** (mục 5.2, sau "Isolation testing"). |
| **5.4** | Dòng có chữ: **→ Chèn hình 5.4 ngay dưới dòng này:** (mục 5.3, sau bảng Routing). |
| **5.5** | Dòng có chữ: **→ Chèn hình 5.5 ngay dưới dòng này:** (mục 5.3, sau "Resilience"). |
| **5.6** | Dòng có chữ: **→ Chèn hình 5.6 ngay dưới dòng này:** (mục 5.3, ngay sau 5.5). |
| **5.7** | Dòng có chữ: **→ Chèn hình 5.7 ngay dưới dòng này:** (mục 5.4, sau "Decoupling proof"). |
| **5.8** | Dòng có chữ: **→ Chèn hình 5.8 ngay dưới dòng này:** (mục 5.4, ngay sau 5.7). |
| **5.9** | Dòng có chữ: **→ Chèn hình 5.9 ngay dưới dòng này:** (mục 5.2, sau 5.3). |
| **5.10** | Dòng có chữ: **→ Chèn hình 5.10 ngay dưới dòng này (tùy chọn):** (mục 5.4, cuối mục). |

*Section 4:* Chèn 4.1 sau mục 4.1, 4.2 sau 4.2, 4.3–4.5 trong mục 4.3, 4.6 trong 4.4, 4.7 trong 4.5.
