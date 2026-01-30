# Movie Service – Tool Import OPhim & API Expose

Tài liệu tóm tắt: tool import từ OPhim (SOURCE_FILM.md) và các API expose ra ngoài.

---

## 1. Tool import từ OPhim (Node.js – tools/)

Import dùng **script Node.js độc lập**, không qua movie-service. Chạy xong có thể xóa folder `tools/`.

```bash
cd movie-service/tools
npm install
node import.js --all                    # Import tất cả (genres, countries, movies)
node import.js --genres --countries     # Chỉ metadata
node import.js --movies --pages 5       # Import 5 trang phim (có episodes)
node import.js --slug ten-phim          # Import 1 phim theo slug
node import.js --genre hanh-dong        # Import phim theo thể loại
```

- MongoDB: `mongodb://localhost:27017/moviedb` (override qua `MONGODB_URI`)
- OPhim API: `https://ophim1.com/v1/api`

---

## 2. API expose ra ngoài (Catalog)

### 2.1. Danh sách & filter

| Method | Endpoint | Query params | Mô tả |
|--------|----------|--------------|--------|
| GET | `/api/movies` | `page`, `size`, `type`, `genre`, `country`, `year`, `q` | Danh sách phim có phân trang + filter. Trả về `PageResponse<MovieListItemResponse>`. |

- `page`: số trang (default 1)  
- `size`: số phần tử/trang (default 24)  
- `type`: single | series | hoathinh  
- `genre`: slug thể loại (vd: hanh-dong)  
- `country`: slug quốc gia (vd: han-quoc)  
- `year`: năm  
- `q`: từ khóa tìm kiếm (name, originName)  

### 2.2. Chi tiết phim

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/movies/{id}` | Chi tiết phim theo ID. Trả về `MovieResponse` (có **episodes** với link_m3u8, link_embed). |
| GET | `/api/movies/slug/{slug}` | Chi tiết phim theo slug. Trả về `MovieResponse`. |

### 2.3. Catalog metadata (filter UI)

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/genres` | Danh sách thể loại (id, name, slug). |
| GET | `/api/countries` | Danh sách quốc gia (id, name, slug). |
| GET | `/api/years` | Danh sách năm có phim (distinct từ movies), sắp xếp giảm dần. |

### 2.4. Các endpoint khác

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/movies/search?q=...&page=1&size=24` | Tìm kiếm theo từ khóa, trả về phân trang. |
| GET | `/api/movies/type/{type}?page=1&size=24` | Phim theo type (single/series/hoathinh). |
| GET | `/api/movies/trending` | Top 10 phim theo view. |
| GET | `/api/movies/free` | Phim free. |
| POST | `/api/movies` | Tạo phim (body: MovieRequest). |
| PUT | `/api/movies/{id}` | Cập nhật phim. |
| DELETE | `/api/movies/{id}` | Xóa phim. |

---

## 3. Cấu trúc dữ liệu lưu MongoDB

### 3.1. Collection `movies`

- Metadata phim (name, slug, type, year, category, country, …).  
- **episodes**: mảng `{ serverName, isAi, serverData: [ { name, slug, filename, link_embed, link_m3u8 } ] }` (theo SOURCE_FILM 559-560).  
- **custom_hls_url**, **custom_hls_source**: dùng khi admin đã upload R2/CDN.  

### 3.2. Collection `genres`

- `id`, `name`, `slug` (sync từ OPhim GET /the-loai).  

### 3.3. Collection `countries`

- `id`, `name`, `slug` (sync từ OPhim GET /quoc-gia).  

---

## 4. File đã thêm/sửa

- **Model:** `CategoryRef`, `CountryRef`, `ServerDataItem`, `Episode`, `Genre`, `Country`; mở rộng `Movie` (episodes, category, country, externalId, source, customHlsUrl, …).  
- **Import tool:** `tools/import.js` (Node.js) – gọi OPhim API, map sang schema, lưu MongoDB.  
- **Repository:** `GenreRepository`, `CountryRepository`, `MovieRepositoryCustom` + `MovieRepositoryImpl` (filter + pagination + distinct years).  
- **DTO:** `PageResponse`, `MovieListItemResponse`, `MovieResponse`.  
- **Catalog:** `MovieMapper`, `CatalogService` (getMoviesWithFilter, getAllGenres, getAllCountries, getDistinctYears), `CatalogController` (GET /api/movies với query, GET by id/slug trả MovieResponse), `CatalogMetaController` (GET /api/genres, /api/countries, /api/years).  

---

**Lưu ý:** Nếu Maven báo lỗi Lombok/JDK khi compile, cần dùng JDK tương thích (vd 17) hoặc nâng cấp Lombok; logic tool import và API đã sẵn sàng theo SOURCE_FILM.md.
