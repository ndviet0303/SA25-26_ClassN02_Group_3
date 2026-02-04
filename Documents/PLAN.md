# 📅 Project Plan: Nozie Microservices (10-Week Roadmap)

Dự án phát triển hệ thống microservices đặt vé xem phim **Nozie**. 
Kế hoạch tuân thủ quy tắc: **Phân công nhiệm vụ kỹ thuật đi kèm với trách nhiệm viết báo cáo tương ứng.**

---

## 👥 Đội ngũ & Phân vai (Team Roles)

| Thành viên | Trách nhiệm Kỹ thuật (Code) | Trách nhiệm Báo cáo (Report) |
| :--- | :--- | :--- |
| **Nhật (Leader)** | Hệ thống lõi, Infrastructure (W2), Messaging (W3), Resilience (W4), Observability (W6), Deployment (W7), Mobile App (W9). | **Báo cáo W6, W7**. Chốt báo cáo tổng kết W10. Giám sát kỹ thuật toàn bộ các Lab. |
| **Việt (Dev)** | Phân rã Domain (W1), Caching (W5), Optimization & Refactor (W8), Mobile App (W9), Integration (W10). | **Báo cáo W5, W8**. Cung cấp tài liệu kỹ thuật Domain cho Lab 1. |
| **Minh (Writer)** | Hỗ trợ thu thập tài liệu, sơ đồ từ Nhật/Việt. | **Báo cáo W1, W2, W9 (phần UI)**. Định dạng và kiểm soát chất lượng văn bản. |
| **Nhất (Writer)** | Hỗ trợ thu thập tài liệu, sơ đồ từ Nhật/Việt. | **Báo cáo W3, W4, W9 (phần logic App)**. Quản lý minh chứng (screenshots/logs). |

---

## 🗓️ Lộ trình chi tiết 10 tuần (Detailed Roadmap)

### Giai đoạn 1: Xây dựng nền tảng (Microservices Foundation)

| Tuần | Nội dung | Thực hiện Code | Thực hiện Report | Trọng tâm báo cáo |
| :--- | :--- | :--- | :--- | :--- |
| **W1** | **Lab 1: Domain Analysis** | **Việt** | **Minh** | Phân rã Domain, Entity, Use Case. |
| **W2** | **Lab 2: Infrastructure** | **Nhật** | **Minh** | Setup Gateway, Eureka, Config Server. |
| **W3** | **Lab 3: Messaging** | **Nhật** | **Nhất** | Triển khai RabbitMQ Logic & luồng Event. |
| **W4** | **Lab 4: Resilience** | **Nhật** | **Nhất** | Circuit Breaker & Fault Tolerance. |

### Giai đoạn 2: Tối ưu & Vận hành (Ops & Optimization)

| Tuần | Nội dung | Thực hiện Code | Thực hiện Report | Trọng tâm báo cáo |
| :--- | :--- | :--- | :--- | :--- |
| **W5** | **Lab 5: Caching** | **Việt** | **Việt** | Redis Caching cho Domain. |
| **W6** | **Lab 6: Observability** | **Nhật** | **Nhật** | Zipkin Tracing & Grafana Monitoring. |
| **W7** | **Lab 7: Deployment** | **Nhật** | **Nhật** | Dockerization & Deployment Guide. |
| **W8** | **Lab 8: Optimization** | **Việt** | **Việt** | Tối ưu DB Index & System Refactor. |

### Giai đoạn 3: Mở rộng & Hoàn thiện (App & Integration)

| Tuần | Nội dung | Thực hiện Code | Thực hiện Report | Trọng tâm báo cáo |
| :--- | :--- | :--- | :--- | :--- |
| **W9** | **Mobile App Dev** | **Nhật & Việt** | **Nhất & Minh** | Phát triển Flutter App & kết nối API. |
| **W10** | **Full Integration** | **Việt & Nhật** | **Cả nhóm** | Kết nối E2E & Video Demo. |

---

## 📄 Danh sách Báo cáo theo thành viên (Report Assignment)

### 1. Nhật (Leader)
- **Report Lab 06**: Giám sát hệ thống (Observability).
- **Report Lab 07**: Triển khai hệ thống (Deployment).
- **Báo cáo tổng kết**: Kết nối toàn diện và đánh giá dự án.

### 2. Việt
- **Report Lab 05**: Triển khai Caching.
- **Report Lab 08**: Tối ưu hóa hệ thống.
- **Tài liệu Domain**: Cung cấp cấu trúc database và logic nghiệp vụ cho Lab 01.

### 3. Minh
- **Report Lab 01**: Phân tích hệ thống và thiết kế Domain.
- **Report Lab 02**: Thiết lập hạ tầng microservices.
- **Report Mobile (A)**: Mô tả thiết kế giao diện (UI) và trải nghiệm người dùng trên App.

### 4. Nhất
- **Report Lab 03**: Cơ chế truyền tin bất đồng bộ (RabbitMQ).
- **Report Lab 04**: Các giải pháp chịu lỗi (Resilience).
- **Report Mobile (B)**: Mô tả logic kết nối API và quản lý trạng thái trên App.

---

## 🛠️ Quy trình phối hợp
- **Code xong -> Cung cấp minh chứng**: Nhật và Việt sau khi code xong phải bắt buộc gửi Screenshots/Logs cho Minh và Nhất (đối với các Lab không tự viết report).
- **Hạn chót**: Report Lab tuần (N) phải hoàn thành vào Thứ 7 của tuần đó để Nhật duyệt.

---
*Cập nhật lần cuối: 2026-02-04 bởi Nhật (Leader).*
