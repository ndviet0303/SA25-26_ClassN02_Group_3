# Fake Data Import (Node.js)

Script chạy **bên ngoài** (Node.js) để import ~10.000 user giả vào **identitydb** và **customerdb**.

## Yêu cầu

- Node.js 18+
- PostgreSQL: `identitydb` và `customerdb` đã tạo, **identity-service** đã chạy ít nhất một lần để có bảng `roles` và role `USER`.

## Cài đặt

```bash
cd Src/server/microservices/tools/fake-data-import
npm install
```

## Cấu hình

Biến môi trường (hoặc mặc định):

| Biến | Mặc định | Mô tả |
|------|----------|--------|
| `IDENTITY_DB_URL` | `postgresql://sa:password@localhost:5432/identitydb` | Connection string Identity DB |
| `CUSTOMER_DB_URL` | `postgresql://sa:password@localhost:5432/customerdb` | Connection string Customer DB |
| `IMPORT_USER_COUNT` | `10000` | Số user giả cần tạo |
| `IMPORT_PASSWORD_HASH` | (bcrypt hash mặc định) | Hash mật khẩu chung cho tất cả user giả |

## Chạy

```bash
# Import 10000 users (mặc định)
npm run import

# Hoặc trực tiếp
node import.js

# Số user tùy chỉnh
IMPORT_USER_COUNT=5000 node import.js

# Dry run (chỉ in config, không ghi DB)
npm run import:dry
```

## Dữ liệu tạo ra

### Identity DB

- **users**: `fakeuser00001` .. `fakeuser10000` (hoặc theo `IMPORT_USER_COUNT`), email `fakeuser00001@nozie.local`, ... Cùng một `password` hash (mặc định tương ứng mật khẩu bạn cấu hình).
- **user_roles**: Mỗi user gán role **USER** (role_id lấy từ bảng `roles`).

### Customer DB

- **customers**: Mỗi `user_id` tương ứng một customer với dữ liệu giả: `full_name`, `date_of_birth`, `gender`, `country`, `phone_number`, `bio` (khác nhau ngẫu nhiên).
- **customer_interests**: Mỗi customer có 1–5 genre ngẫu nhiên (slug + name), map đúng `customer_id` với user đã tạo.

Chạy lại script: user trùng (username) sẽ bỏ qua, customer trùng `user_id` sẽ được cập nhật (upsert), interests giữ unique `(customer_id, genre_slug)`.
