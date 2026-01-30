# Luồng dữ liệu & video: Cào OPhim + Custom (FFmpeg → R2 → CDN)

Tài liệu mô tả **hai giai đoạn** rõ ràng theo ý anh:
1. **Cào data ban đầu** từ OPhim (tool ngoài tự chế) → lưu metadata + **link m3u8 & embed** vào DB
2. **Custom** (tùy chọn): Admin dùng tool MP4 → FFmpeg → m3u8 + ts → upload Cloudflare R2 → CDN → lưu link mới vào DB

Tham chiếu: `idea-2.md`, `SOURCE_FILM.md` (559-560), `FEASIBILITY_ANALYSIS.md`.

---

## 1. Giai đoạn 1: Cào data từ OPhim (ban đầu)

### 1.1. Cách làm

- **Không dùng Feign** trong runtime
- Dùng **tool bên ngoài tự chế** (script Python/Node/Java CLI) để:
  - Gọi 13 API OPhim (GET)
  - Parse JSON
  - Chuẩn hóa và **nhét vào database** của mình (MongoDB movie-service)

### 1.2. Phần video cần lưu từ OPhim

Theo `SOURCE_FILM.md` (559-560), mỗi **tập/phim** trong OPhim có cấu trúc:

```json
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
]
```

Tool cào data **bắt buộc lưu**:

- **`link_m3u8`**: dùng cho player HLS (m3u8 trực tiếp)
- **`link_embed`**: dùng cho iframe/embed (nếu app có chế độ xem embed)

→ Cả hai đều lưu vào DB, theo đúng cấu trúc **episodes** (server → server_data → từng item có `link_embed`, `link_m3u8`).

### 1.3. Cấu trúc DB gợi ý cho phần “cào OPhim”

Document Movie trong MongoDB nên có **episodes** giống OPhim (để một nguồn duy nhất từ cào):

```json
{
  "_id": "...",
  "name": "Kẻ Đánh Cắp Giấc Mơ",
  "slug": "ke-danh-cap-giac-mo",
  "origin_name": "Inception",
  "thumb_url": "...",
  "poster_url": "...",
  "type": "single",
  "year": 2010,
  "source": "OPHIM",
  
  "episodes": [
    {
      "server_name": "Vietsub #1",
      "is_ai": false,
      "server_data": [
        {
          "name": "Full",
          "slug": "full",
          "filename": "Kẻ Đánh Cắp Giấc Mơ",
          "link_embed": "https://vip.opstream11.com/share/...",
          "link_m3u8": "https://vip.opstream11.com/.../index.m3u8"
        }
      ]
    }
  ]
}
```

- **Phim bộ**: `episodes[].server_data` có nhiều phần tử (tập 1, 2, 3, …), mỗi phần tử đều có `link_embed` và `link_m3u8`.
- Tool cào chỉ việc map đúng từ API chi tiết phim `GET /v1/api/phim/{slug}` vào trường `episodes` như trên.

---

## 2. Giai đoạn 2: Custom – FFmpeg → R2 → CDN → DB

### 2.1. Ý tưởng (theo idea-2.md)

- Admin có file **MP4** (tự có bản quyền / nội bộ).
- Dùng **tool** (có thể tích hợp vào admin backend hoặc script riêng):
  1. **FFmpeg**: MP4 → HLS (1 file `.m3u8` + nhiều file `.ts`).
  2. **Upload** toàn bộ folder đó lên **Cloudflare R2**.
  3. Phát qua **Cloudflare CDN** (custom domain hoặc R2 public URL).
  4. **Lưu link** phát cuối cùng (master m3u8) vào DB.

### 2.2. Luồng kỹ thuật

```
MP4 (local / upload)
    → FFmpeg (m3u8 + ts)
    → Upload lên Cloudflare R2
    → CDN (R2 public / custom domain)
    → Lưu URL master.m3u8 vào DB
```

### 2.3. Lưu link custom vào DB như thế nào?

Hợp lý nhất là **tách nguồn phát**:

- **Nguồn từ OPhim** (sau cào): dùng `episodes[].server_data[].link_m3u8` và `link_embed` như trên.
- **Nguồn custom (R2/CDN)**: thêm một tầng “playback source” để app ưu tiên hoặc cho admin chọn.

Hai cách thiết kế:

**Cách A – Thêm trường “custom HLS” (đơn giản)**

- Trong Movie thêm:
  - `custom_hls_url`: string (ví dụ `https://cdn.example.com/videos/phim-01/master.m3u8`)
  - `custom_hls_source`: enum `"R2"` hoặc `"CDN"` (optional, để biết nguồn).
- Logic phát:
  - Nếu `custom_hls_url` có giá trị → ưu tiên phát từ đây (R2/CDN).
  - Ngược lại → phát từ `episodes[].server_data[].link_m3u8` (OPhim đã cào).

**Cách B – Gom mọi nguồn vào “playback sources”**

- Movie có một mảng, ví dụ: `playback_sources`:
  - Mỗi phần tử: `{ "type": "OPHIM" | "R2", "label": "Vietsub #1", "url": "..." }` hoặc phức tạp hơn với `link_m3u8` + `link_embed`.
- OPhim: khi cào, map từ `episodes` sang `playback_sources` (giữ cả m3u8 và embed).
- Custom: sau khi upload R2 và có CDN URL, append (hoặc upsert) một entry `type: "R2"`, `url: "https://.../master.m3u8"`.
- App/Backend chọn nguồn theo rule (ví dụ ưu tiên R2 nếu có).

Đề xuất: **Cách A** đủ dùng và dễ implement:  
cào OPhim → lưu `episodes` (link_m3u8 + link_embed);  
admin custom → set `custom_hls_url` (và tuỳ chọn `custom_hls_source`).

---

## 3. Tóm tắt: Cào data vs Custom

| Giai đoạn | Nguồn | Cách lấy | Lưu vào DB |
|-----------|--------|----------|------------|
| **1 – Cào ban đầu** | OPhim API | Tool ngoài (script) gọi GET, parse JSON | Metadata phim + **episodes** với **link_m3u8** và **link_embed** từng tập (theo SOURCE_FILM 559-560) |
| **2 – Custom (tùy chọn)** | File MP4 của admin | Tool: FFmpeg → m3u8 + ts → upload R2 → CDN | **custom_hls_url** (và có thể **custom_hls_source**) trên cùng document Movie |

- **Một Movie** có thể:
  - Chỉ có `episodes` (100% từ OPhim).
  - Chỉ có `custom_hls_url` (100% nội bộ).
  - Vừa có `episodes` vừa có `custom_hls_url` (backend/app ưu tiên custom khi có).

---

## 4. Gợi ý schema Movie (MongoDB) gộp cả hai giai đoạn

```json
{
  "_id": "ObjectId",
  "name": "string",
  "slug": "string",
  "origin_name": "string",
  "content": "string",
  "thumb_url": "string",
  "poster_url": "string",
  "trailer_url": "string",
  "type": "single | series | hoathinh",
  "status": "string",
  "quality": "string",
  "lang": "string",
  "year": 2025,
  "view": 0,
  "time": "string",
  "episode_current": "string",
  "episode_total": "string",
  "price": 0,
  "access_type": "FREE | PREMIUM | RENTAL",
  "tmdb_rating": 7.5,
  "imdb_rating": 8.8,
  "source": "OPHIM",
  "created_at": "ISODate",
  "updated_at": "ISODate",

  "episodes": [
    {
      "server_name": "Vietsub #1",
      "is_ai": false,
      "server_data": [
        {
          "name": "Full",
          "slug": "full",
          "filename": "string",
          "link_embed": "https://...",
          "link_m3u8": "https://.../index.m3u8"
        }
      ]
    }
  ],

  "custom_hls_url": "https://pub-xxx.r2.dev/videos/phim-01/master.m3u8",
  "custom_hls_source": "R2"
}
```

- **episodes**: dùng cho data **cào từ OPhim** (luôn lưu đủ link_m3u8 + link_embed).
- **custom_hls_url** (+ **custom_hls_source**): dùng cho **custom** sau khi FFmpeg + R2 + CDN.

---

## 5. Tool custom (FFmpeg + R2) – gợi ý

Theo `idea-2.md`:

1. **FFmpeg** (local hoặc VPS):  
   - Input: MP4  
   - Output: thư mục chứa `master.m3u8` + các `*.ts`  
   - Có thể nhiều resolution (360p, 720p, 1080p) nếu cần.

2. **Upload R2**:  
   - Script (Python/Node) dùng AWS S3 API tương thích R2:  
     - Put từng file `.ts` và `.m3u8` vào bucket (ví dụ prefix `videos/{movie_id}/`).

3. **CDN**:  
   - R2 public bucket hoặc custom domain qua Cloudflare CDN → lấy URL dạng:  
     `https://cdn.example.com/videos/phim-01/master.m3u8`.

4. **Cập nhật DB**:  
   - Gọi API admin của movie-service (hoặc cập nhật trực tiếp MongoDB):  
     set `custom_hls_url` = URL master m3u8 (và `custom_hls_source` = "R2").

Anh có thể dùng một script tự chế (Python/Node) để: nhận đường dẫn MP4 (hoặc movie_id) → chạy FFmpeg → upload R2 → gọi API/PATCH movie để lưu link. Không bắt buộc phải đưa FFmpeg vào Spring Boot; có thể là job/CLI riêng.

---

## 6. Kết luận

- **Cào data ban đầu**: tool ngoài cào OPhim → nhét metadata + **episodes** (mỗi tập có **link_m3u8** và **link_embed**) vào DB. Đúng với SOURCE_FILM (559-560).
- **Custom**: admin dùng tool MP4 → FFmpeg → m3u8 + ts → upload R2 → CDN → lưu **custom_hls_url** (và tuỳ chọn custom_hls_source) vào DB; có thể ưu tiên phát từ URL này thay vì link OPhim.

Nếu anh muốn, bước tiếp có thể là: (1) bổ sung model `Episode` / `ServerData` trong movie-service và migration cho `episodes` + `custom_hls_url`, hoặc (2) phác thảo API admin “upload custom HLS” (nhận URL sau khi đã upload R2) để chỉ cần ghi vào DB.
