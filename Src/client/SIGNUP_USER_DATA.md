# Danh sách thông tin người dùng thu thập trong quá trình Signup

## Tổng quan
App Flutter thu thập thông tin người dùng qua 5 bước trong quá trình đăng ký và lưu vào Firebase Firestore.

---

## 1. Bước 1: Gender (Giới tính)
**File:** `lib/features/auth/register/presentation/screen/steps/step_gender.dart`

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `gender` | `String?` | ✅ Có | Giới tính người dùng (từ `Genders.getOptions()`) |

**Lưu vào Firestore:** `gender`

---

## 2. Bước 2: Age (Độ tuổi)
**File:** `lib/features/auth/register/presentation/screen/steps/step_age.dart`

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `age` | `String?` | ✅ Có | Nhóm tuổi người dùng (từ `Ages.getOptions()`) |

**Lưu vào Firestore:** `age`

---

## 3. Bước 3: Genre (Thể loại phim yêu thích)
**File:** `lib/features/auth/register/presentation/screen/steps/step_genre.dart`

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `genres` | `List<String>` | ❌ Không (có thể skip) | Danh sách thể loại phim yêu thích (từ `Genres.getOptions()`) |

**Lưu vào Firestore:** `genres` (array)

---

## 4. Bước 4: Profile (Thông tin cá nhân)
**File:** `lib/features/auth/register/presentation/screen/steps/step_profile.dart`

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `fullName` | `String` | ✅ Có | Họ và tên đầy đủ |
| `phone` | `String` | ✅ Có | Số điện thoại |
| `dateOfBirth` (dob) | `String` | ✅ Có | Ngày sinh (format DD/MM/YYYY) |
| `country` | `String` | ✅ Có | Quốc gia (từ dropdown `Countries.list`) |
| `avatarPath` | `String?` | ❌ Không | Đường dẫn file ảnh đại diện (từ ImagePicker) |

**Lưu vào Firestore:**
- `displayName` ← từ `fullName`
- `phone`
- `dateOfBirth`
- `country`
- `avatarUrl` ← URL sau khi upload lên Firebase Storage

---

## 5. Bước 5: Signup (Thông tin tài khoản)
**File:** `lib/features/auth/register/presentation/screen/steps/step_signup.dart`

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `username` | `String` | ✅ Có | Tên người dùng |
| `email` | `String` | ✅ Có | Email đăng ký |
| `password` | `String` | ✅ Có | Mật khẩu |
| `confirmPassword` | `String` | ✅ Có | Xác nhận mật khẩu (chỉ dùng để validate, không lưu) |
| `rememberMe` | `bool` | ❌ Không | Ghi nhớ đăng nhập (mặc định: false) |

**Lưu vào Firestore:**
- `username`
- `email` (từ Firebase Auth)
- `rememberMe`

**Lưu vào Firebase Auth:**
- `email`
- `password` (đã hash)
- `displayName` (từ fullName)

---

## Dữ liệu được lưu vào Firestore

**File:** `lib/features/auth/register/domain/repositories/firebase_auth_repository.dart`

Khi đăng ký thành công, app lưu vào collection `users` với document ID là `user.uid`:

```dart
{
  'uid': String,                    // Firebase Auth UID
  'email': String,                   // Email từ Firebase Auth
  'displayName': String?,             // Từ fullName
  'username': String,                 // Tên người dùng
  'rememberMe': bool,                 // Ghi nhớ đăng nhập
  'gender': String?,                  // Giới tính
  'age': String?,                     // Độ tuổi
  'genres': List<String>,             // Thể loại phim yêu thích
  'phone': String,                     // Số điện thoại
  'dateOfBirth': String,              // Ngày sinh
  'country': String,                  // Quốc gia
  'avatarUrl': String?,                // URL ảnh đại diện (sau khi upload)
  'createdAt': Timestamp,             // Thời gian tạo (server timestamp)
  'updatedAt': Timestamp,             // Thời gian cập nhật (server timestamp)
}
```

---

## Tóm tắt các trường gửi về Server

### Thông tin bắt buộc:
1. ✅ **username** - Tên người dùng
2. ✅ **email** - Email đăng ký
3. ✅ **password** - Mật khẩu (đã hash bởi Firebase)
4. ✅ **fullName** - Họ và tên đầy đủ
5. ✅ **phone** - Số điện thoại
6. ✅ **dateOfBirth** - Ngày sinh
7. ✅ **country** - Quốc gia
8. ✅ **gender** - Giới tính
9. ✅ **age** - Độ tuổi

### Thông tin tùy chọn:
10. ❓ **genres** - Danh sách thể loại phim (có thể bỏ qua)
11. ❓ **avatarUrl** - URL ảnh đại diện (nếu người dùng chọn upload)
12. ❓ **rememberMe** - Ghi nhớ đăng nhập (mặc định: false)

### Thông tin tự động tạo:
13. 🔄 **uid** - Firebase Auth User ID (tự động)
14. 🔄 **createdAt** - Thời gian tạo (server timestamp)
15. 🔄 **updatedAt** - Thời gian cập nhật (server timestamp)

---

## Lưu ý

1. **Avatar Upload Process:**
   - Ảnh được upload tạm thời trước khi tạo user
   - Sau khi tạo user thành công, ảnh được di chuyển đến vị trí cố định: `users/{uid}/avatar/avatar_{timestamp}.jpg`
   - URL cuối cùng được lưu vào `avatarUrl`

2. **Password:**
   - Mật khẩu được hash và lưu bởi Firebase Auth, không lưu plain text
   - `confirmPassword` chỉ dùng để validate, không được lưu

3. **Validation:**
   - Tất cả các trường bắt buộc đều có validation riêng
   - Email phải đúng format
   - Password phải đủ mạnh
   - Phone phải đúng format
   - Date of Birth phải hợp lệ
