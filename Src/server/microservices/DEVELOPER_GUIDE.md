# 🚀 Nozie Microservices - Developer Guide

Tài liệu này hướng dẫn chi tiết cho lập trình viên về kiến trúc, cách cài đặt và quy trình phát triển hệ thống Nozie (Hệ thống đặt vé xem phim Microservices).

---

## 🏗️ 1. Kiến trúc hệ thống (System Architecture)

Hệ thống được thiết kế theo kiến trúc Microservices với các thành phần chính:

- **API Gateway (Port 8080):** Cửa ngõ duy nhất, xử lý Routing, JWT Validation và Rate Limiting.
- **Discovery Server (Eureka - Port 8761):** Quản lý định danh và trạng thái của các service.
- **Config Server (Port 8888):** Quản lý cấu hình tập trung cho tất cả các service.
- **Business Services:**
  - `identity-service` (Port 8085): Quản lý người dùng, phân quyền (Auth).
  - `movie-service` (Port 8081): Quản lý phim, lịch chiếu, rạp.
  - `customer-service` (Port 8082): Quản lý thông tin khách hàng.
  - `payment-service` (Port 8083): Xử lý thanh toán.
  - `notification-service` (Port 8084): Gửi thông báo (Email, Push).

---

## 🛠️ 2. Tech Stack

- **Backend:** Java 17, Spring Boot 3, Spring Cloud (Gateway, Eureka, Config, Feign).
- **Database:** PostgreSQL (Relation), MongoDB (NoSQL), Redis (Caching).
- **Messaging:** RabbitMQ (Async communication).
- **Observability:** Prometheus, Grafana, Loki (Logging), Zipkin (Tracing).
- **Client:** Flutter (Mobile/Web).

---

## 🚀 3. Hướng dẫn cài đặt & Khởi chạy

### Bước 1: Khởi tạo Infrastructure (Docker)
Chạy các dịch vụ bổ trợ (Database, RabbitMQ, Monitoring):
```bash
cd Src/server/microservices
docker compose up -d
```

### Bước 2: Khởi chạy Microservices
Sử dụng script `run.sh` để bắt đầu theo đúng thứ tự (Config -> Discovery -> Gateway -> Services):
```bash
chmod +x run.sh
./run.sh start
```
*Lưu ý: Đợi khoảng 30-60 giây để hệ thống ổn định.*

### Bước 3: Kiểm tra trạng thái
- **Eureka Dashboard:** [http://localhost:8761](http://localhost:8761)
- **API Gateway:** [http://localhost:8080](http://localhost:8080)
- **Zipkin (Tracing):** [http://localhost:9411](http://localhost:9411)
- **Grafana (Monitoring):** [http://localhost:3000](http://localhost:3000) (User/Pass: `admin/admin`)

---

## 📊 4. Quy trình phát triển Service mới

Khi bạn muốn tạo một Microservice mới (ví dụ: `review-service`):

1. **Tạo module Maven:** Thêm module vào `pom.xml` gốc.
2. **Cấu hình Eureka Client:** Thêm dependency `spring-cloud-starter-netflix-eureka-client`.
3. **Đăng ký với Gateway:** Cấu hình route trong `api-gateway.yml` trên Config Server.
4. **Cấu hình Circuit Breaker:** Định nghĩa instance trong `application.yml` của Gateway để đảm bảo tính chịu lỗi.
5. **Database:** Cập nhật `docker-compose.yml` nếu cần thêm DB mới.

---

## 🔍 5. Cách Debug & Khắc phục lỗi

### Xem Log
- Truy cập vào folder `logs/` để xem file log riêng của từng service.
- Sử dụng **Grafana Loki** để truy vấn log tập trung theo `traceId`.

### Tracing (Truy vết lỗi)
Khi một Request từ App gọi qua Gateway -> Identity -> Movie mà bị lỗi:
1. Lấy `traceId` từ Header của Response hoặc Log.
2. Dán vào **Zipkin UI** để xem Request bị chậm hoặc chết ở Service nào.

### Lỗi phổ biến
- **Service không hiện trên Eureka:** Kiểm tra mạng (Docker Network) và đảm bảo `discovery-server` đã chạy xong trước khi Start service đó.
- **Lỗi 401 Unauthorized:** Kiểm tra JWT Secret trong `api-gateway.yml` và `identity-service` phải giống hệt nhau.

---

## 📜 6. Quy tắc Code (Coding Standards)
- **Naming:** CamelCase cho Java, kebab-case cho URL API.
- **DTOs:** Luôn dùng DTO để trao đổi dữ liệu, không trả về trực tiếp Entity.
- **Exception Handling:** Sử dụng `@ControllerAdvice` để trả về lỗi định dạng chuẩn JSON.

---
*Tài liệu này được cập nhật lần cuối vào: 2026-01-26*
