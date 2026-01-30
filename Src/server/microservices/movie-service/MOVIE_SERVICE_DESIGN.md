# Gợi ý xây dựng Movie Service chuẩn

Tài liệu này gợi ý kiến trúc và thiết kế cho **movie-service** trong hệ sinh thái microservices Nozie, đồng bộ với nguồn dữ liệu OPhim (xem `SOURCE_FILM.md`).

---

## 1. Kiến trúc tổng quan

### 1.1. Layered Architecture (đã có, cần bổ sung)

```
┌─────────────────────────────────────────────────────────────────┐
│  API Layer (Controllers)                                         │
│  - CatalogController, StreamingController                        │
│  - DTO Request/Response, Validation                              │
├─────────────────────────────────────────────────────────────────┤
│  Service Layer (Business Logic)                                  │
│  - CatalogService, StreamingService                              │
│  - [Gợi ý] OPhimSyncService, GenreService, CountryService        │
├─────────────────────────────────────────────────────────────────┤
│  Repository Layer (Persistence)                                   │
│  - MovieRepository                                                │
│  - [Gợi ý] GenreRepository, CountryRepository (nếu lưu master)   │
├─────────────────────────────────────────────────────────────────┤
│  External Clients (Optional)                                      │
│  - OPhimClient (Feign) – đồng bộ/import từ OPhim                 │
└─────────────────────────────────────────────────────────────────┘
```

- **API**: Chỉ nhận DTO, validate, gọi Service, trả Response DTO.
- **Service**: Nghiệp vụ, mapping Entity ↔ DTO, gọi Repository/Client.
- **Repository**: Chỉ truy cập MongoDB (Movie, có thể thêm Genre/Country nếu cần).

### 1.2. Bounded context (đã tách)

- **Catalog**: Danh mục phim (CRUD, tìm kiếm, lọc, trang chủ, theo thể loại/quốc gia/năm).
- **Streaming**: Tương tác phát (view count, sau này: link phát, token).

Giữ tách Controller/Service theo hai context này là hợp chuẩn.

---

## 2. API Design chuẩn

### 2.1. REST conventions

| Chuẩn | Gợi ý |
|-------|--------|
| **Base path** | `/api/v1/movies` (version trong path hoặc header) |
| **Danh sách** | `GET /api/v1/movies` + query pagination & filter |
| **Chi tiết** | `GET /api/v1/movies/{id}` hoặc `GET /api/v1/movies/slug/{slug}` |
| **Tạo** | `POST /api/v1/movies` (admin) |
| **Cập nhật** | `PUT /api/v1/movies/{id}` hoặc `PATCH` (admin) |
| **Xóa** | `DELETE /api/v1/movies/{id}` (admin) |
| **Sub-resource** | `POST /api/v1/movies/{id}/view` (streaming) |

Có thể giữ `/api/movies` như hiện tại, nhưng nên thống nhất thêm version (ví dụ `v1`) khi có breaking change.

### 2.2. Pagination chuẩn (align OPhim & best practice)

- Query: `page` (1-based), `size` hoặc `limit` (mặc định 24).
- Response wrap trong object có metadata:

```json
{
  "success": true,
  "data": {
    "items": [...],
    "page": 1,
    "size": 24,
    "totalItems": 100,
    "totalPages": 5
  }
}
```

Gợi ý: Tạo DTO `PageResponse<T>` trong common hoặc movie-service, dùng chung cho mọi API trả danh sách.

### 2.3. Filtering (khớp SOURCE_FILM)

Cho **GET /api/v1/movies** (hoặc GET danh sách tương đương):

| Query param | Mô tả | Ví dụ |
|-------------|--------|-------|
| `page` | Trang | 1 |
| `size` hoặc `limit` | Số phần tử/trang | 24 |
| `q` hoặc `keyword` | Tìm kiếm tên/gốc | inception |
| `type` | Loại phim | single, series, hoathinh |
| `genre` hoặc `category` | Thể loại (slug) | hanh-dong, tinh-cam |
| `country` | Quốc gia (slug) | han-quoc, au-my |
| `year` | Năm | 2025 |
| `accessType` | FREE, PREMIUM, RENTAL | FREE |
| `sort` | Trường sắp xếp | view, year, createdAt |
| `order` | asc / desc | desc |

Repository/Service: dùng `Query` + criteria (MongoDB) hoặc `MongoRepository` với `Example`/custom method có `Pageable`.

---

## 3. Model & DTO

### 3.1. Entity Movie (MongoDB) – mở rộng theo OPhim

Giữ các trường hiện tại, **cân nhắc thêm** (để đồng bộ với SOURCE_FILM và client):

- `category` / `country`: danh sách `{ id, name, slug }` (embedded hoặc ref).
- `episodeCurrent`, `episodeTotal`: đã có trong ý tưởng OPhim.
- `actor`, `director`: `List<String>`.
- `subDocquyen`, `chieuRap`: boolean (nếu cần).
- `externalId`: ID từ OPhim (để sync không trùng).
- `source`: enum OPHIM | MANUAL (nguồn nhập).

Chỉ thêm trường khi thật sự dùng (catalog UI, filter, sync).

### 3.2. DTO chuẩn

| DTO | Mục đích |
|-----|----------|
| **MovieRequest** | POST/PUT body (đã có), bổ sung validation đủ trường cần thiết |
| **MovieResponse** | Trả về 1 phim (chi tiết) – không lộ field nội bộ, có thể thêm `fullPosterUrl`, `fullThumbUrl` (CDN) |
| **MovieListItemResponse** | Item trong danh sách (ít field hơn chi tiết) |
| **PageResponse\<T>** | `items`, `page`, `size`, `totalItems`, `totalPages` |
| **MovieFilterRequest** | Object query params (page, size, q, type, genre, country, year, sort, order) – dùng trong Service |

Tách Response cho “list” và “detail” giúp API rõ ràng và dễ tối ưu (chỉ trả field cần).

---

## 4. Đồng bộ / Import từ OPhim

### 4.1. Chiến lược

- **Option A – Proxy**: Movie-service không lưu, gọi OPhim (Feign) và map response sang DTO của bạn. Ưu: luôn mới. Nhược: phụ thuộc OPhim, latency.
- **Option B – Sync/Import**: Định kỳ hoặc on-demand gọi OPhim (13 API trong SOURCE_FILM), map vào `Movie` (và Genre/Country nếu có) rồi lưu MongoDB. Ưu: chủ động, nhanh, có thể gắn thêm `accessType`, `price`. Nhược: cần job + xử lý conflict (slug, externalId).

Gợi ý: **Option B** cho catalog chính, kèm admin API “sync now” hoặc scheduler.

### 4.2. OPhim Client (Feign)

- Tạo `OPhimClient` (Feign) gọi `https://ophim1.com` (hoặc domain trong config).
- DTO riêng cho response OPhim (OPhimMovieDto, OPhimListResponse…) để không dính entity nội bộ.
- Service: `OPhimSyncService` – lấy từng endpoint (home, danh-sách, the-loai, quoc-gia, nam-phat-hanh, tim-kiem, phim/{slug}), map sang `Movie` (và Genre/Country nếu lưu), save/update theo `slug` hoặc `externalId`.

### 4.3. Mapping OPhim → Movie

- `name`, `origin_name` → `name`, `originName`
- `slug` → `slug` (unique)
- `thumb_url`, `poster_url` → `thumbUrl`, `posterUrl` (có thể lưu relative, khi trả client mới gắn CDN)
- `type` → `type` (single/series/hoathinh)
- `year` → `year`
- `category` → `category` (embedded/list)
- `country` → `country` (embedded/list)
- `tmdb.vote_average`, `imdb.vote_average` → `tmdbRating`, `imdbRating`
- Thêm `externalId = _id` từ OPhim, `source = OPHIM`.

---

## 5. API Catalog gợi ý (align 13 API OPhim)

Có thể ánh xạ 1-1 với SOURCE_FILM hoặc gom lại qua 1 endpoint có filter:

| # | Mục đích | Gợi ý endpoint | Ghi chú |
|---|----------|----------------|---------|
| 1 | Trang chủ | GET /api/v1/movies/home hoặc GET /api/v1/movies?feature=latest | Phim mới cập nhật |
| 2 | Danh sách + bộ lọc | GET /api/v1/movies?page&size&type&genre&country&year&sort&order | Một endpoint linh hoạt |
| 3 | Tìm kiếm | GET /api/v1/movies/search?q=&page&size | keyword + filter như trên |
| 4 | Danh sách thể loại | GET /api/v1/genres | Trả từ master hoặc aggregate từ Movie |
| 5 | Phim theo thể loại | GET /api/v1/movies?genre=hanh-dong&page&size | Dùng chung GET /movies |
| 6 | Danh sách quốc gia | GET /api/v1/countries | Master hoặc aggregate |
| 7 | Phim theo quốc gia | GET /api/v1/movies?country=han-quoc&page&size | Dùng chung GET /movies |
| 8 | Danh sách năm | GET /api/v1/years | Distinct year từ Movie |
| 9 | Phim theo năm | GET /api/v1/movies?year=2025&page&size | Dùng chung GET /movies |
| 10 | Chi tiết phim | GET /api/v1/movies/{id} hoặc GET /api/v1/movies/slug/{slug} | Trả MovieResponse đầy đủ |
| 11–13 | Hình ảnh / Diễn viên / Từ khóa | Có thể nằm trong chi tiết phim (MovieResponse) | Hoặc GET sub-resource nếu tách riêng |

Ưu tiên: **một GET /movies với filter** + **GET /movies/slug/{slug}** + **GET /genres, /countries, /years** đơn giản.

---

## 6. Chất lượng mã & vận hành

### 6.1. Validation

- Request: `@Valid` + Bean Validation (đã dùng).
- Bổ sung: `@NotBlank`, `@Size`, `@Min`/`@Max` cho số, `@Pattern` cho slug nếu cần.
- Slug: không cho phép trùng khi tạo/sửa (đã có trong CatalogService).

### 6.2. Xử lý lỗi

- Dùng chung `ResourceNotFoundException`, `BadRequestException` và `GlobalExceptionHandler` (common) – giữ như hiện tại.
- Trả lỗi thống nhất: HTTP status + body format giống `ApiResponse` (success=false, message, data=null).

### 6.3. Bảo mật

- CORS: không để `*` production; cấu hình origin cụ thể.
- Admin API (POST/PUT/DELETE): bảo vệ bằng JWT hoặc API key (qua API Gateway / identity-service).
- GET catalog: có thể public; rate limit ở gateway hoặc movie-service.

### 6.4. Caching (tùy chọn)

- Redis: cache “home”, “danh sách theo genre/country/year” (key theo param, TTL vài phút).
- Cache invalidation: khi sync OPhim hoặc khi admin cập nhật/xóa phim.

### 6.5. Observability

- Actuator: đã có; bật `health`, `info`; production ẩn endpoint nhạy cảm.
- Log: cấu trúc (JSON), có requestId/traceId khi qua gateway.
- Metrics: số request theo endpoint, latency; có thể export Prometheus.

---

## 7. Testing

- **Unit**: Service (CatalogService, StreamingService, OPhimSyncService) – mock Repository/Feign.
- **Integration**: Controller + MongoDB (Testcontainers) hoặc embedded MongoDB; test GET/POST với body chuẩn.
- **Contract**: Nếu có gateway/consumer khác gọi movie-service, cân nhắc Pact hoặc OpenAPI-based contract test.

---

## 8. Checklist triển khai

- [ ] Chuẩn hóa pagination: `PageResponse<T>`, query `page`, `size`/`limit`.
- [ ] Thêm filter GET /movies: type, genre, country, year, sort, order.
- [ ] Tách MovieResponse / MovieListItemResponse, dùng cho API thay vì trả entity.
- [ ] (Tùy chọn) Thêm Genre/Country master + API GET /genres, /countries, /years.
- [ ] (Tùy chọn) OPhim Feign client + OPhimSyncService + mapping → Movie.
- [ ] (Tùy chọn) Scheduler hoặc admin API “sync from OPhim”.
- [ ] CORS, rate limit, bảo vệ admin API.
- [ ] Caching (Redis) nếu cần giảm tải.
- [ ] OpenAPI/Swagger cho tài liệu API.
- [ ] Unit + integration test cho luồng chính.

---

## 9. Tài liệu tham khảo

- **SOURCE_FILM.md**: 13 API OPhim, cấu trúc response, thể loại, quốc gia, phân trang.
- **Common**: `ApiResponse`, `ResourceNotFoundException`, `BadRequestException`, `GlobalExceptionHandler`.
- **Hiện trạng**: CatalogController, StreamingController, CatalogService, StreamingService, MovieRepository, Movie, MovieRequest.

Khi triển khai từng bước, nên ưu tiên: **pagination + filter** → **Response DTO** → **OPhim sync** (nếu cần) → **cache & security**.
