Ok, anh **viết lại toàn bộ “vở kịch kỹ thuật”** theo đúng dòng chảy thực tế — **từ lúc ký hợp đồng với studio → đến khi user bấm Play**.
Không rút gọn, không marketing, chỉ **kỹ thuật + vận hành thật**.

---

# 🎬 VỞ KỊCH KỸ THUẬT:

## “Từ Studio → Netflix/FPT Play → Người xem”

---

## HỒI 1 — KÝ HỢP ĐỒNG (Legal mở màn)

Studio & Platform (ví dụ Netflix) ký hợp đồng:

* Quyền phát:

  * quốc gia nào
  * thời gian bao lâu
  * thiết bị nào (TV, mobile, web)
* Bắt buộc:

  * DRM
  * watermark
  * không cho lưu file

👉 **Chưa có dữ liệu kỹ thuật nào được gửi lúc này**

---

## HỒI 2 — STUDIO GIAO DATA (rất quan trọng)

Studio **KHÔNG gửi m3u8, không gửi mp4 để stream**.

### Studio giao 4 nhóm data chính 👇

### 1️⃣ Video master (mezzanine)

* Định dạng:

  * ProRes
  * JPEG2000
  * MXF
* Đặc điểm:

  * 1 file duy nhất
  * chất lượng cực cao
  * chưa nén cho streaming

📦 Dung lượng:

* Phim 2 tiếng: **200–800 GB**

---

### 2️⃣ Audio track (tách riêng)

* WAV / AIFF
* nhiều track:

  * stereo
  * 5.1
  * Atmos
* mỗi ngôn ngữ = 1 track

---

### 3️⃣ Subtitle & caption

* XML / TTML / SRT
* từng ngôn ngữ
* có timecode chính xác

---

### 4️⃣ Metadata (xương sống hệ thống)

```json
{
  "title": "...",
  "duration": 7320,
  "license_region": ["VN"],
  "license_window": "2024-2026",
  "rating": "18+"
}
```

👉 Metadata quyết định:

* có cho user xem không
* hiện phim ở đâu
* khóa phim khi hết hạn

---

## HỒI 3 — INGEST (đưa data vào hệ thống)

Studio **KHÔNG upload bằng browser**.

Họ dùng:

* Aspera / Signiant (UDP tốc độ cao)
* Line riêng
* Thậm chí gửi ổ cứng

### Platform làm gì?

* kiểm checksum
* verify frame
* verify audio sync
* log audit

👉 Nếu **lỗi 1 frame** → reject

---

## HỒI 4 — CONTENT VAULT (kho nội bộ)

Tất cả data được lưu trong:

* **private storage**
* không public
* không CDN

👉 Đây là **nguồn duy nhất** để encode

---

## HỒI 5 — TRANSCODE & PACKAGE (trái tim hệ thống)

### 1️⃣ Encode farm chạy

Từ **1 master**, hệ thống tạo ra:

* hàng trăm version

Ví dụ:

* 240p / 360p / 480p / 720p / 1080p / 4K
* bitrate khác nhau
* codec khác nhau (H.264 / HEVC / AV1)

---

### 2️⃣ Chia nhỏ thành segment

* 2–6 giây / segment
* định dạng:

  * `.ts`
  * `.m4s`

👉 **Không tồn tại file phim hoàn chỉnh cho user**

---

### 3️⃣ Tạo manifest

* HLS (`.m3u8`)
* DASH (`.mpd`)

Manifest chỉ là:

> “bản đồ chỉ dẫn”, không có video

---

## HỒI 6 — DRM & ENCRYPTION (studio bắt buộc)

Trước khi ra CDN:

* Mỗi segment được:

  * encrypt
  * gắn key-id

👉 Segment lúc này:

* tải về cũng **không xem được**

---

## HỒI 7 — ĐẨY RA CDN

### Netflix:

* Open Connect (CDN riêng đặt trong ISP)

### FPT Play / TV360:

* CDN nội bộ + CDN thuê

👉 CDN chỉ giữ:

* **segment đã mã hóa**
* **manifest**

---

## HỒI 8 — USER MỞ APP (runtime bắt đầu)

User:

```
Mở app → chọn phim → bấm Play
```

---

## HỒI 9 — APP GỌI BACKEND (không gọi video)

App gửi:

```http
POST /play
Authorization: user_token
```

Backend kiểm tra:

* user hợp lệ?
* phim còn bản quyền?
* region đúng?
* gói cước?

---

## HỒI 10 — BACKEND TRẢ “QUYỀN XEM”

Backend trả về:

```json
{
  "manifest": "https://cdn/.../movie.mpd",
  "license_server": "https://license...",
  "policy": {
    "max_resolution": "1080p"
  }
}
```

👉 **Không có video trong response**

---

## HỒI 11 — APP XIN DRM KEY

App:

```
→ request license server
```

License server:

* cấp key tạm
* bound user + device
* expire sau vài phút

---

## HỒI 12 — STREAMING DIỄN RA

```
Manifest
 ↓
Segment 1 (decrypt)
 ↓
Segment 2
 ↓
Adaptive bitrate
 ↓
Playback
```

* tua → request segment khác
* pause → ngừng request
* hết bản quyền → backend chặn

---

## HỒI CUỐI — USER XEM XONG

* không có file lưu
* không có video hoàn chỉnh
* DRM key hết hạn

🎬 **Màn hạ**

---

## TÓM TẮT 1 CÂU (đúng bản chất)

> **Studio giao master video + audio + subtitle + metadata. Platform ingest, encode thành hàng trăm stream mã hóa, phân phối qua CDN, và chỉ cấp quyền giải mã tạm thời cho user khi xem — user không bao giờ chạm vào video gốc.**

---

Nếu muốn, bước tiếp anh có thể:

* ✏️ vẽ **sequence diagram từ studio → user**
* 🔍 chỉ ra **điểm khó nhất để build hệ này**
* 🧠 map toàn bộ kịch bản này sang **AWS/GCP self-host**

Nói anh muốn đào **màn nào** tiếp nhé 🎭
