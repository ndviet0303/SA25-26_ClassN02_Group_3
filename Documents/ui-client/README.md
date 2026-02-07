# Ảnh chụp màn hình UI (Flutter client)

Các ảnh đã được đặt tên theo nội dung màn hình.

## Đã có ảnh (16)

| File | Màn hình | Route |
|------|----------|--------|
| `01_home.png` | Trang chủ | `/home` |
| `02_discover.png` | Khám phá | `/discover` |
| `03_premium_subscription.png` | Gói Premium / Subscription | `/subscription` |
| `04_profile.png` | Cá nhân | `/profile` |
| `05_personal_info.png` | Thông tin cá nhân | `/personal-info` |
| `06_movie_detail.png` | Chi tiết phim | `/movie/:id` |
| `07_movie_info.png` | Thông tin phim (tập, diễn viên) | `/movie-info/:id` |
| `08_ratings_reviews.png` | Đánh giá & gợi ý | `/ratings/:id` |
| `09_movie_detail_episodes.png` | Chi tiết phim (phần tập) | (variant) |
| `10_video_player_credits.png` | Trình phát — credit | `/video-player/:id` |
| `11_video_player.png` | Trình phát | `/video-player/:id` |
| `12_search_results.png` | Tìm kiếm | `/search` |
| `13_explore_by_genre.png` | Khám phá theo thể loại | `/explore/:name` |
| `14_welcome.png` | Welcome | `/` |
| `15_onboarding_gender.png` | Onboarding (bước chọn giới tính) | `/signup` (bước trong luồng) |
| `16_login.png` | Đăng nhập | `/sign-in` |

---

## Chưa có ảnh (cần chụp bổ sung)

| # | Màn hình | Route | Ghi chú |
|---|----------|--------|--------|
| 1 | **Đăng ký** (Signup — màn đầu hoặc tổng quan) | `/signup` | Có thể thêm ảnh màn đầu (email/name) nếu khác 15 |
| 2 | **Quên mật khẩu** | `/forgot-password` | Form nhập email |
| 3 | **Xác thực OTP** | `/otp-verification` | Sau khi gửi email quên MK |
| 4 | **Đặt lại mật khẩu** | `/reset-password` | Form mật khẩu mới |
| 5 | **Danh sách Wishlist** | `/wishlist` | Tab bottom nav — danh sách phim yêu thích |
| 6 | **Mua / Giao dịch (Purchase)** | `/purchase` | Tab bottom nav — lịch sử giao dịch / mua |
| 7 | **Thông báo** | `/notification` | Danh sách thông báo |
| 8 | **Cài đặt thông báo** | `/notification-settings` | Từ Profile → Notification |
| 9 | **Bảo mật** | `/security` | Đổi mật khẩu, Remember me, Sessions |
| 10 | **Sở thích (Preferences)** | `/preferences` | Thể loại ưa thích, v.v. |
| 11 | **Ngôn ngữ** | `/language` | Chọn English / Tiếng Việt |
| 12 | **Trung tâm trợ giúp** | `/help-center` | FAQ / hỗ trợ |
| 13 | **Danh sách theo loại** (Wishlist / Recent / Recommended) | `/movie-type/wishlist`, `/movie-type/recent`, `/movie-type/recommended` | Màn danh sách phim theo từng loại |
| 14 | **Chi tiết thể loại / bộ lọc** | `/movie-carousel-genre/:id` (hoặc country/year) | ExploreGenreDetails — màn sau khi chọn 1 genre từ carousel |
| 15 | **Thanh toán thành công** | `/payment/success` | Sau khi thanh toán Stripe thành công |
| 16 | **Cài đặt (Settings)** | — | Language + Theme (SettingScreen) — có trong code, chưa có route trong app_router |

---

## Cách chụp nhanh

1. Chạy app: `cd Src/client && flutter run` (chọn iOS Simulator hoặc Chrome).
2. Đăng nhập (nếu màn cần auth): dùng user test.
3. Điều hướng theo cột **Route** ở bảng "Chưa có ảnh".
4. Chụp: **iOS Simulator** `Cmd + S`, **Chrome** `Cmd/Ctrl + Shift + P` → "Capture screenshot".
5. Đặt tên theo gợi ý: `17_wishlist.png`, `18_purchase.png`, `19_notification.png`, …
