# Template – Sample Course Project Report: Nozie Movie Streaming Platform

*(Báo cáo mẫu dựa trên Template - Sample Project Report, nội dung áp dụng cho toàn bộ dự án Nozie.)*

---

## Contents

1. [Cover Page & Info](#1-cover-page--info)
2. [Executive Summary](#2-executive-summary)
3. [Project Requirements & Goals](#3-project-requirements--goals)
4. [Architectural Design & Implementation](#4-architectural-design--implementation)
5. [Testing & Verification](#5-testing--verification)
6. [Conclusion & Reflection](#6-conclusion--reflection)

---

## 1. Cover Page & Info

- **Project Title:** Nozie – Movie Streaming & Subscription Platform (Microservices Architecture)
- **Course Name:** Software Architecture
- **Team / Student Info:** [Group 03 – Class N02] — Nhật (Lead), Việt, Minh, Nhất
- **Date:** February 2026

---

## 2. Executive Summary

Dự án Nozie nhằm thiết kế và triển khai một **nền tảng streaming phim** dựa trên kiến trúc **Microservices**, kết hợp **Event-Driven Architecture (EDA)** và giao tiếp đồng bộ (REST/OpenFeign). Hệ thống cung cấp: quản lý người dùng và xác thực (Identity Service), danh mục phim (Movie Service), quản lý khách hàng và gói subscription (Customer Service), thanh toán qua Stripe (Payment Service), và thông báo bất đồng bộ (Notification Service). Tất cả dịch vụ được điều phối qua **API Gateway**, **Eureka** (service discovery), **Spring Cloud Config**, và **RabbitMQ** cho luồng sự kiện. Kết quả đạt được là một hệ thống có khả năng mở rộng, tách biệt lỗi, và đáp ứng các mục tiêu chất lượng: **Scalability**, **Availability**, và **Modifiability**.

---

## 3. Project Requirements & Goals

Phần này mô tả phạm vi và các driver kiến trúc chính của dự án.

### 3.1 Core Functional Requirements

| ID | Description |
|----|-------------|
| FR-01 | Hệ thống phải cho phép người dùng đăng ký và đăng nhập (credentials và/hoặc OAuth). |
| FR-02 | Người dùng phải có thể duyệt danh mục phim, tìm kiếm và xem chi tiết phim. |
| FR-03 | Người dùng phải có thể đăng ký gói (subscription) và thanh toán qua Stripe (Checkout Session). |
| FR-04 | Sau thanh toán thành công, hệ thống phải cập nhật trạng thái subscription của khách hàng và gửi thông báo (email/notification) mà không chặn response thanh toán. |
| FR-05 | API Gateway phải định tuyến request tới đúng microservice và xác thực JWT cho các route được bảo vệ. |
| FR-06 | Các microservice phải đăng ký với Eureka và lấy cấu hình từ Config Server. |

### 3.2 Key Quality Attributes (Architectural Goals – Non-functional Requirements)

- **Scalability:** Hệ thống phải scale theo từng service (vd: tăng instance Movie Service khi tải cao) và hỗ trợ cân bằng tải qua Eureka/LoadBalancer.
- **Availability:** Lỗi một service (vd: Notification) không được kéo sập luồng thanh toán; Circuit Breaker và Fallback giảm cascade failure.
- **Modifiability:** Thêm service mới hoặc thay đổi contract (API/event) không đòi hỏi sửa toàn bộ hệ thống nhờ EDA và API Gateway.
- **Security:** Xác thực JWT tại Gateway; bí mật và cấu hình được quản lý tập trung (Config Server, biến môi trường).

### 3.3 Propose Model of ASR

- **ASR: High Scalability (NFR)**  
  - **Statement:** Hệ thống phải xử lý được đột biến truy cập (vd: ra mắt phim mới hoặc sự kiện khuyến mãi) mà không làm nghẽn toàn bộ nền tảng.  
  - **Impact:** Thúc đẩy lựa chọn Microservices, Database-per-Service, và Event-Driven; cho phép scale độc lập từng service và dùng message broker (RabbitMQ) để tách tải.

- **ASR: Payment Not Blocked by Notifications (NFR)**  
  - **Statement:** Thời gian phản hồi API thanh toán phải độc lập với thời gian gửi email/push.  
  - **Impact:** Dẫn tới kiến trúc hướng sự kiện: Payment Service publish event, Notification Service consume bất đồng bộ; người dùng nhận response thanh toán nhanh, thông báo xử lý sau.

### 3.4 Use Case Modeling (đầy đủ 27 UC)

Tài liệu chi tiết: **`Documents/Architecture/UC/Use_Case_Modeling_Full.md`** (luồng, API, trạng thái triển khai từng UC).

Tóm tắt theo package:

| Package | UC ID | Use Case | Actor | API / Ghi chú |
|---------|-------|----------|--------|----------------|
| **Identity** | UC1 | Register | Customer | POST /api/auth/register |
| | UC2 | Login via Credentials | Customer | POST /api/auth/login |
| | UC2_1 | Social Auth Login | Customer | POST /api/auth/social-login (stub) |
| | UC2_2 | Two-Factor Auth | Customer | (Mở rộng login) |
| | UC3 | Logout & Revoke Token | Customer | POST /api/auth/logout, DELETE /api/auth/sessions/{id} |
| | UC4 | Change Password | Customer | POST /api/auth/change-password |
| | UC5 | Manage User Sessions | Customer | GET /api/auth/sessions |
| | UC6 | Assign Roles/Permissions | Admin | /api/admin/roles, /api/admin/users/{id}/roles |
| | UC7 | View System Audit Logs | Admin | GET /api/admin/audit-logs |
| | UC8 | Enrich User Profile | Customer | GET /api/auth/me, PUT /api/auth/profile |
| **Movie** | UC9 | Browse Movie Catalog | Customer, Staff | GET /api/movies, /latest, /trending, /genre/{slug}, ... |
| | UC10 | Advanced Search | Customer, Staff | GET /api/movies/search?q= |
| | UC11 | Watch Movie | Customer | GET /api/movies/{id}/play, /episodes (include UC18) |
| | UC12 | Add to Watchlist | Customer | GET/POST/DELETE /api/customers/{id}/watchlist |
| | UC13 | Rate & Review Movie | Customer | POST /api/movies/{id}/rate, GET /api/movies/{id}/reviews |
| | UC14 | Get AI Recommendations | Customer | (Chưa có) |
| | UC15 | Upload & Manage Content | Staff | POST/PUT/DELETE /api/movies |
| | UC16 | Sync Data with TMDB | Staff | (Chưa có) |
| **Customer** | UC17 | View Subscription Plans | Customer | GET /api/subscriptions/plans |
| | UC18 | Check Membership Status | Customer | GET /api/subscriptions/active/{userId}, /current/{userId} |
| | UC19 | Track Viewing History | Customer | GET/POST /api/customers/{id}/history |
| | UC20 | Manage Membership Rules | Admin | (Config) |
| **Payment** | UC21 | Checkout & Pay | Customer | POST /api/subscriptions/subscribe |
| | UC22 | Receive Payment Webhook | Stripe | POST /api/subscriptions/webhook |
| | UC23 | View Billing History | Customer | GET /api/subscriptions/history/{userId} |
| | UC24 | Request Refund | Customer | POST /api/subscriptions/refund (stub) |
| **Notification** | UC25 | Send Transactional Alert | System | RabbitMQ → Notification Service |
| | UC26 | Send Marketing Push | System/Admin | POST /api/notifications |
| | UC27 | Send Security Alert | System | (Extend UC2_2) |

**Quan hệ:** UC11 include UC18 (xem phim kiểm tra subscription); UC21 extend UC25 (sau thanh toán gửi thông báo).

---

## 4. Architectural Design & Implementation

### 4.1 Architectural Pattern: Microservices + Event-Driven Architecture (EDA)

Nozie kết hợp hai mô hình chính:

- **Microservices:** Mỗi bounded context (Identity, Movie, Customer, Payment, Notification) là một service độc lập, có database riêng (Database-per-Service), triển khai và scale độc lập.
- **Event-Driven (EDA):** Giao tiếp bất đồng bộ qua **RabbitMQ**: Payment Service publish event khi thanh toán/subscription thành công; Customer Service và Notification Service subscribe và xử lý độc lập, không chặn luồng thanh toán.

Giao tiếp đồng bộ (vd: Payment cần kiểm tra Customer/Movie) thực hiện qua **Spring Cloud OpenFeign** và Service Discovery (Eureka).

#### System Context Diagram (C4 Level 1)

- **Hệ thống Nozie** là ranh giới chung; bên trong gồm các microservice và API Gateway.
- **Actor:** Customer (người dùng duyệt phim, đăng ký, thanh toán).
- **Hệ thống ngoài:** Stripe (thanh toán), OAuth (Google/FB), TMDB (metadata phim), CDN (streaming video).
- **Chiến lược giao tiếp:** Đồng bộ (HTTPS/REST qua Gateway), Bất đồng bộ (Event qua RabbitMQ).

*(Tham chiếu: `Documents/Architecture/C4/level-1.md` – PlantUML C4 Context.)*

### 4.2 Technical Stack and Data Model

| Layer | Technology |
|-------|------------|
| **API Gateway** | Spring Cloud Gateway (routing, JWT validation, CORS, Resilience4j) |
| **Service Discovery** | Netflix Eureka |
| **Configuration** | Spring Cloud Config Server |
| **Identity Service** | Spring Boot, PostgreSQL, JWT, Redis (session/blacklist) |
| **Movie Service** | Spring Boot, MongoDB |
| **Customer Service** | Spring Boot, PostgreSQL, RabbitMQ consumer |
| **Payment Service** | Spring Boot, PostgreSQL, Stripe SDK, OpenFeign, RabbitMQ producer |
| **Notification Service** | Spring Boot, MongoDB/Redis, RabbitMQ consumer |
| **Message Broker** | RabbitMQ (Topic/Direct exchange) |
| **Cache / Session** | Redis |
| **Deployment** | Docker, Docker Compose |

**Data Model (tóm tắt):** Mỗi service sở hữu schema riêng: Identity (users, roles), Movie (movies, metadata), Customer (customers, subscriptions), Payment (subscriptions, plans, Stripe IDs), Notification (logs, templates). Không chia sẻ database giữa các service.

### 4.3 Implementation: Infrastructure & Communication

**Service Discovery (Eureka)**  
- Mọi microservice đăng ký với Eureka (defaultZone: 8761). Gateway và Feign client gọi service qua tên (vd: `customer-service`) thay vì IP:port.

**API Gateway Routing**  
- `/api/auth/**` → identity-service  
- `/api/movies/**` → movie-service  
- `/api/customers/**` → customer-service  
- `/api/payments/**` → payment-service  
- `/api/notifications/**` → notification-service  

**Synchronous Communication (OpenFeign)**  
- Payment Service gọi Customer Service và Movie Service để validate customer/movie trước khi tạo checkout session. Lỗi 404 hoặc timeout → trả 400 và không gọi Stripe.

**Asynchronous Communication (RabbitMQ)**  
- Payment Service publish `SubscriptionActivatedEvent` (vd: routing key `subscription.activated`) lên exchange.  
- Customer Service: consumer cập nhật subscription và `stripeCustomerId`.  
- Notification Service: consumer gửi email/xử lý thông báo.  
- Luồng: Request thanh toán trả response ngay; notification xử lý sau trong queue.

*(Chi tiết: `Documents/Architecture/03_Messaging_and_Events.md`, Lab report 4.)*

### 4.4 Implementation: Security & Resilience

- **JWT:** Identity Service cấp token; Gateway dùng `AuthenticationFilter` (hoặc RouteValidator) kiểm tra JWT cho route bảo vệ; route công khai (login, register) không cần token.  
- **Circuit Breaker (Resilience4j):** Áp dụng trên Feign client (vd: Payment → Customer) để tránh cascade failure khi downstream chậm/lỗi.  
- **Rate Limiting:** Có thể triển khai tại Gateway (Redis) cho `/login` và API công khai.

### 4.5 Code Snippets (Minh họa)

**Gateway route (YAML):**
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: payment-service
          uri: lb://payment-service
          predicates:
            - Path=/api/payments/**
```

**Payment Service – Publish event (Java):**
```java
// Sau khi kích hoạt subscription thành công
rabbitTemplate.convertAndSend(
    "payment.exchange",
    "subscription.activated",
    new SubscriptionActivatedEvent(...)
);
```

**Notification Service – Consumer (Java):**
```java
@RabbitListener(queues = "payment.notification.queue")
public void handleSubscriptionActivated(SubscriptionActivatedEvent event) {
    // Gửi email / push notification
}
```

---

## 5. Testing & Verification

### 5.1 Verification Proof: End-to-End Subscription & Notification

| Step | Expected Result | Actual Result | Status |
|------|------------------|---------------|--------|
| 1. Gọi POST tạo Checkout Session (customerId, planId hợp lệ) | 200, trả checkout URL | 200, URL Stripe trả về | Pass |
| 2. Giả lập Stripe webhook `checkout.session.completed` | Payment Service xử lý, publish event, cập nhật DB | Event xuất hiện trên RabbitMQ; subscription activated | Pass |
| 3. Kiểm tra Customer Service | Subscription và stripeCustomerId được cập nhật | DB/log xác nhận cập nhật | Pass |
| 4. Kiểm tra Notification Service | Consumer nhận event, log "Sent" / email | Log consumer nhận event và xử lý | Pass |
| 5. Gọi checkout với customerId không tồn tại (Feign) | 400 Bad Request | Payment Service trả 400 khi Customer Service 404 | Pass |

### 5.2 Verification Proof: API Gateway & JWT

- Gọi `/api/movies` không token (nếu route public) → 200.  
- Gọi `/api/customers/me` không token (route protected) → 401.  
- Gọi với JWT hợp lệ → 200 và request được chuyển tới customer-service.

*(Minh chứng: screenshot Postman/curl, log Gateway và từng service – có thể đính kèm trong báo cáo chính thức.)*

---

## 6. Conclusion & Reflection

Nozie đã triển khai thành công kiến trúc Microservices kết hợp EDA: Gateway, Eureka, Config Server, năm core services (Identity, Movie, Customer, Payment, Notification), RabbitMQ và Redis. Các mục tiêu Scalability, Availability và Modifiability được đáp ứng thông qua tách service, Database-per-Service, và giao tiếp đồng bộ/bất đồng bộ rõ ràng.

### 6.1 Lessons Learned

- **EDA và tách luồng:** Việc tách notification và cập nhật subscription ra khỏi luồng thanh toán giúp API trả về nhanh và ổn định; RabbitMQ đảm bảo message không mất khi consumer tạm thời chậm.  
- **Feign + Eureka:** Gọi service bằng tên và load balancing tích hợp giảm cấu hình thủ công và dễ scale.  
- **Config Server:** Thay đổi cấu hình (timeout, URL) không cần build lại từng service, phù hợp nhiều môi trường (dev/test/prod).

### 6.2 Future Improvements

1. **Observability:** Bật distributed tracing (Zipkin/Micrometer) và metrics (Prometheus/Grafana) cho toàn bộ service.  
2. **Caching:** Redis cache cho Movie catalog và authority (Identity) đã có trong thiết kế; triển khai đầy đủ và invalidation khi data thay đổi.  
3. **Deployment:** Chuẩn hóa Docker Compose cho dev; xem xét Kubernetes cho prod và CI/CD.  
4. **Security:** Rotate secret (JWT, Stripe) qua Config Server hoặc vault; không lưu secret trong repo.

---

*Tài liệu tham chiếu: `Documents/Architecture/`, `Documents/PLAN.md`, `Documents/Labs/ClassN02_Group_03_Lab report_4.md`, Template - Sample Project Report.pdf.*
