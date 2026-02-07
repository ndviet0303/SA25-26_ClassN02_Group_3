# Tools

## Insert subscription plans vào paymentdb

Bảng `subscription_plans` phải đã tồn tại (chạy **payment-service** ít nhất một lần để JPA tạo bảng).

### PostgreSQL chạy trong Docker (nozie-postgres)

```bash
# Từ thư mục microservices
cat tools/insert-subscription-plans.sql | docker exec -i nozie-postgres psql -U sa -d paymentdb
```

Hoặc:

```bash
docker exec -i nozie-postgres psql -U sa -d paymentdb -f - < tools/insert-subscription-plans.sql
```

(Phải chạy từ thư mục có `tools/`, hoặc dùng đường dẫn đầy đủ tới file.)

### PostgreSQL chạy local (psql)

```bash
psql -h localhost -p 5432 -U sa -d paymentdb -f tools/insert-subscription-plans.sql
```

Nhập password khi được hỏi (mặc định trong docker-compose: `password`).

---

Nội dung SQL cũng nằm trong `payment-service/src/main/resources/data.sql` và có thể được Spring Boot chạy khi khởi động payment-service (nếu bật init).
