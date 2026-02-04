# 📋 Chia việc chi tiết 8 Lab cho Nozie (Requirements → Deployment & ATAM)

*Áp dụng chuỗi 8 bài thực hành Kiến trúc Phần mềm vào dự án **Nozie** (nền tảng đặt vé / streaming phim), với phân công rõ ràng cho **Nhật (Lead) – Việt – Minh – Nhất**.*

---

## Bảng ánh xạ Lab ↔ Tuần & Trách nhiệm

| Tuần | Lab | Tên Lab (theo đề cương) | Người thực hiện (Code/Thiết kế) | Người viết báo cáo |
|------|-----|--------------------------|-----------------------------------|---------------------|
| **W1** | Lab 1 | Khơi gợi & Mô hình hóa Yêu cầu | **Việt** | **Minh** |
| **W2** | Lab 2 | Thiết kế Kiến trúc Phân lớp (View Logic) | **Việt** | **Minh** |
| **W3** | Lab 3 | Triển khai Kiến trúc Phân lớp (CRUD) | **Việt** | **Nhất** |
| **W4** | Lab 4 | Phân rã Microservices & Giao tiếp | **Nhật** | **Nhất** |
| **W5** | Lab 5 | Triển khai Movie Microservice | **Việt** | **Việt** |
| **W6** | Lab 6 | API Gateway Pattern | **Nhật** | **Minh** |
| **W7** | Lab 7 | Kiến trúc Hướng sự kiện (EDA) | **Nhật** | **Nhất** |
| **W8** | Lab 8 | Deployment View & ATAM | **Nhật** | **Nhật** |

---

## Lab 1: Khơi gợi & Mô hình hóa Yêu cầu (Requirements Elicitation & Modeling)

**Mục tiêu:** Xác định và tài liệu hóa ASRs, FRs, NFRs; mô hình hóa phạm vi và hành vi bên ngoài của hệ thống Nozie.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 1.1 | Xác định Actor & Use Case | **Actors:** Khách hàng (Customer), Quản lý nội dung (Content Manager), Admin hệ thống. **Use Case:** Đăng ký, Đăng nhập (credentials + OAuth), Xem danh mục phim, Tìm kiếm phim, Xem phim (có kiểm tra subscription), Thanh toán/Subscribe, Xem lịch sử thanh toán, Nhận thông báo (email/push), Quản lý phân quyền, v.v. (tham chiếu `Documents/Architecture/UC/uc.md`). | **Việt** | Danh sách Actor + Use Case (bảng/Excel). |
| 1.2 | Biểu đồ UML Use Case | Vẽ Use Case diagram: hệ thống Nozie, các actor, use case theo từng package (Identity, Movie, Customer, Payment, Notification); quan hệ **include** (vd: Xem phim include Kiểm tra subscription), **extend** (vd: Thanh toán thành công extend Gửi thông báo). | **Việt** (nội dung) + **Minh** (chỉnh sửa diagram/format) | File PlantUML hoặc hình ảnh Use Case diagram. |
| 1.3 | Thẻ ASR (ASR Card) | Lập ít nhất 3–5 thẻ ASR: mỗi thẻ giải thích **một yêu cầu có ý nghĩa kiến trúc** (vd: “Hệ thống phải scale theo tải đăng nhập ngày lễ” → ảnh hưởng quyết định tách Identity Service; “Thanh toán không được chặn bởi gửi email” → ảnh hưởng chọn EDA). | **Việt** | Tài liệu ASR Cards (markdown/Word). |
| 1.4 | Tổng hợp FRs & NFRs | Liệt kê FRs (chức năng đăng ký, xem phim, thanh toán, v.v.) và NFRs (bảo mật, khả năng mở rộng, độ trễ chấp nhận được). | **Việt** | Bảng FR/NFR. |
| 1.5 | Viết báo cáo Lab 1 | Mô tả quy trình khơi gợi, kết quả Actor/Use Case, diagram, ASR, FR/NFR; định dạng chuẩn, chất lượng văn bản. | **Minh** | Báo cáo Lab 1 (file nộp). |

**Đầu vào cho Minh:** Việt gửi danh sách Actor/UC, file diagram, ASR Cards, bảng FR/NFR.

---

## Lab 2: Thiết kế Kiến trúc Phân lớp – View Logic (Layered Architecture Design)

**Mục tiêu:** Định nghĩa 4 lớp (Presentation, Business Logic, Persistence, Data) và trách nhiệm; tuân thủ quy tắc “một lớp chỉ tương tác với lớp ngay bên dưới”.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 2.1 | Định nghĩa 4 lớp | **Presentation:** Controller (REST API). **Business Logic:** Service (nghiệp vụ). **Persistence:** Repository (truy cập dữ liệu). **Data:** PostgreSQL/MongoDB. Áp dụng cho **một** bounded context, ví dụ **Movie Catalog** (hoặc Identity/Customer tùy chọn). | **Việt** | Mô tả ngắn từng lớp + quy tắc phụ thuộc. |
| 2.2 | Xác định component cụ thể | Cho tính năng **Movie Catalog:** MovieController (API), MovieService (logic nghiệp vụ), MovieRepository (truy vấn DB). Liệt kê interface “cung cấp” và “yêu cầu” của từng component. | **Việt** | Bảng component + interface. |
| 2.3 | Biểu đồ Component (UML) | Vẽ Component Diagram: MovieController → MovieService → MovieRepository → Database; thể hiện luồng phụ thuộc (chỉ xuống lớp dưới). | **Việt** (nội dung) + **Minh** (chỉnh diagram/format) | File diagram (PlantUML/draw.io). |
| 2.4 | Viết báo cáo Lab 2 | Giải thích lựa chọn phân lớp, trách nhiệm từng lớp, component diagram, quy tắc kiến trúc. | **Minh** | Báo cáo Lab 2. |

**Đầu vào cho Minh:** Việt gửi mô tả 4 lớp, bảng component, file Component Diagram.

---

## Lab 3: Triển khai Kiến trúc Phân lớp (CRUD Implementation)

**Mục tiêu:** Code thực tế tính năng theo thiết kế Lab 2; đảm bảo luồng Controller → Service → Repository.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 3.1 | Cấu trúc dự án phân lớp | Trong **movie-service** (hoặc module tương ứng): tách rõ package/class theo Presentation (controller), Application/Domain (service), Infrastructure (repository). | **Việt** | Cấu trúc thư mục + package. |
| 3.2 | Implement Persistence | MovieRepository: CRUD (Create, Read, Update, Delete) với JPA/MongoDB. Có thể dùng in-memory hoặc DB thật tùy giai đoạn. | **Việt** | Code Repository. |
| 3.3 | Implement Business Logic | MovieService: gọi Repository, áp dụng rule nghiệp vụ (vd: validate dữ liệu trước khi lưu). | **Việt** | Code Service. |
| 3.4 | Implement Presentation | Controller (REST): endpoints GET/POST/PUT/DELETE; chỉ gọi Service, không gọi trực tiếp Repository. | **Việt** | Code Controller. |
| 3.5 | Minh chứng luồng | Đảm bảo: Request → Controller → Service → Repository → DB. Ghi lại bằng log hoặc diagram luồng. | **Việt** | Screenshot/log hoặc sơ đồ. |
| 3.6 | Viết báo cáo Lab 3 | Mô tả cấu trúc, code từng lớp, minh chứng luồng, công nghệ (Java/Spring Boot). | **Nhất** | Báo cáo Lab 3. |

**Đầu vào cho Nhất:** Việt gửi link repo/commit, screenshot log, mô tả ngắn cấu trúc và luồng.

---

## Lab 4: Phân rã Microservices & Giao tiếp (Microservices Decomposition)

**Mục tiêu:** Chuyển từ Monolith (Lab 3) sang Microservices: xác định ranh giới dịch vụ theo Năng lực Kinh doanh, định nghĩa Service Contracts, mô hình C4 Level 1.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 4.1 | Xác định microservice | **Nozie:** Identity Service, Movie Service, Customer Service, Payment Service, Notification Service. Giải thích ngắn từng service tương ứng Business Capability nào. | **Nhật** | Bảng danh sách service + lý do. |
| 4.2 | Hợp đồng dịch vụ (Service Contracts) | Định nghĩa API Endpoints chính: VD Identity (`POST /auth/register`, `POST /auth/login`), Movie (`GET /movies`, `GET /movies/{id}`), Customer (`GET /customers/{id}`), Payment (`POST /payments/checkout`), Notification (chỉ nhận event, không REST công khai). | **Nhật** | Tài liệu API/OpenAPI hoặc bảng endpoint. |
| 4.3 | C4 Level 1 – System Context | Vẽ C4 Context: Hệ thống Nozie ở giữa; Actor (Khách hàng, Admin); Hệ thống ngoài (Stripe, OAuth, CDN, Email/Push). Thể hiện chiến lược giao tiếp: **đồng bộ** (REST qua Gateway) vs **bất đồng bộ** (Event qua Message Broker). | **Nhật** (nội dung) + **Nhất** (vẽ/chỉnh C4 diagram) | Diagram C4 Level 1. |
| 4.4 | Viết báo cáo Lab 4 | Mô tả phân rã, bản đồ hệ thống, hợp đồng dịch vụ, đồng bộ vs bất đồng bộ. | **Nhất** | Báo cáo Lab 4. |

**Đầu vào cho Nhất:** Nhật gửi danh sách service, tài liệu API, bản nháp C4 hoặc mô tả để Nhất vẽ.

---

## Lab 5: Triển khai Movie Microservice (tương đương Product Microservice)

**Mục tiêu:** Một dịch vụ cốt lõi hoạt động độc lập: sở hữu DB riêng, cung cấp REST API, kiểm thử cô lập.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 5.1 | Database per Service | Movie Service có DB riêng (MongoDB hoặc PostgreSQL tùy thiết kế Nozie). Không truy cập DB của Identity/Customer/Payment. | **Việt** | Cấu hình DB + schema/collection. |
| 5.2 | REST API độc lập | Endpoints: tìm kiếm phim, lấy chi tiết phim (theo id/slug). Implement đầy đủ trong movie-service. | **Việt** | Code + API docs. |
| 5.3 | Kiểm thử cô lập (Isolation Testing) | Gọi trực tiếp movie-service (bypass Gateway) bằng cURL/Postman: kiểm tra API hoạt động khi chạy một mình. | **Việt** | Screenshot/collection Postman hoặc script cURL. |
| 5.4 | Viết báo cáo Lab 5 | Mô tả nguyên tắc Database per Service, API, kết quả kiểm thử cô lập. | **Việt** | Báo cáo Lab 5. |

---

## Lab 6: API Gateway Pattern

**Mục tiêu:** Điểm vào duy nhất (single-entry point): định tuyến và xử lý cross-cutting (bảo mật).

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 6.1 | Gateway làm reverse proxy | Spring Cloud Gateway (hoặc Flask nếu mô phỏng giống bài mẫu): nhận request từ client, chuyển tiếp tới backend (movie-service, identity-service, customer-service, payment-service, notification-service). | **Nhật** | Code Gateway + cấu hình route. |
| 6.2 | Định tuyến (Routing) | Route theo path: `/api/movies/**` → movie-service, `/api/auth/**` → identity-service, `/api/customers/**` → customer-service, `/api/payments/**` → payment-service, `/api/notifications/**` → notification-service. | **Nhật** | Cấu hình routing (YAML/code). |
| 6.3 | Security Stub (kiểm tra token) | Trước khi cho phép truy cập: xác thực JWT (hoặc token stub). Route công khai (vd login/register) không cần token; route còn lại phải có token hợp lệ. | **Nhật** | Filter/Validator + minh chứng (screenshot 401 khi thiếu token). |
| 6.4 | Viết báo cáo Lab 6 | Vai trò Gateway, routing, cơ chế bảo mật, minh chứng. | **Minh** | Báo cáo Lab 6. |

**Đầu vào cho Minh:** Nhật gửi cấu hình route, mô tả security stub, screenshot test (có token / không token).

---

## Lab 7: Kiến trúc Hướng sự kiện (Event-Driven Architecture – EDA)

**Mục tiêu:** Tách rời Order/Payment và Notification bằng Message Broker; chứng minh Order/Payment không bị chặn bởi gửi email.

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 7.1 | Producer (Payment/Order) | Sau khi tạo đơn/thanh toán thành công: **Payment Service** gửi sự kiện (vd `PaymentSucceededEvent` hoặc `OrderPlaced`) vào hàng đợi RabbitMQ. Dùng Topic/Direct exchange, routing key rõ ràng. | **Nhật** | Code publish event + cấu hình exchange/queue. |
| 7.2 | Consumer (Notification) | **Notification Service** lắng nghe queue: nhận event → xử lý gửi email xác nhận (hoặc log/stub gửi email). | **Nhật** | Code consumer + cấu hình queue binding. |
| 7.3 | Chứng minh decoupling | Minh chứng: (1) Gọi API thanh toán → trả response nhanh; (2) Email/notification xử lý sau (log hoặc email thật). So sánh thời gian response khi bật/tắt consumer hoặc làm chậm gửi email. | **Nhật** | Screenshot/log so sánh, đo thời gian response. |
| 7.4 | Viết báo cáo Lab 7 | Mô tả luồng EDA, Producer/Consumer, RabbitMQ, minh chứng độc lập (Order/Payment không block). | **Nhất** | Báo cáo Lab 7. |

**Đầu vào cho Nhất:** Nhật gửi sơ đồ luồng, code snippet publish/consume, screenshot log và so sánh thời gian.

---

## Lab 8: Deployment View & Phân tích Thuộc tính Chất lượng (ATAM)

**Mục tiêu:** Tài liệu hóa kiến trúc triển khai vật lý; đánh giá trade-off Monolith vs Microservices (ATAM giản lược).

### Công việc chi tiết cho Nozie

| # | Hoạt động | Nội dung cụ thể Nozie | Người làm | Deliverable |
|---|-----------|------------------------|-----------|-------------|
| 8.1 | Biểu đồ Deployment (UML) | Mô hình hóa: **Node** (Load Balancer, Server/Cluster, Client); **Artifact** (API Gateway, từng Microservice, DB, RabbitMQ, Redis). Thể hiện phân bố component lên node (vd Docker container trên một hoặc nhiều host). | **Nhật** | Deployment Diagram (PlantUML/draw.io). |
| 8.2 | Phân tích ATAM – Kịch bản | Chọn 2 kịch bản: (1) **Scalability** – VD “Black Friday / tải cao”: so sánh Monolith vs Microservices (scale từng service, scale ngang). (2) **Availability** – VD “Một service lỗi”: so sánh ảnh hưởng (cascade failure vs cô lập lỗi). | **Nhật** | Bảng/đoạn văn phân tích từng kịch bản. |
| 8.3 | Kết luận trade-off | Microservices vượt trội về mở rộng và cô lập lỗi nhưng phức tạp hơn vận hành; khi nào nên chọn Monolith vs Microservices. | **Nhật** | Đoạn kết luận. |
| 8.4 | Viết báo cáo Lab 8 | Deployment diagram, mô tả môi trường triển khai, ATAM (kịch bản + phân tích + kết luận). | **Nhật** | Báo cáo Lab 8. |

---

## Tóm tắt phân công theo thành viên

| Thành viên | Công việc thực hiện (Code/Thiết kế) | Công việc báo cáo |
|------------|-------------------------------------|-------------------|
| **Nhật (Lead)** | Lab 4 (Phân rã MS + C4), Lab 6 (Gateway), Lab 7 (EDA), Lab 8 (Deployment + ATAM). Giám sát kỹ thuật toàn bộ. | **Lab 8.** Hỗ trợ minh chứng cho Lab 4, 6, 7. |
| **Việt** | Lab 1 (Actor, UC, ASR, FR/NFR), Lab 2 (Phân lớp + Component), Lab 3 (CRUD layered), Lab 5 (Movie Microservice). | **Lab 5.** Cung cấp tài liệu/input cho Lab 1, 2, 3 (Minh/Nhất). |
| **Minh** | Hỗ trợ chỉnh diagram/format (Lab 1, 2); thu thập tài liệu từ Nhật (Lab 6). | **Lab 1, Lab 2, Lab 6.** |
| **Nhất** | Hỗ trợ vẽ C4 (Lab 4); thu thập minh chứng từ Việt (Lab 3), Nhật (Lab 4, 7). | **Lab 3, Lab 4, Lab 7.** |

---

## Quy trình phối hợp (nhắc lại)

- **Người làm code/thiết kế** hoàn thành từng bước → gửi **deliverable** (file, link, screenshot, log) cho **người viết báo cáo** tương ứng.
- **Hạn báo cáo:** Report Lab tuần N hoàn thành **Thứ 7** tuần đó để **Nhật** duyệt.
- **Tài liệu tham chiếu Nozie:** `Documents/Architecture/`, `Documents/Architecture/UC/uc.md`, `PLAN.md`.

---
*Cập nhật theo nội dung 8 Lab: Requirements Elicitation → Layered Design → CRUD → Microservices Decomposition → Movie MS → API Gateway → EDA → Deployment & ATAM.*
