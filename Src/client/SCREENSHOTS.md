# Chụp lại tất cả màn hình Flutter

Hai cách: **thủ công** (nhanh, đủ cho báo cáo) và **tự động** (integration test).

---

## 1. Cách thủ công (khuyến nghị)

Chạy app trên simulator/emulator hoặc thiết bị thật, điều hướng từng màn hình rồi chụp bằng phím tắt.

### Chạy app

```bash
cd Src/client
flutter run
# Chọn: Chrome (web), iOS Simulator, hoặc Android Emulator
```

### Phím tắt chụp màn hình

| Nền tảng | Cách chụp |
|----------|------------|
| **iOS Simulator** | `Cmd + S` — ảnh lưu trên Desktop |
| **Android Emulator** | `Ctrl + S` (Windows/Linux) hoặc `Cmd + S` (macOS) — hoặc nút camera trên thanh emulator |
| **Chrome (web)** | `Cmd + Shift + P` (macOS) / `Ctrl + Shift + P` (Win) → gõ "Capture screenshot" → Enter (chụp full page) |
| **macOS / Windows** | Chụp cửa sổ app: `Cmd + Shift + 4` (macOS), `Win + Shift + S` (Windows) |

### Danh sách màn hình cần chụp (theo route)

Điều hướng lần lượt và chụp từng màn. Một số route cần đăng nhập (đăng nhập trước rồi mới vào tab chính).

**Không cần đăng nhập**

| # | Màn hình | Đường dẫn / hành động |
|---|----------|------------------------|
| 1 | Welcome | Mở app (/) |
| 2 | Đăng nhập | `/sign-in` |
| 3 | Đăng ký | `/signup` |
| 4 | Quên mật khẩu | `/forgot-password` |
| 5 | Nhập OTP | Quên MK → nhập email → `/otp-verification` |
| 6 | Đặt mật khẩu mới | Sau OTP → `/reset-password` |

**Cần đăng nhập** (sau khi login)

| # | Màn hình | Đường dẫn |
|---|----------|-----------|
| 7 | Home | `/home` (tab Trang chủ) |
| 8 | Khám phá | `/discover` |
| 9 | Danh sách yêu thích | `/wishlist` |
| 10 | Mua / Giao dịch | `/purchase` |
| 11 | Cá nhân | `/profile` |
| 12 | Tìm kiếm | `/search` (hoặc nút search trên app bar) |
| 13 | Thông báo | `/notification` |
| 14 | Chi tiết phim | `/movie/:id` (chọn 1 phim bất kỳ) |
| 15 | Xem phim | Từ chi tiết phim → Play → `/video-player/:id` |
| 16 | Thông tin phim | Từ chi tiết → tab Info / `/movie-info/:id` |
| 17 | Đánh giá | `/ratings/:id` |
| 18 | Gói đăng ký | `/subscription` |
| 19 | Thanh toán thành công | `/payment/success` (sau khi test thanh toán) |
| 20 | Cài đặt | `/settings` |
| 21 | Thông tin cá nhân | `/personal-info` |
| 22 | Bảo mật | `/security` |
| 23 | Ngôn ngữ | `/language` |
| 24 | Cài đặt thông báo | `/notification-settings` |
| 25 | Sở thích | `/preferences` |
| 26 | Trung tâm trợ giúp | `/help-center` |
| 27 | Loại danh sách (Wishlist/Recent/Recommended) | `/movie-type/wishlist`, `/movie-type/recent`, `/movie-type/recommended` |
| 28 | Khám phá theo thể loại | `/explore/:name` hoặc từ Home → một genre |
| 29 | Chi tiết thể loại / bộ lọc | `/movie-carousel-genre/:id` (tùy màn bạn có) |

Gợi ý: tạo thư mục `screenshots/` trong project hoặc trên Desktop, đặt tên file theo màn (vd: `01_welcome.png`, `02_login.png`, …) để dễ ghép vào báo cáo.

---

## 2. Cách tự động (integration test + screenshot)

Dùng integration test để mở từng màn và gọi `takeScreenshot`. Ảnh có thể lưu qua driver (xem bước 2b).

### 2a. Cài package hỗ trợ (nếu dùng driver để lưu ảnh)

Trong `pubspec.yaml` (phần `dev_dependencies`):

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  # Tùy chọn: lưu screenshot ra file trên máy host
  # integration_test_driver_extended: ^0.2.0
```

### 2b. Tạo test chụp màn hình

Tạo thư mục và file:

- `integration_test/screenshot_screens_test.dart`

Nội dung mẫu (chụp màn Welcome và Login; có thể mở rộng cho mọi route):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_fe/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Screenshot: Welcome screen', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.binding.takeScreenshot('01_welcome');
  });

  testWidgets('Screenshot: Login screen', (tester) async {
    await tester.tap(find.text('Đăng nhập')); // điều chỉnh theo UI
    await tester.pumpAndSettle();
    await tester.binding.takeScreenshot('02_login');
  });
}
```

Chạy trên **device/emulator** (không chạy bằng `flutter test` thuần):

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_screens_test.dart
```

Ảnh do `takeScreenshot('tên')` tạo ra thường nằm trong thư mục build của Flutter hoặc theo cấu hình driver. Để lưu chính xác vào một thư mục (vd `screenshots/`), cần dùng driver tùy chỉnh với `integration_test_driver_extended` và callback `onScreenshot` ghi file (tên file = `screenshotName` + `.png`).

### 2c. Lưu ảnh ra thư mục cố định (tùy chọn)

- Tạo `test_driver/integration_test.dart` gọi `integrationDriver()` từ `integration_test_driver_extended` và trong `onScreenshot` ghi `screenshotBytes` ra file (vd `screenshots/$screenshotName.png`).
- Chạy vẫn bằng:

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_screens_test.dart
```

Lưu ý: màn hình yêu cầu đăng nhập cần test với user giả hoặc mock auth trong test thì mới mở được và chụp đúng nội dung.

---

## Tóm tắt

- **Nhanh, đủ dùng:** dùng **cách 1 (thủ công)** + bảng danh sách màn hình ở trên + phím tắt chụp theo từng nền tảng.
- **Lặp lại nhiều lần / CI:** đầu tư **cách 2 (integration test)** + driver lưu ảnh vào `screenshots/`.
