# Movie Service – API Reference

## Cấu trúc thư mục

```
movie-service/
├── common/                    # Shared: model, repository, dto
│   ├── model/                 # Movie, Genre, Country, Episode, ...
│   ├── repository/            # MovieRepository, GenreRepository, ...
│   └── dto/                   # MovieRequest, MovieResponse, PlayUrlResponse, ...
├── catalog/                   # Browsing & metadata
│   ├── controller/            # CatalogController, CatalogMetaController
│   └── service/               # CatalogService, MovieMapper
├── streaming/                 # Video playback
│   ├── controller/            # StreamingController
│   └── service/               # StreamingService
└── MovieServiceApplication.java
```

---

## Catalog API

### Danh sách & Filter

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/movies` | Danh sách phim. Query: `page`, `size`, `type`, `genre`, `country`, `year`, `q` |
| GET | `/api/movies/latest` | Phim mới cập nhật. Query: `page`, `size` |
| GET | `/api/movies/search?q=...` | Tìm kiếm. Query: `q`, `page`, `size` |
| GET | `/api/movies/type/{type}` | Phim theo loại (single/series/hoathinh) |
| GET | `/api/movies/genre/{slug}` | Phim theo thể loại |
| GET | `/api/movies/country/{slug}` | Phim theo quốc gia |
| GET | `/api/movies/year/{year}` | Phim theo năm |
| GET | `/api/movies/trending` | Top 10 phim xem nhiều |
| GET | `/api/movies/free` | Phim miễn phí |

### Chi tiết phim

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/movies/{id}` | Chi tiết phim theo ID |
| GET | `/api/movies/slug/{slug}` | Chi tiết phim theo slug |

### CRUD (Admin)

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| POST | `/api/movies` | Tạo phim |
| PUT | `/api/movies/{id}` | Cập nhật phim |
| DELETE | `/api/movies/{id}` | Xóa phim |

### Metadata (Filter UI)

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/genres` | Danh sách thể loại |
| GET | `/api/countries` | Danh sách quốc gia |
| GET | `/api/years` | Danh sách năm có phim |

---

## Streaming API

### Phát video

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/movies/{id}/play` | URL phát mặc định. Query: `server`, `episode` (0-based) |
| GET | `/api/movies/slug/{slug}/play` | URL phát theo slug. Query: `server`, `episode` |
| GET | `/api/movies/{id}/episodes` | Danh sách episodes theo server |
| GET | `/api/movies/slug/{slug}/episodes` | Danh sách episodes theo slug |

### Tương tác

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| POST | `/api/movies/{id}/view` | Tăng lượt xem |
| POST | `/api/movies/slug/{slug}/view` | Tăng lượt xem theo slug |

---

## Response DTOs

### PlayUrlResponse

```json
{
  "movieId": "...",
  "movieName": "...",
  "serverName": "Vietsub #1",
  "episodeName": "Full",
  "episodeSlug": "full",
  "m3u8Url": "https://...",
  "embedUrl": "https://...",
  "customHls": false
}
```

### EpisodesResponse

```json
{
  "movieId": "...",
  "movieName": "...",
  "customHlsUrl": null,
  "servers": [
    {
      "serverName": "Vietsub #1",
      "isAi": false,
      "episodes": [
        {
          "name": "Full",
          "slug": "full",
          "m3u8Url": "https://...",
          "embedUrl": "https://..."
        }
      ]
    }
  ]
}
```

### PageResponse&lt;MovieListItemResponse&gt;

```json
{
  "items": [...],
  "page": 1,
  "size": 24,
  "totalItems": 121,
  "totalPages": 6
}
```

---

## Query params

- `page` (default: 1)
- `size` (default: 24, max: 50)
- `type`: single | series | hoathinh
- `genre`: slug thể loại (vd: hanh-dong)
- `country`: slug quốc gia (vd: han-quoc)
- `year`: năm
- `q`: từ khóa tìm kiếm
- `server`: index server (0-based) cho /play
- `episode`: index tập (0-based) cho /play
