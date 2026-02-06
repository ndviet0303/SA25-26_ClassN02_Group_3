# 4. Architectural Design

## 4.1 Layered Architecture

Hệ thống Nozie áp dụng **kiến trúc phân lớp (Layered Architecture)** trong từng microservice. Mỗi service tuân thủ bốn lớp với quy tắc phụ thuộc một chiều: lớp trên chỉ gọi lớp ngay bên dưới.

| Lớp | Trách nhiệm | Thể hiện trong code (ví dụ) |
|-----|-------------|-----------------------------|
| **Presentation** | REST API, nhận request và trả response | `Controller` (e.g. `CustomerController`, `CatalogController`) |
| **Business Logic** | Nghiệp vụ, validation, orchestration | `Service` (e.g. `CustomerService`, `CatalogService`) |
| **Persistence** | Truy cập dữ liệu, CRUD | `Repository` (e.g. `CustomerRepository`, `MovieRepository`) |
| **Data** | Lưu trữ thực tế | PostgreSQL, MongoDB |

**Quy tắc kiến trúc:**
- Request đi theo luồng: **Controller → Service → Repository → Database**.
- Controller không gọi trực tiếp Repository; Service không gọi Controller.
- Mỗi lớp chỉ phụ thuộc vào interface/lớp ngay bên dưới, giúp dễ test và thay đổi implementation.

---

## 4.2 Microservices Decomposition

Hệ thống được phân rã theo **bounded context** và **năng lực kinh doanh** thành các microservice sau:

| Microservice | Bounded Context | Database | Chức năng chính |
|--------------|-----------------|----------|-----------------|
| **identity-service** | Xác thực & phân quyền | PostgreSQL (identitydb) | Đăng ký, đăng nhập, JWT, quản lý user/admin |
| **customer-service** | Hồ sơ khách hàng & sở thích | PostgreSQL (customerdb) | CRUD customer, watchlist, viewing history, interests |
| **movie-service** | Danh mục & phát phim | MongoDB (moviedb) | Catalog CRUD, tìm kiếm/lọc, streaming, recommendation |
| **payment-service** | Thanh toán & gói dịch vụ | PostgreSQL (paymentdb) | Subscription, Stripe checkout, giao dịch |
| **notification-service** | Thông báo | MongoDB (notificationdb) | In-app notification, email (EDA), queue events |

**Nguyên tắc Database per Service:** Mỗi service sở hữu database riêng; không service nào truy cập trực tiếp DB của service khác. Giao tiếp giữa các service qua **REST API** (sync) hoặc **message queue** (async, EDA).

---

## 4.3 C4 Model

### Context (C4 Level 1 – System Context)
- **Hệ thống Nozie** tương tác với:
  - **User (Customer):** xem phim, đăng ký, thanh toán, nhận thông báo.
  - **Content Manager / Admin:** quản lý nội dung, người dùng (qua identity-service).
- Nozie giao tiếp với **Stripe** (payment provider) và có thể mở rộng với **Email/SMS** cho notification.

### Container (C4 Level 2 – Containers)
- Mỗi **microservice** là một container: Flutter Client, API Gateway, Identity Service, Customer Service, Movie Service, Payment Service, Notification Service.
- **API Gateway** là điểm vào duy nhất cho client; client không gọi trực tiếp từng service.

### Component (C4 Level 3 – Components)
- Trong mỗi service: **Controller** (presentation), **Service** (business logic), **Repository** (persistence). Ví dụ Movie Service: `CatalogController` → `CatalogService` → `MovieRepository` → MongoDB.

### Code (C4 Level 4)
- Chi tiết class/interface trong từng component (có thể tham chiếu package structure trong repo).

---

## 4.4 Event-Driven Architecture

**Event-Driven Architecture (EDA)** is a style in which services communicate by producing and consuming **events** via a **message broker**, rather than calling each other directly over HTTP. In Nozie, EDA is used alongside request–response (REST) to achieve loose coupling and non-blocking behaviour where appropriate.

**Concepts:**
- **Producer:** A service that publishes events when something meaningful happens in its domain (e.g. a business state change).
- **Consumer:** A service that subscribes to events and reacts asynchronously (e.g. updating its own data or triggering side effects).
- **Message broker:** Middleware that receives events from producers, persists or routes them, and delivers them to consumers. Producers and consumers do not need to know each other’s endpoints or be available at the same time.

**Role in the overall architecture:**
- **Synchronous communication (REST):** Used for user-facing flows and when the caller needs an immediate result (e.g. catalog, auth, customer profile).
- **Asynchronous communication (EDA):** Used when one part of the system must react to something that happened in another part, without the original operation waiting for that reaction. This avoids blocking the main flow (e.g. payment confirmation) on slower or secondary actions (e.g. updating customer subscription status, sending notifications).

**Benefits of EDA in this system:**
- **Loose coupling:** Producers and consumers depend on the event contract and the broker, not on each other’s APIs or availability.
- **Non-blocking behaviour:** The service that performs the primary action (e.g. payment) can respond quickly; downstream updates and notifications happen in the background.
- **Resilience:** If a consumer is temporarily down, the broker can retain messages and deliver them when the consumer recovers, supporting retries and eventual consistency.
- **Scalability:** Consumers can be scaled independently, and multiple consumers can react to the same event for different purposes.

**Placement in the design:** Nozie uses a **hybrid** approach: REST for most client-to-service and service-to-service calls, and event-driven messaging for selected cross-cutting concerns (e.g. reactions to payment or subscription outcomes). The concrete choice of broker, event types, and flows is described in **Section 5.4 (EDA with RabbitMQ: Payment ↔ Notification)**.

---

## 4.5 Deployment View & System Infrastructure

**Hạ tầng (Docker Compose):**
- **Data stores:** PostgreSQL (nhiều DB: identitydb, customerdb, paymentdb), MongoDB (moviedb, notificationdb), Redis (cache, rate limit tại Gateway), RabbitMQ (message broker).
- **Discovery:** Eureka (discovery-server) – các service đăng ký và gọi nhau qua tên service (e.g. `lb://movie-service`).
- **Config:** Config Server (Spring Cloud Config) – cấu hình tập trung cho từng service.
- **Gateway:** API Gateway (port 8080) – routing, JWT auth, rate limit, circuit breaker, CORS.
- **Observability:** Zipkin (tracing), Prometheus + Grafana (metrics), Loki, ELK (logs) tùy cấu hình.

**Luồng triển khai:**
- Client (Flutter) → **API Gateway:8080** → Eureka → **movie-service**, **customer-service**, **payment-service**, **notification-service**, **identity-service**.
- Các service kết nối tới PostgreSQL/MongoDB/Redis/RabbitMQ tương ứng theo `docker-compose` và `application.yml`.

---

# 5. Server Implementation

## 5.1 Layered Architecture Implementation (CRUD per Labs 2–3)

Triển khai kiến trúc phân lớp với CRUD được thể hiện rõ trong **customer-service** và **movie-service**.

**Ví dụ Customer Service:**
- **Presentation:** `CustomerController` (`/api/customers`) – GET/POST/PUT/DELETE, chỉ gọi `CustomerService`.
- **Business Logic:** `CustomerService` – validation (e.g. `existsByUserId`), nghiệp vụ create/update, gọi các repository (Customer, Watchlist, ViewingHistory, Interest).
- **Persistence:** `CustomerRepository`, `WatchlistItemRepository`, `ViewingHistoryRepository`, `CustomerInterestRepository` – JPA/Spring Data, truy cập PostgreSQL.

**Ví dụ Movie Service (Catalog):**
- **Presentation:** `CatalogController` (`/api/movies`) – danh sách, tìm kiếm, filter, CRUD phim; `CatalogMetaController` – genres, countries.
- **Business Logic:** `CatalogService` – logic filter, pagination, map entity → DTO, gọi `MovieRepository`, `GenreRepository`, `CountryRepository`, và Feign `CustomerClient` (lấy watchlist).
- **Persistence:** `MovieRepository` (và custom `MovieRepositoryImpl`), `GenreRepository`, `CountryRepository` – Spring Data MongoDB.

**Minh chứng luồng:** Request → Controller → Service → Repository → DB; có thể kiểm chứng qua log (e.g. `log.info` trong Controller/Service) hoặc trace (Zipkin).

---

## 5.2 Movie Microservice & Database per Service (Lab 5)

**Movie Service** là một microservice độc lập:
- **Database:** MongoDB (`moviedb`) – chỉ movie-service kết nối tới DB này.
- **Cấu trúc package:** `catalog` (controller, service), `common` (model, dto, repository, client), `streaming` (controller, service), `recommendation` (controller, service), `config`.

**Chức năng chính:**
- Catalog: list, search, filter (genre, country, year, keyword), pagination, CRUD movie, genres/countries meta.
- Streaming: phát phim, kiểm tra quyền (subscription) qua `AccessControlService`, có thể gọi customer-service để xác nhận subscription.
- Recommendation: gợi ý phim (có thể dùng viewing history từ customer-service qua Feign).
- **Database per Service:** Movie, Genre, Country, Review lưu trong MongoDB; không truy cập PostgreSQL của customer hay payment.

**Giao tiếp với service khác:** Feign client `CustomerClient` – lấy watchlist theo userId để trả về danh sách phim trong watchlist (REST sync).

---

## 5.3 API Gateway & Edge Security (Lab 6)

**API Gateway** (Spring Cloud Gateway) là điểm vào duy nhất cho client:
- **Routing:** Theo path – e.g. `/api/movies/**` → movie-service, `/api/customers/**` → customer-service, `/api/subscriptions/**` → payment-service, `/api/notifications/**` → notification-service, `/api/auth/**`, `/api/admin/**` → identity-service. Dùng Eureka (`lb://service-id`) để load balance.
- **Edge security:**
  - **Authentication:** `AuthenticationFilter` – kiểm tra JWT trong header `Authorization`, validate token (JWT secret), có thể kiểm tra blacklist (Redis). Endpoint public (e.g. login, register) bỏ qua auth.
  - **Rate limiting:** `RateLimitFilter` – dùng Redis để giới hạn số request theo IP/user; ví dụ login: 30 req/phút theo IP, user API: 1000 req/phút.
  - **CORS:** Cấu hình global CORS tại gateway (allowedOrigins, methods, headers).
- **Resilience:** Circuit Breaker (Resilience4j) cho từng route – khi service lỗi vượt ngưỡng thì chuyển sang fallback (e.g. `forward:/fallback/movies`) thay vì trả lỗi 5xx trực tiếp.
- **Logging:** `AccessLogFilter` – ghi log request/response; correlation ID hỗ trợ trace.

---

## 5.4 EDA with RabbitMQ: Payment ↔ Notification (Lab 7)

**Triển khai Event-Driven giữa Payment Service và Notification Service (và Customer Service):**

**Payment Service (Producer):**
- Sau khi subscription được kích hoạt (Stripe webhook hoặc logic nội bộ), gọi `PaymentEventProducer.sendSubscriptionActivatedEvent(SubscriptionActivatedEvent)`.
- Event chứa: `userId`, `planType`/`planName`, `endDate`, `stripeCustomerId`, v.v.
- Gửi vào RabbitMQ: exchange `payment.exchange`, routing key `subscription.activated` (cấu hình trong `RabbitMQConfig`).

**Customer Service (Consumer):**
- `SubscriptionEventListener` lắng nghe queue `customer.subscription.queue` (binding tới `payment.exchange` với key `subscription.activated`).
- Khi nhận `SubscriptionActivatedEvent`: tìm customer theo `userId`, cập nhật trạng thái subscription (FREE/PREMIUM/VIP), `endDate`, `stripeCustomerId`, lưu vào DB.

**Notification Service (Consumer):**
- `SubscriptionEventConsumer` lắng nghe cùng queue (hoặc queue riêng binding cùng routing key tùy cấu hình).
- Khi nhận event: gọi `NotificationService.createNotification(...)` tạo in-app notification cho user (nội dung kiểu "Gói X đã được kích hoạt đến ngày …").

**Cấu hình RabbitMQ:** Topic exchange, queue(s), binding; message converter JSON (Jackson); các service kết nối RabbitMQ qua `application.yml` (host, port, user, password). Docker Compose khai báo container RabbitMQ (port 5672, 15672 management).

---

*Tài liệu này trình bày nội dung mục 4 (Architectural Design) và 5 (Server Implementation) cho báo cáo dự án Nozie, bám sát cấu trúc trong CONTENT.md và codebase hiện tại.*
