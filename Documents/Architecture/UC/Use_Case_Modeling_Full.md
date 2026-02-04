# Use Case Modeling đầy đủ – Nozie Streaming Platform

*Tài liệu ánh xạ toàn bộ Use Case (27 UC) từ biểu đồ UC sang luồng nghiệp vụ, API và trạng thái triển khai.*

---

## 1. Tổng quan Actor & Package

| Actor | Mô tả |
|-------|--------|
| **Customer** | Người dùng cuối: đăng ký, đăng nhập, xem phim, mua gói, nhận thông báo. |
| **Content Manager (Staff)** | Quản lý nội dung: upload/cập nhật phim, đồng bộ TMDB. |
| **System Admin** | Quản trị hệ thống: phân quyền, audit log, quy tắc membership. |
| **External** | Stripe, OAuth (Google/FB), CDN, TMDB, FCM/Email Server. |

---

## 2. Bảng Use Case đầy đủ (27 UC)

### 2.1 Identity Service (UC1–UC8)

| ID | Use Case | Actor | Luồng chính (Flow) | API / Implementation | Trạng thái |
|----|----------|--------|---------------------|------------------------|------------|
| UC1 | Register | Customer | 1. User gửi username, email, password. 2. Identity Service validate, hash password, tạo User. 3. (Tùy chọn) publish UserRegisteredEvent. 4. Trả UserResponse (có thể kèm JWT). | POST /api/auth/register | ✅ Đã có |
| UC2 | Login via Credentials | Customer | 1. User gửi username + password. 2. Validate, tạo session, sinh Access + Refresh token. 3. Trả AuthResponse (tokens, user). | POST /api/auth/login | ✅ Đã có |
| UC2_1 | Social Auth Login | Customer, OAuth | 1. Client gửi provider (google/fb) + token. 2. Validate token với OAuth provider. 3. Tạo hoặc link User, trả JWT. | POST /api/auth/social-login | 🔶 Stub (TODO) |
| UC2_2 | Two-Factor Auth | Customer | 1. Sau login, yêu cầu OTP. 2. User nhập OTP. 3. Verify và hoàn tất login. | (Mở rộng login / 2FA endpoint) | 🔶 Chưa có |
| UC3 | Logout & Revoke Token | Customer | 1. User gửi refresh token (và access token). 2. Blacklist access token, invalidate refresh. 3. Trả success. | POST /api/auth/logout, DELETE /api/auth/sessions/{id} | ✅ Đã có |
| UC4 | Change Password | Customer | 1. User đã đăng nhập gửi oldPassword + newPassword. 2. Verify old, hash new, lưu. 3. (Tùy chọn) invalidate other sessions. | POST /api/auth/change-password | ✅ Đã có |
| UC5 | Manage User Sessions | Customer | 1. User xem danh sách session (device, IP, last access). 2. User có thể revoke từng session. | GET /api/auth/sessions, DELETE /api/auth/sessions/{sessionId} | ✅ Đã có |
| UC6 | Assign Roles/Permissions | System Admin | 1. Admin xem/sửa roles và permissions. 2. Gán role cho user. | GET/POST/PUT/DELETE /api/admin/roles, /api/admin/users/{id}/roles, /api/admin/permissions | ✅ Đã có |
| UC7 | View System Audit Logs | System Admin | 1. Admin xem audit log (login, thay đổi quyền, v.v.). | GET /api/admin/audit-logs, GET /api/admin/audit-logs/user/{userId} | ✅ Đã có |
| UC8 | Enrich User Profile | Customer | 1. User xem/sửa profile (tên, avatar, v.v.). | GET /api/auth/me, PUT /api/auth/profile | ✅ Đã có |

---

### 2.2 Movie Service (UC9–UC16)

| ID | Use Case | Actor | Luồng chính (Flow) | API / Implementation | Trạng thái |
|----|----------|--------|---------------------|------------------------|------------|
| UC9 | Browse Movie Catalog | Customer, Staff | 1. User/Staff gọi API danh sách phim. 2. Filter theo type, genre, country, year, keyword. 3. Trả phân trang. | GET /api/movies, GET /api/movies/latest, /trending, /free, /type/{type}, /genre/{slug}, /country/{slug}, /year/{year} | ✅ Đã có |
| UC10 | Advanced Search | Customer, Staff | 1. User nhập từ khóa. 2. Search theo title/description. 3. Trả kết quả phân trang. | GET /api/movies/search?q= | ✅ Đã có |
| UC11 | Watch Movie | Customer | 1. User chọn phim. 2. (Include: kiểm tra subscription UC18.) 3. Lấy URL phát (CDN/HLS). 4. Client stream từ CDN. | GET /api/movies/{id}/play, GET /api/movies/slug/{slug}/play, GET /api/movies/{id}/episodes | ✅ Đã có |
| UC12 | Add to Watchlist | Customer | 1. User đăng nhập thêm phim vào watchlist. 2. Lưu (customerId, movieId). | GET /api/customers/{id}/watchlist, POST /api/customers/{id}/watchlist, DELETE /api/customers/{id}/watchlist/{movieId} | ✅ Đã có |
| UC13 | Rate & Review Movie | Customer | 1. User gửi điểm (1–10) và/hoặc comment. 2. Lưu rating/review cho movieId + userId. | POST /api/movies/{id}/rate, GET /api/movies/{id}/reviews | ✅ Đã có |
| UC14 | Get AI Recommendations | Customer | 1. Hệ thống gợi ý phim theo lịch sử/thể loại. | GET /api/movies/recommendations (hoặc tương đương) | 🔶 Chưa có |
| UC15 | Upload & Manage Content | Staff, Admin | 1. Staff tạo/sửa/xóa phim. 2. Upload metadata (poster, mô tả). | POST/PUT/DELETE /api/movies, GET /api/movies/{id} | ✅ Đã có |
| UC16 | Sync Data with TMDB | Staff | 1. Staff kích hoạt sync. 2. Service gọi TMDB API, cập nhật/insert movie. | (Internal job hoặc POST /api/admin/movies/sync) | 🔶 Chưa có |

---

### 2.3 Customer Service (UC17–UC20)

| ID | Use Case | Actor | Luồng chính (Flow) | API / Implementation | Trạng thái |
|----|----------|--------|---------------------|------------------------|------------|
| UC17 | View Subscription Plans | Customer | 1. User xem danh sách gói (tên, giá, mô tả). | GET /api/subscriptions/plans | ✅ Đã có (Payment) |
| UC18 | Check Membership Status | Customer, System | 1. Kiểm tra user có subscription đang active không. 2. Dùng khi xem phim (UC11 include). | GET /api/subscriptions/active/{userId}, GET /api/subscriptions/current/{userId} | ✅ Đã có |
| UC19 | Track Viewing History | Customer | 1. Khi user xem phim, ghi lại (userId, movieId, watchedAt). 2. User xem lịch sử. | GET /api/customers/{id}/history, POST /api/customers/{id}/history | ✅ Đã có |
| UC20 | Manage Membership Rules | System Admin | 1. Admin cấu hình quy tắc gói (thời hạn, quyền xem). | (Config hoặc Admin API) | 🔶 Chưa có |

---

### 2.4 Payment & Billing (UC21–UC24)

| ID | Use Case | Actor | Luồng chính (Flow) | API / Implementation | Trạng thái |
|----|----------|--------|---------------------|------------------------|------------|
| UC21 | Checkout & Pay | Customer | 1. User chọn gói, gọi API tạo Checkout Session. 2. Payment Service tạo session Stripe, trả URL. 3. User redirect đến Stripe, thanh toán. | POST /api/subscriptions/subscribe | ✅ Đã có |
| UC22 | Receive Payment Webhook | Stripe → System | 1. Stripe gửi checkout.session.completed (và events khác). 2. Payment Service verify signature, cập nhật subscription, publish event. | POST /api/subscriptions/webhook | ✅ Đã có |
| UC23 | View Billing History | Customer | 1. User xem lịch sử subscription/thanh toán. | GET /api/subscriptions/history/{userId} | ✅ Đã có |
| UC24 | Request Refund | Customer | 1. User gửi yêu cầu hoàn tiền. 2. (Thủ công hoặc tích hợp Stripe Refund API.) | POST /api/subscriptions/refund hoặc /api/payments/refund | 🔶 Chưa có |

---

### 2.5 Notification (UC25–UC27)

| ID | Use Case | Actor | Luồng chính (Flow) | API / Implementation | Trạng thái |
|----|----------|--------|---------------------|------------------------|------------|
| UC25 | Send Transactional Alert | System | 1. Sau event (thanh toán, đăng ký), Payment/Identity publish event. 2. Notification Service consume, gửi email/push (FCM/Email Server). | RabbitMQ consumer; POST (internal) tạo notification | ✅ Đã có (event-driven) |
| UC26 | Send Marketing Push | System / Admin | 1. Admin hoặc job gửi campaign tới segment user. | POST /api/notifications (broadcast) hoặc job | 🔶 Một phần (tạo notification có) |
| UC27 | Send Security Alert | System | 1. Khi có sự kiện bảo mật (vd: 2FA fail), gửi alert. 2. (Extend UC2_2: Failed 2FA alert.) | Event → Notification Service → email/push | 🔶 Chưa có |

---

## 3. Quan hệ Include / Extend (theo diagram)

| Quan hệ | Mô tả |
|---------|--------|
| UC11 **include** UC18 | Xem phim (Watch Movie) luôn bao gồm kiểm tra membership (Check subscription). |
| UC21 **extend** UC25 | Sau thanh toán thành công có thể mở rộng gửi thông báo (Notify on success). |
| UC27 **extend** UC2_2 | Cảnh báo bảo mật có thể mở rộng từ kịch bản 2FA thất bại. |

---

## 4. Ánh xạ API theo Service

| Service | Base path | Use Case phục vụ |
|---------|-----------|-------------------|
| Identity | /api/auth, /api/admin | UC1–UC8, UC6, UC7 |
| Movie | /api/movies, /api/genres, /api/countries, /api/years | UC9–UC16 |
| Customer | /api/customers | UC12 (watchlist), UC19 (history), hỗ trợ profile |
| Payment | /api/subscriptions | UC17, UC18, UC21–UC24 |
| Notification | /api/notifications | UC25–UC27 (consume event + REST đọc/thao tác thông báo) |

---

## 5. Trạng thái triển khai tóm tắt

| Trạng thái | Số lượng | Ghi chú |
|------------|----------|--------|
| ✅ Đã có | 21 | API và/hoặc event đã triển khai (gồm UC12, UC13, UC19). |
| 🔶 Stub / Một phần | 4 | UC2_1 (Social login), UC2_2 (2FA), UC26 (Marketing push), UC27 (Security alert). |
| 🔶 Chưa có | 2 | UC14 (AI Recommendations), UC16 (TMDB Sync) – có thể bổ sung sau. |

---

*Tham chiếu: `uc.md` (PlantUML), `02_Data_Architecture.md`, các controller trong từng microservice.*
