# Tài Liệu API OPhim

## Tổng Quan

OPhim là hệ thống API RESTful cung cấp dữ liệu phim ảnh phong phú và được cập nhật liên tục. API này cung cấp thông tin chi tiết về phim, bao gồm metadata, hình ảnh HD từ TMDB, thông tin diễn viên, đạo diễn, và các tính năng tìm kiếm, lọc, sắp xếp linh hoạt.

## Thông Tin Cơ Bản

- **Base URL**: `https://ophim1.com`
- **API Version**: `v1`
- **Định dạng dữ liệu**: `JSON`
- **Mã hóa**: `UTF-8`
- **Phương thức HTTP**: `GET`
- **CDN Image**: `https://img.ophim.live`

## Cấu Trúc Response Chung

Tất cả các API endpoint đều trả về response theo cấu trúc sau:

```json
{
  "status": "success" | "error",
  "message": "string",
  "data": {
    "seoOnPage": { ... },
    "breadCrumb": [ ... ],
    "items": [ ... ] | "item": { ... },
    "params": { ... },
    "APP_DOMAIN_CDN_IMAGE": "https://img.ophim.live"
  }
}
```

### Các Trường Chính

- **status**: Trạng thái của request (`success` hoặc `error`)
- **message**: Thông báo (thường là chuỗi rỗng khi thành công)
- **data**: Dữ liệu chính
  - **seoOnPage**: Thông tin SEO cho trang
  - **breadCrumb**: Breadcrumb navigation
  - **items**: Danh sách phim (cho danh sách)
  - **item**: Chi tiết một phim (cho chi tiết)
  - **params**: Tham số của request
  - **APP_DOMAIN_CDN_IMAGE**: Domain CDN cho hình ảnh

---

## API Endpoints

### 1. API Trang Chủ - Phim Trang Chủ

Lấy danh sách phim hiển thị trên trang chủ.

**Endpoint**: 
```
GET /v1/api/home
```

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/home"
```

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "seoOnPage": {
      "titleHead": "Dữ liệu phim vietsub miễn phí mới nhất...",
      "descriptionHead": "Website cung cấp phim miễn phí...",
      "og_type": "website",
      "og_image": ["/uploads/movies/movie1-thumb.jpg", ...]
    },
    "items": [
      {
        "_id": "68deaaebbc85dba74e6e9e16",
        "name": "Tên phim",
        "slug": "ten-phim",
        "origin_name": "Original Name",
        "type": "series" | "single" | "hoathinh",
        "thumb_url": "ten-phim-thumb.jpg",
        "sub_docquyen": true | false,
        "time": "114 phút/tập",
        "episode_current": "Hoàn tất (22/22)",
        "quality": "HD",
        "lang": "Vietsub",
        "year": 2025,
        "category": [...],
        "country": [...],
        "alternative_names": [...],
        "tmdb": {...},
        "imdb": {...},
        "modified": {...}
      }
    ]
  }
}
```

---

### 2. API Danh Sách - Danh Sách Phim (Bộ Lọc)

Lấy danh sách phim với các bộ lọc tùy chọn.

**Endpoint**: 
```
GET /v1/api/danh-sach/phim-moi-cap-nhat
```

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)
- `filterCategory`: Mảng các thể loại (ví dụ: `["hanh-dong"]`)
- `filterCountry`: Mảng các quốc gia (ví dụ: `["han-quoc"]`)
- `filterYear`: Năm phim (ví dụ: `2025`)
- `filterType`: Loại phim (`single`, `series`, `hoathinh`)
- `sortField`: Trường sắp xếp (ví dụ: `_id`, `modified.time`)
- `sortType`: Kiểu sắp xếp (`asc`, `desc`)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/danh-sach/phim-moi-cap-nhat?page=1&limit=24"
```

**Response**: Tương tự như endpoint "Phim Trang Chủ", nhưng có thêm thông tin phân trang và bộ lọc trong `params`.

---

### 3. API Tìm Kiếm - Tìm Kiếm Phim

Tìm kiếm phim theo từ khóa với các bộ lọc tùy chọn.

**Endpoint**: 
```
GET /v1/api/tim-kiem
```

**Tham số Query** (bắt buộc):
- `keyword`: Từ khóa tìm kiếm (bắt buộc)

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)
- `filterCategory`: Mảng các thể loại (ví dụ: `["hanh-dong"]`)
- `filterCountry`: Mảng các quốc gia (ví dụ: `["han-quoc"]`)
- `filterYear`: Năm phim (ví dụ: `2025`)
- `filterType`: Loại phim (`single`, `series`, `hoathinh`)
- `sortField`: Trường sắp xếp (ví dụ: `_id`, `modified.time`)
- `sortType`: Kiểu sắp xếp (`asc`, `desc`)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/tim-kiem?keyword=inception"
```

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "seoOnPage": {...},
    "breadCrumb": [...],
    "titlePage": "Tìm kiếm phim: inception",
    "items": [...],
    "params": {
      "type_slug": "tim-kiem",
      "keyword": "inception",
      "filterCategory": [""],
      "filterCountry": [""],
      "filterYear": "",
      "filterType": "",
      "sortField": "_id",
      "sortType": "desc",
      "pagination": {
        "totalItems": 1,
        "totalItemsPerPage": 24,
        "currentPage": 1,
        "pageRanges": 3
      }
    },
    "APP_DOMAIN_CDN_IMAGE": "https://img.ophim.live"
  }
}
```

---

### 4. API Thể Loại - Danh Sách Thể Loại

Lấy danh sách tất cả các thể loại phim có sẵn.

**Endpoint**: 
```
GET /v1/api/the-loai
```

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/the-loai"
```

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "items": [
      {
        "_id": "620a21b2e0fc277084dfd0c5",
        "name": "Hành Động",
        "slug": "hanh-dong"
      },
      {
        "_id": "620a220de0fc277084dfd16d",
        "name": "Tình Cảm",
        "slug": "tinh-cam"
      },
      ...
    ]
  }
}
```

---

### 5. API Thể Loại - Phim Theo Thể Loại (Bộ Lọc)

Lấy danh sách phim theo thể loại cụ thể với các bộ lọc tùy chọn.

**Endpoint**: 
```
GET /v1/api/the-loai/{slug}
```

**Tham số Path**:
- `slug`: Slug của thể loại (bắt buộc). Ví dụ: `hanh-dong`, `tinh-cam`, `hai-huoc`, `kinh-di`, `vien-tuong`, `phieu-luu`, `khoa-hoc`, `hinh-su`, `chien-tranh`, `chinh-kich`, `bi-an`

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/the-loai/hanh-dong"
```

**Response**: Tương tự như endpoint "Danh Sách Phim", nhưng chỉ trả về các phim thuộc thể loại được chỉ định.

---

### 6. API Quốc Gia - Danh Sách Quốc Gia

Lấy danh sách tất cả các quốc gia có phim.

**Endpoint**: 
```
GET /v1/api/quoc-gia
```

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/quoc-gia"
```

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "items": [
      {
        "_id": "62093063196e9f4ab6b448b8",
        "name": "Trung Quốc",
        "slug": "trung-quoc"
      },
      {
        "_id": "620a2300e0fc277084dfd6d2",
        "name": "Hàn Quốc",
        "slug": "han-quoc"
      },
      ...
    ]
  }
}
```

---

### 7. API Quốc Gia - Phim Theo Quốc Gia (Bộ Lọc)

Lấy danh sách phim theo quốc gia cụ thể với các bộ lọc tùy chọn.

**Endpoint**: 
```
GET /v1/api/quoc-gia/{slug}
```

**Tham số Path**:
- `slug`: Slug của quốc gia (bắt buộc). Ví dụ: `han-quoc`, `trung-quoc`, `nhat-ban`, `thai-lan`, `au-my`, `anh`, `phap`, `canada`, `viet-nam`

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/quoc-gia/han-quoc"
```

**Response**: Tương tự như endpoint "Danh Sách Phim", nhưng chỉ trả về các phim từ quốc gia được chỉ định.

---

### 8. API Năm Phát Hành - Danh Sách Năm Phát Hành

Lấy danh sách tất cả các năm phát hành có phim.

**Endpoint**: 
```
GET /v1/api/nam-phat-hanh
```

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/nam-phat-hanh"
```

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "items": [
      {
        "year": 2026
      },
      {
        "year": 2025
      },
      {
        "year": 2024
      },
      ...
    ]
  }
}
```

---

### 9. API Năm Phát Hành - Phim Theo Năm Phát Hành (Bộ Lọc)

Lấy danh sách phim theo năm phát hành cụ thể với các bộ lọc tùy chọn.

**Endpoint**: 
```
GET /v1/api/nam-phat-hanh/{year}
```

**Tham số Path**:
- `year`: Năm phát hành (bắt buộc). Ví dụ: `2025`, `2024`, `2023`

**Tham số Query** (tùy chọn):
- `page`: Số trang (mặc định: 1)
- `limit`: Số lượng phim mỗi trang (mặc định: 24)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/nam-phat-hanh/2025"
```

**Response**: Tương tự như endpoint "Danh Sách Phim", nhưng chỉ trả về các phim phát hành trong năm được chỉ định.

---

### 10. API Phim - Thông Tin Phim

Lấy thông tin chi tiết của một bộ phim theo slug.

**Endpoint**: 
```
GET /v1/api/phim/{slug}
```

**Tham số Path**:
- `slug`: Slug của phim (bắt buộc)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/phim/ke-danh-cap-giac-mo"
```

**Response**: Xem chi tiết ở phần "Cấu Trúc Dữ Liệu Chi Tiết" bên dưới.

---

### 11. API Phim - Hình Ảnh

Lấy danh sách hình ảnh của một bộ phim.

**Endpoint**: 
```
GET /v1/api/phim/{slug}/hinh-anh
```

**Tham số Path**:
- `slug`: Slug của phim (bắt buộc)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/phim/ke-danh-cap-giac-mo/hinh-anh"
```

**Lưu ý**: Endpoint này có thể trả về `{"status":false,"msg":"hmmm!"}` nếu không có dữ liệu hoặc slug không hợp lệ.

---

### 12. API Phim - Diễn Viên

Lấy danh sách diễn viên của một bộ phim.

**Endpoint**: 
```
GET /v1/api/phim/{slug}/dien-vien
```

**Tham số Path**:
- `slug`: Slug của phim (bắt buộc)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/phim/ke-danh-cap-giac-mo/dien-vien"
```

**Lưu ý**: Endpoint này có thể trả về `{"status":false,"msg":"hmmm!"}` nếu không có dữ liệu hoặc slug không hợp lệ. Thông tin diễn viên cũng có thể được tìm thấy trong response của endpoint "Thông Tin Phim" trong trường `actor`.

---

### 13. API Phim - Từ Khóa

Lấy danh sách từ khóa (keywords) liên quan đến một bộ phim.

**Endpoint**: 
```
GET /v1/api/phim/{slug}/tu-khoa
```

**Tham số Path**:
- `slug`: Slug của phim (bắt buộc)

**Ví dụ Request**:
```bash
curl "https://ophim1.com/v1/api/phim/ke-danh-cap-giac-mo/tu-khoa"
```

**Lưu ý**: Endpoint này có thể trả về `{"status":false,"msg":"hmmm!"}` nếu không có dữ liệu hoặc slug không hợp lệ.

---

**Response**:
```json
{
  "status": "success",
  "message": "",
  "data": {
    "seoOnPage": {
      "og_type": "video.movie",
      "titleHead": "Kẻ Đánh Cắp Giấc Mơ-Inception (2010) [HD-Vietsub]",
      "seoSchema": {
        "@context": "https://schema.org",
        "@type": "Movie",
        "name": "Kẻ Đánh Cắp Giấc Mơ-Inception (2010) [HD-Vietsub]",
        "dateModified": "2022-03-15T12:32:00.068Z",
        "dateCreated": "2022-03-15T12:32:00.068Z",
        "url": "https://ophim17.cc/phim/ke-danh-cap-giac-mo",
        "datePublished": "2022-03-15T12:32:00.068Z",
        "image": "https://img.ophim.live/uploads/movies/ke-danh-cap-giac-mo-thumb.jpg",
        "director": "OPhim.Live"
      },
      "descriptionHead": "Mô tả phim...",
      "og_image": ["movies/ke-danh-cap-giac-mo-thumb.jpg"],
      "updated_time": 1698405214000,
      "og_url": "phim/ke-danh-cap-giac-mo"
    },
    "breadCrumb": [
      {
        "name": "Phim Lẻ",
        "slug": "/danh-sach/phim-le",
        "position": 2
      },
      {
        "name": "Kẻ Đánh Cắp Giấc Mơ",
        "isCurrent": true,
        "position": 4
      }
    ],
    "params": {
      "slug": "ke-danh-cap-giac-mo"
    },
    "item": {
      "_id": "623087406507d05b94f59caf",
      "name": "Kẻ Đánh Cắp Giấc Mơ",
      "origin_name": "Inception",
      "content": "<p>Mô tả phim...</p>",
      "type": "single",
      "status": "completed",
      "thumb_url": "ke-danh-cap-giac-mo-thumb.jpg",
      "is_copyright": false,
      "trailer_url": "",
      "time": "Đang cập nhật",
      "episode_current": "Full",
      "episode_total": "1",
      "quality": "HD",
      "lang": "Vietsub",
      "notify": "",
      "showtimes": "",
      "slug": "ke-danh-cap-giac-mo",
      "year": 2010,
      "view": 443,
      "actor": [""],
      "director": [""],
      "category": [
        {
          "id": "620a21b2e0fc277084dfd0c5",
          "name": "Hành Động",
          "slug": "hanh-dong"
        }
      ],
      "country": [
        {
          "id": "620a231fe0fc277084dfd7ce",
          "name": "Âu Mỹ",
          "slug": "au-my"
        }
      ],
      "chieurap": false,
      "poster_url": "ke-danh-cap-giac-mo-poster.jpg",
      "sub_docquyen": false,
      "episodes": [
        {
          "server_name": "Vietsub #1",
          "is_ai": false,
          "server_data": [
            {
              "name": "Full",
              "slug": "full",
              "filename": "Kẻ Đánh Cắp Giấc Mơ",
              "link_embed": "https://vip.opstream11.com/share/d54e99a6c03704e95e6965532dec148b",
              "link_m3u8": "https://vip.opstream11.com/20220314/1901_ef246108/index.m3u8"
            }
          ]
        }
      ],
      "alternative_names": ["Alternative Name 1", "Alternative Name 2"],
      "lang_key": ["vs"],
      "tmdb": {
        "type": "movie",
        "id": "27205",
        "season": null,
        "vote_average": 8.37,
        "vote_count": 38224
      },
      "imdb": {
        "vote_average": 8.8,
        "vote_count": 2743035,
        "id": "tt1375666"
      },
      "created": {
        "time": "2022-03-15T12:32:00.068Z"
      },
      "modified": {
        "time": "2023-10-27T11:13:34.000Z"
      }
    },
    "APP_DOMAIN_CDN_IMAGE": "https://img.ophim.live"
  }
}
```

---

## Cấu Trúc Dữ Liệu Chi Tiết

### Đối Tượng Phim (Movie Item)

```json
{
  "_id": "string",                    // ID duy nhất của phim
  "name": "string",                    // Tên phim (tiếng Việt)
  "origin_name": "string",             // Tên phim gốc
  "slug": "string",                   // Slug URL của phim
  "type": "single" | "series" | "hoathinh",  // Loại phim
  "thumb_url": "string",              // URL hình thumbnail
  "poster_url": "string",             // URL hình poster
  "sub_docquyen": boolean,             // Có phụ đề độc quyền không
  "chieurap": boolean,                 // Có chiếu rạp không
  "time": "string",                   // Thời lượng (ví dụ: "114 phút/tập")
  "episode_current": "string",        // Tập hiện tại (ví dụ: "Hoàn tất (22/22)")
  "episode_total": "string",          // Tổng số tập
  "quality": "string",                // Chất lượng (ví dụ: "HD", "4K")
  "lang": "string",                   // Ngôn ngữ (ví dụ: "Vietsub", "Lồng Tiếng")
  "lang_key": ["vs"],                 // Mảng key ngôn ngữ
  "year": number,                     // Năm phát hành
  "view": number,                     // Số lượt xem
  "category": [                       // Mảng thể loại
    {
      "id": "string",
      "name": "string",
      "slug": "string"
    }
  ],
  "country": [                        // Mảng quốc gia
    {
      "id": "string",
      "name": "string",
      "slug": "string"
    }
  ],
  "alternative_names": ["string"],    // Tên thay thế
  "tmdb": {                           // Thông tin từ TMDB
    "type": "movie" | "tv",
    "id": "string",
    "season": number | null,
    "vote_average": number,
    "vote_count": number
  },
  "imdb": {                           // Thông tin từ IMDB
    "id": "string",
    "vote_average": number,
    "vote_count": number
  },
  "modified": {                        // Thời gian cập nhật
    "time": "ISO 8601 datetime string"
  },
  "created": {                         // Thời gian tạo
    "time": "ISO 8601 datetime string"
  },
  "last_episodes": [                   // Tập mới nhất
    {
      "server_name": "string",
      "is_ai": boolean,
      "name": "string"
    }
  ],
  "episodes": [                        // Danh sách tập (chỉ có trong chi tiết)
    {
      "server_name": "string",
      "is_ai": boolean,
      "server_data": [
        {
          "name": "string",
          "slug": "string",
          "filename": "string",
          "link_embed": "string",      // Link embed video
          "link_m3u8": "string"        // Link m3u8 để phát
        }
      ]
    }
  ],
  "content": "string",                 // Mô tả phim (HTML)
  "status": "string",                  // Trạng thái (ví dụ: "completed")
  "trailer_url": "string",            // URL trailer
  "actor": ["string"],                 // Mảng diễn viên
  "director": ["string"],              // Mảng đạo diễn
  "notify": "string",                  // Thông báo
  "showtimes": "string"                // Lịch chiếu
}
```

---

## Các Loại Phim (Type)

- `single`: Phim lẻ (một tập)
- `series`: Phim bộ (nhiều tập)
- `hoathinh`: Phim hoạt hình

## Các Thể Loại Phim (Category)

Một số thể loại phổ biến:
- `hanh-dong`: Hành Động
- `tinh-cam`: Tình Cảm
- `hai-huoc`: Hài Hước
- `kinh-di`: Kinh Dị
- `vien-tuong`: Viễn Tưởng
- `phieu-luu`: Phiêu Lưu
- `khoa-hoc`: Khoa Học
- `hinh-su`: Hình Sự
- `chien-tranh`: Chiến Tranh
- `chinh-kich`: Chính Kịch
- `bi-an`: Bí Ẩn

## Các Quốc Gia (Country)

Một số quốc gia phổ biến:
- `han-quoc`: Hàn Quốc
- `trung-quoc`: Trung Quốc
- `nhat-ban`: Nhật Bản
- `thai-lan`: Thái Lan
- `au-my`: Âu Mỹ
- `anh`: Anh
- `phap`: Pháp
- `canada`: Canada

## Ngôn Ngữ (Language)

- `vs`: Vietsub
- `tm`: Thuyết Minh
- `lt`: Lồng Tiếng

---

## Xử Lý Hình Ảnh

Tất cả các URL hình ảnh trong response là relative paths. Để lấy URL đầy đủ, cần kết hợp với `APP_DOMAIN_CDN_IMAGE`:

```
URL đầy đủ = APP_DOMAIN_CDN_IMAGE + "/uploads/movies/" + thumb_url/poster_url
```

**Ví dụ**:
- `thumb_url`: `"ke-danh-cap-giac-mo-thumb.jpg"`
- `APP_DOMAIN_CDN_IMAGE`: `"https://img.ophim.live"`
- URL đầy đủ: `https://img.ophim.live/uploads/movies/ke-danh-cap-giac-mo-thumb.jpg`

---

## Xử Lý Video

Trong response chi tiết phim, có hai loại link video:

1. **link_embed**: Link embed để nhúng vào iframe
2. **link_m3u8**: Link m3u8 để phát trực tiếp (HLS streaming)

**Ví dụ**:
```json
{
  "link_embed": "https://vip.opstream11.com/share/d54e99a6c03704e95e6965532dec148b",
  "link_m3u8": "https://vip.opstream11.com/20220314/1901_ef246108/index.m3u8"
}
```

---

## Phân Trang (Pagination)

Các endpoint danh sách hỗ trợ phân trang thông qua tham số query:

- `page`: Số trang (bắt đầu từ 1)
- `limit`: Số lượng item mỗi trang (mặc định: 24)

Response sẽ bao gồm thông tin phân trang trong `params.pagination`:

```json
{
  "pagination": {
    "totalItems": 100,
    "totalItemsPerPage": 24,
    "currentPage": 1,
    "pageRanges": 5
  }
}
```

---

## Lỗi (Errors)

Khi có lỗi xảy ra, response sẽ có cấu trúc:

```json
{
  "status": "error",
  "message": "Mô tả lỗi",
  "data": null
}
```

---

## Rate Limiting

API không yêu cầu authentication, nhưng có thể có giới hạn về số lượng request. Khuyến nghị:
- Không gửi quá nhiều request trong thời gian ngắn
- Cache dữ liệu khi có thể
- Sử dụng pagination hợp lý

---

## Ví Dụ Sử Dụng

### JavaScript/TypeScript

```javascript
// Lấy danh sách phim mới
async function getLatestMovies() {
  const response = await fetch('https://ophim1.com/v1/api/danh-sach/phim-moi-cap-nhat');
  const data = await response.json();
  return data;
}

// Tìm kiếm phim
async function searchMovies(keyword) {
  const response = await fetch(`https://ophim1.com/v1/api/tim-kiem?keyword=${encodeURIComponent(keyword)}`);
  const data = await response.json();
  return data;
}

// Lấy chi tiết phim
async function getMovieDetail(slug) {
  const response = await fetch(`https://ophim1.com/v1/api/phim/${slug}`);
  const data = await response.json();
  return data;
}
```

### Python

```python
import requests

# Lấy danh sách phim mới
def get_latest_movies():
    response = requests.get('https://ophim1.com/v1/api/danh-sach/phim-moi-cap-nhat')
    return response.json()

# Tìm kiếm phim
def search_movies(keyword):
    response = requests.get(f'https://ophim1.com/v1/api/tim-kiem?keyword={keyword}')
    return response.json()

# Lấy chi tiết phim
def get_movie_detail(slug):
    response = requests.get(f'https://ophim1.com/v1/api/phim/{slug}')
    return response.json()
```

---

## Ghi Chú

1. **Base URL**: API sử dụng domain `ophim1.com`, nhưng có thể có các domain mirror khác như `ophim17.cc`, `ophim18.cc`.

2. **CDN Image**: Hình ảnh được lưu trữ trên CDN tại `https://img.ophim.live`.

3. **Video Streaming**: Video được stream qua các server khác nhau, có thể cần xử lý CORS khi embed.

4. **Cập nhật**: API được cập nhật thường xuyên, cấu trúc response có thể thay đổi theo thời gian.

5. **Slug**: Slug của phim là duy nhất và được sử dụng để truy cập chi tiết phim.

---

## Liên Hệ & Hỗ Trợ

- Website: https://ophim18.cc
- Forum: https://forum.ophim.cc/
- Telegram: https://t.me/+QMfjBOtNpkZmNTc1

---

**Tài liệu này được tạo dựa trên phân tích API thực tế của OPhim. Có thể có các endpoint khác chưa được liệt kê trong tài liệu này.**
