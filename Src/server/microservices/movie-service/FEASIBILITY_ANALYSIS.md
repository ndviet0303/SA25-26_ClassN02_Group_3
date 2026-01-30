# Phân tích tính khả thi: Tool Import OPhim & Tool Mua Bản Quyền

Tài liệu này phân tích tính khả thi của 2 công cụ:
1. **Tool Import Data từ OPhim** (không dùng Feign, chỉ import ban đầu vào DB)
2. **Tool Admin Mua Phim Bản Quyền** (giả lập quy trình từ `idea-movie.md`)

**Luồng video & data chi tiết** (cào OPhim + custom FFmpeg → R2 → CDN): xem **[DATA_AND_VIDEO_FLOW.md](./DATA_AND_VIDEO_FLOW.md)**.

---

## 📋 PHẦN 1: TOOL IMPORT DATA TỪ OPHIM

### 1.1. Mục tiêu

- **Không dùng Feign** để gọi OPhim real-time
- **Chỉ import ban đầu** (one-time hoặc manual sync) từ 13 API OPhim vào MongoDB của movie-service
- Data sau khi import sẽ được quản lý độc lập, có thể chỉnh sửa, thêm metadata (price, accessType, license info)

### 1.2. Tính khả thi: ✅ **CAO**

#### ✅ Ưu điểm

1. **API OPhim công khai**: 13 endpoint trong `SOURCE_FILM.md` đều là GET, không cần auth
2. **Cấu trúc rõ ràng**: Response JSON có format nhất quán (`status`, `data.items`, `data.item`)
3. **Mapping đơn giản**: OPhim fields → Movie entity (xem bảng mapping bên dưới)
4. **Không phụ thuộc runtime**: Import xong, không cần gọi OPhim nữa

#### ⚠️ Thách thức nhỏ

1. **Rate limiting**: OPhim có thể giới hạn request (cần retry + delay)
2. **Data quality**: Một số field có thể null/empty (cần validation)
3. **Conflict**: Slug trùng (cần strategy: skip, update, hoặc rename)

### 1.3. Kiến trúc đề xuất

```
┌─────────────────────────────────────────────────────────────┐
│  Import Tool (CLI hoặc Admin API)                            │
│  - OPhimImportService                                        │
│  - OPhimHttpClient (RestTemplate/WebClient, không Feign)    │
│  - OPhimMapper (OPhim DTO → Movie Entity)                    │
├─────────────────────────────────────────────────────────────┤
│  Movie Service                                               │
│  - MovieRepository (MongoDB)                                 │
│  - CatalogService (validation, conflict handling)            │
└─────────────────────────────────────────────────────────────┘
```

### 1.4. Mapping OPhim → Movie Entity

| OPhim Field | Movie Field | Ghi chú |
|-------------|-------------|---------|
| `_id` | `externalId` (mới) | Lưu ID gốc từ OPhim |
| `name` | `name` | ✅ |
| `origin_name` | `originName` | ✅ |
| `slug` | `slug` | ✅ (unique index) |
| `content` | `content` | Mô tả phim (HTML) |
| `thumb_url` | `thumbUrl` | Relative path |
| `poster_url` | `posterUrl` | Relative path |
| `trailer_url` | `trailerUrl` | ✅ |
| `type` | `type` | single/series/hoathinh |
| `status` | `status` | completed/ongoing |
| `quality` | `quality` | HD/4K |
| `lang` | `lang` | Vietsub/Lồng Tiếng |
| `year` | `year` | ✅ |
| `time` | `time` | "114 phút/tập" |
| `episode_current` | `episodeCurrent` | ✅ |
| `episode_total` | `episodeTotal` | ✅ |
| `tmdb.vote_average` | `tmdbRating` | ✅ |
| `imdb.vote_average` | `imdbRating` | ✅ |
| `category[]` | `category` (mới) | List<Category> embedded |
| `country[]` | `country` (mới) | List<Country> embedded |
| `actor[]` | `actor` (mới) | List<String> |
| `director[]` | `director` (mới) | List<String> |
| `sub_docquyen` | `subDocquyen` (mới) | boolean |
| `chieurap` | `chieuRap` (mới) | boolean |
| **`episodes[]`** | **`episodes`** (mới) | **Quan trọng – xem bên dưới** |
| - | `source` (mới) | Enum: OPHIM |
| - | `price` | Mặc định 0 (FREE) |
| - | `accessType` | Mặc định FREE (admin có thể đổi sau) |

**Episodes (video từ OPhim):** Mỗi phần tử trong `episodes` có `server_name`, `is_ai`, `server_data[]`. Mỗi `server_data` item cần lưu **`link_embed`** và **`link_m3u8`** (theo SOURCE_FILM.md 559-560). Tool cào **bắt buộc** lưu cả hai link này vào DB.

### 1.5. Các bước triển khai

#### Bước 1: Tạo DTO cho OPhim Response

```java
// OPhimMovieDto.java - Map từ JSON response của OPhim
@Data
public class OPhimMovieDto {
    private String _id;
    private String name;
    private String origin_name;
    private String slug;
    private String content;
    private String thumb_url;
    private String poster_url;
    private String trailer_url;
    private String type;
    private String status;
    private String quality;
    private String lang;
    private Integer year;
    private String time;
    private String episode_current;
    private String episode_total;
    private List<CategoryDto> category;
    private List<CountryDto> country;
    private List<String> actor;
    private List<String> director;
    private Boolean sub_docquyen;
    private Boolean chieurap;
    private TmdbDto tmdb;
    private ImdbDto imdb;
    /** Episodes với link_embed + link_m3u8 (SOURCE_FILM 559-560) - bắt buộc lưu khi cào */
    private List<EpisodeDto> episodes;
    // ... getters/setters
}

// EpisodeDto: server_name, is_ai, server_data (List<ServerDataItem>)
// ServerDataItem: name, slug, filename, link_embed, link_m3u8
```

#### Bước 2: Tạo OPhimHttpClient (RestTemplate/WebClient)

```java
@Service
@Slf4j
public class OPhimHttpClient {
    private final RestTemplate restTemplate;
    private final String baseUrl = "https://ophim1.com/v1/api";
    
    public OPhimListResponse getHomeMovies(int page, int limit) {
        String url = baseUrl + "/home?page=" + page + "&limit=" + limit;
        // Call, parse JSON → OPhimListResponse
    }
    
    public OPhimMovieDto getMovieBySlug(String slug) {
        String url = baseUrl + "/phim/" + slug;
        // Call, parse JSON → OPhimMovieDto
    }
    
    // ... các method khác cho 13 API
}
```

#### Bước 3: Tạo OPhimMapper

```java
@Component
public class OPhimMapper {
    public Movie toMovie(OPhimMovieDto ophimDto) {
        return Movie.builder()
            .externalId(ophimDto.get_id())
            .name(ophimDto.getName())
            .originName(ophimDto.getOrigin_name())
            .slug(ophimDto.getSlug())
            .content(ophimDto.getContent())
            .thumbUrl(ophimDto.getThumb_url())
            .posterUrl(ophimDto.getPoster_url())
            .trailerUrl(ophimDto.getTrailer_url())
            .type(ophimDto.getType())
            .status(ophimDto.getStatus())
            .quality(ophimDto.getQuality())
            .lang(ophimDto.getLang())
            .year(ophimDto.getYear())
            .time(ophimDto.getTime())
            .episodeCurrent(ophimDto.getEpisode_current())
            .episodeTotal(ophimDto.getEpisode_total())
            .tmdbRating(ophimDto.getTmdb() != null ? ophimDto.getTmdb().getVote_average() : null)
            .imdbRating(ophimDto.getImdb() != null ? ophimDto.getImdb().getVote_average() : null)
            .source(Movie.Source.OPHIM)
            .price(BigDecimal.ZERO)
            .accessType(Movie.AccessType.FREE)
            .build();
    }
}
```

#### Bước 4: Tạo OPhimImportService

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class OPhimImportService {
    private final OPhimHttpClient ophimClient;
    private final OPhimMapper mapper;
    private final MovieRepository movieRepository;
    private final CatalogService catalogService;
    
    // Import từ trang chủ (home)
    public ImportResult importFromHome(int maxPages) {
        int imported = 0;
        int skipped = 0;
        int errors = 0;
        
        for (int page = 1; page <= maxPages; page++) {
            try {
                OPhimListResponse response = ophimClient.getHomeMovies(page, 24);
                for (OPhimMovieDto dto : response.getData().getItems()) {
                    try {
                        Movie movie = mapper.toMovie(dto);
                        if (movieRepository.existsBySlug(movie.getSlug())) {
                            log.warn("Skipping duplicate slug: {}", movie.getSlug());
                            skipped++;
                            continue;
                        }
                        movieRepository.save(movie);
                        imported++;
                    } catch (Exception e) {
                        log.error("Error importing movie {}: {}", dto.getSlug(), e.getMessage());
                        errors++;
                    }
                }
                // Delay để tránh rate limit
                Thread.sleep(1000);
            } catch (Exception e) {
                log.error("Error fetching page {}: {}", page, e.getMessage());
                errors++;
            }
        }
        
        return ImportResult.builder()
            .imported(imported)
            .skipped(skipped)
            .errors(errors)
            .build();
    }
    
    // Import từ slug cụ thể
    public Movie importBySlug(String slug) {
        OPhimMovieDto dto = ophimClient.getMovieBySlug(slug);
        Movie movie = mapper.toMovie(dto);
        if (movieRepository.existsBySlug(movie.getSlug())) {
            throw new BadRequestException("Movie with slug already exists: " + slug);
        }
        return movieRepository.save(movie);
    }
}
```

#### Bước 5: Tạo Admin API hoặc CLI

**Option A: Admin REST API** (khuyến nghị)

```java
@RestController
@RequestMapping("/api/admin/movies/import")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class MovieImportController {
    private final OPhimImportService importService;
    
    @PostMapping("/home")
    public ResponseEntity<ApiResponse<ImportResult>> importFromHome(
            @RequestParam(defaultValue = "10") int maxPages) {
        ImportResult result = importService.importFromHome(maxPages);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/slug/{slug}")
    public ResponseEntity<ApiResponse<Movie>> importBySlug(@PathVariable String slug) {
        Movie movie = importService.importBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(movie));
    }
}
```

**Option B: Spring Boot CLI Command**

```java
@Component
public class ImportCommand implements CommandLineRunner {
    @Override
    public void run(String... args) {
        if (args.length > 0 && args[0].equals("import-ophim")) {
            // Import logic
        }
    }
}
```

### 1.6. Kết luận Tool Import

| Tiêu chí | Đánh giá |
|----------|----------|
| **Tính khả thi** | ✅ **CAO** - API công khai, mapping rõ ràng |
| **Độ phức tạp** | 🟡 **TRUNG BÌNH** - Cần xử lý pagination, conflict, rate limit |
| **Thời gian** | 2-3 ngày (bao gồm test) |
| **Rủi ro** | 🟢 **THẤP** - Chỉ đọc data, không ảnh hưởng hệ thống hiện tại |

---

## 📋 PHẦN 2: TOOL ADMIN MUA PHIM BẢN QUYỀN

### 2.1. Mục tiêu

Theo `idea-movie.md`, admin cần **giả lập quy trình mua bản quyền từ studio**:
- **HỒI 1**: Ký hợp đồng (metadata: quốc gia, thời gian, thiết bị, DRM)
- **HỒI 2**: Studio giao data (video master, audio, subtitle, metadata)
- **HỒI 3-7**: Ingest, transcode, DRM, CDN (có thể giả lập hoặc bỏ qua)
- **HỒI 8-12**: User xem (đã có trong streaming service)

**Trong thực tế**, tool này sẽ:
1. Admin nhập thông tin hợp đồng (license metadata)
2. Admin upload/link video (hoặc giả lập)
3. Hệ thống cập nhật Movie với license info, chuyển `accessType` → PREMIUM/RENTAL
4. Ghi log audit (ai mua, khi nào, giá bao nhiêu)

### 2.2. Tính khả thi: ✅ **CAO** (với giả lập)

#### ✅ Ưu điểm

1. **Không cần ingest/transcode thật**: Có thể giả lập bằng cách:
   - Link video từ OPhim/CDN khác (tạm thời)
   - Hoặc chỉ lưu metadata license, video sẽ được xử lý sau
2. **Metadata đơn giản**: Chỉ cần thêm fields vào Movie:
   - `licenseRegion`, `licenseStartDate`, `licenseEndDate`
   - `licensePrice`, `purchasedBy`, `purchasedAt`
   - `drmRequired`, `maxResolution`
3. **Audit trail**: Đã có JWT + admin role, có thể log mọi thao tác

#### ⚠️ Thách thức

1. **Video storage**: Nếu muốn lưu video thật → cần S3/MinIO (nằm ngoài scope hiện tại)
2. **DRM**: Cần tích hợp license server (Widevine/FairPlay) → phức tạp
3. **Transcode**: Cần encode farm → rất phức tạp, có thể bỏ qua giai đoạn đầu

### 2.3. Kiến trúc đề xuất (giả lập)

```
┌─────────────────────────────────────────────────────────────┐
│  Admin Tool (REST API)                                      │
│  - LicensePurchaseController                                │
│  - LicensePurchaseService                                   │
│  - LicenseMetadata (DTO)                                   │
├─────────────────────────────────────────────────────────────┤
│  Movie Service                                              │
│  - Movie Entity (+ license fields)                         │
│  - MovieRepository                                          │
│  - AuditLog (mới) - ghi lại mọi purchase                   │
└─────────────────────────────────────────────────────────────┘
```

### 2.4. Mở rộng Movie Entity

Thêm các field sau vào `Movie.java`:

```java
// License & Purchase Info
@Field("license_region")
private List<String> licenseRegion; // ["VN", "US"]

@Field("license_start_date")
private LocalDate licenseStartDate;

@Field("license_end_date")
private LocalDate licenseEndDate;

@Field("license_price")
private BigDecimal licensePrice; // Giá mua từ studio

@Field("purchased_by")
private String purchasedBy; // Admin user ID

@Field("purchased_at")
private LocalDateTime purchasedAt;

@Field("drm_required")
@Builder.Default
private Boolean drmRequired = false;

@Field("max_resolution")
private String maxResolution; // "1080p", "4K"

@Field("video_source_type")
private VideoSourceType videoSourceType; // OPHIM_LINK, S3, CDN

@Field("video_source_url")
private String videoSourceUrl; // Link tạm thời hoặc S3 path

public enum VideoSourceType {
    OPHIM_LINK,  // Link từ OPhim (tạm thời)
    S3,          // S3/MinIO storage
    CDN,         // CDN riêng
    EXTERNAL     // Link external khác
}
```

### 2.5. DTO & API

#### LicensePurchaseRequest.java

```java
@Data
@Builder
public class LicensePurchaseRequest {
    @NotBlank
    private String movieId; // ID phim đã có trong DB
    
    @NotNull
    @Min(0)
    private BigDecimal licensePrice; // Giá mua từ studio
    
    @NotEmpty
    private List<String> licenseRegion; // ["VN"]
    
    @NotNull
    private LocalDate licenseStartDate;
    
    @NotNull
    private LocalDate licenseEndDate;
    
    @Builder.Default
    private Boolean drmRequired = false;
    
    private String maxResolution; // "1080p"
    
    // Video source (tạm thời)
    private VideoSourceType videoSourceType;
    private String videoSourceUrl; // Link từ OPhim hoặc CDN
    
    // Access type sau khi mua
    @NotNull
    private Movie.AccessType accessType; // PREMIUM hoặc RENTAL
}
```

#### LicensePurchaseController.java

```java
@RestController
@RequestMapping("/api/admin/movies/license")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class LicensePurchaseController {
    private final LicensePurchaseService licenseService;
    
    @PostMapping("/purchase")
    public ResponseEntity<ApiResponse<Movie>> purchaseLicense(
            @Valid @RequestBody LicensePurchaseRequest request,
            Authentication auth) {
        String adminId = auth.getName(); // Lấy từ JWT
        Movie movie = licenseService.purchaseLicense(request, adminId);
        return ResponseEntity.ok(ApiResponse.success("License purchased successfully", movie));
    }
    
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<LicensePurchaseHistory>>> getPurchaseHistory() {
        // Lấy lịch sử mua bản quyền
    }
}
```

#### LicensePurchaseService.java

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class LicensePurchaseService {
    private final MovieRepository movieRepository;
    private final AuditLogRepository auditLogRepository; // Mới
    
    @Transactional
    public Movie purchaseLicense(LicensePurchaseRequest request, String adminId) {
        // 1. Validate movie exists
        Movie movie = movieRepository.findById(request.getMovieId())
            .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", request.getMovieId()));
        
        // 2. Validate license dates
        if (request.getLicenseEndDate().isBefore(request.getLicenseStartDate())) {
            throw new BadRequestException("License end date must be after start date");
        }
        
        // 3. Update movie with license info
        movie.setLicensePrice(request.getLicensePrice());
        movie.setLicenseRegion(request.getLicenseRegion());
        movie.setLicenseStartDate(request.getLicenseStartDate());
        movie.setLicenseEndDate(request.getLicenseEndDate());
        movie.setDrmRequired(request.getDrmRequired());
        movie.setMaxResolution(request.getMaxResolution());
        movie.setVideoSourceType(request.getVideoSourceType());
        movie.setVideoSourceUrl(request.getVideoSourceUrl());
        movie.setAccessType(request.getAccessType()); // Chuyển sang PREMIUM/RENTAL
        movie.setPurchasedBy(adminId);
        movie.setPurchasedAt(LocalDateTime.now());
        movie.onUpdate();
        
        // 4. Save movie
        movie = movieRepository.save(movie);
        
        // 5. Log audit
        AuditLog auditLog = AuditLog.builder()
            .action("LICENSE_PURCHASE")
            .entityType("MOVIE")
            .entityId(movie.getId())
            .userId(adminId)
            .metadata(Map.of(
                "licensePrice", request.getLicensePrice().toString(),
                "licenseRegion", String.join(",", request.getLicenseRegion()),
                "accessType", request.getAccessType().name()
            ))
            .createdAt(LocalDateTime.now())
            .build();
        auditLogRepository.save(auditLog);
        
        log.info("License purchased for movie {} by admin {}", movie.getId(), adminId);
        return movie;
    }
}
```

### 2.6. Audit Log Entity (mới)

```java
@Document(collection = "audit_logs")
@Getter
@Setter
@Builder
public class AuditLog {
    @Id
    private String id;
    
    private String action; // LICENSE_PURCHASE, MOVIE_UPDATE, etc.
    private String entityType; // MOVIE, USER, etc.
    private String entityId;
    private String userId; // Admin ID
    private Map<String, String> metadata; // Additional info
    private LocalDateTime createdAt;
}
```

### 2.7. Workflow giả lập (theo idea-movie.md)

| HỒI | Mô tả | Giả lập trong Tool |
|-----|-------|-------------------|
| **HỒI 1** | Ký hợp đồng | Admin nhập `LicensePurchaseRequest` (region, dates, price) |
| **HỒI 2** | Studio giao data | Admin nhập `videoSourceUrl` (link từ OPhim/CDN tạm thời) |
| **HỒI 3-4** | Ingest + Content Vault | **Bỏ qua** (hoặc chỉ log "Video sẽ được ingest sau") |
| **HỒI 5** | Transcode | **Bỏ qua** (giả lập bằng cách dùng link OPhim có sẵn) |
| **HỒI 6** | DRM | **Bỏ qua** (chỉ set `drmRequired=true`, chưa encrypt thật) |
| **HỒI 7** | CDN | **Bỏ qua** (dùng link OPhim/CDN hiện có) |
| **HỒI 8-12** | User xem | Đã có trong `StreamingController` (cần bổ sung check license) |

### 2.8. Bổ sung: Check License khi User xem

Cần update `StreamingService` để check license:

```java
@Service
public class StreamingService {
    public PlaybackResponse getPlaybackInfo(String movieId, String userId) {
        Movie movie = movieRepository.findById(movieId)
            .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", movieId));
        
        // Check license còn hiệu lực
        if (movie.getLicenseEndDate() != null && 
            LocalDate.now().isAfter(movie.getLicenseEndDate())) {
            throw new BadRequestException("Movie license has expired");
        }
        
        // Check region (nếu có)
        // ... (cần thêm user region info)
        
        // Check access type
        if (movie.getAccessType() == Movie.AccessType.PREMIUM) {
            // Check user có premium subscription không
            // ... (gọi customer-service)
        }
        
        // Return playback info
        return PlaybackResponse.builder()
            .manifestUrl(movie.getVideoSourceUrl()) // Tạm thời
            .drmRequired(movie.getDrmRequired())
            .maxResolution(movie.getMaxResolution())
            .build();
    }
}
```

### 2.9. Kết luận Tool Mua Bản Quyền

| Tiêu chí | Đánh giá |
|----------|----------|
| **Tính khả thi** | ✅ **CAO** (với giả lập ingest/transcode/DRM) |
| **Độ phức tạp** | 🟡 **TRUNG BÌNH** - Cần thêm fields, audit log, validation |
| **Thời gian** | 3-4 ngày (bao gồm test) |
| **Rủi ro** | 🟢 **THẤP** - Chỉ metadata, chưa động vào video thật |
| **Mở rộng sau** | Có thể tích hợp S3, transcode service, DRM license server |

---

## 📊 TỔNG KẾT & ROADMAP

### Ưu tiên triển khai

1. **Tool Import OPhim** (2-3 ngày)
   - Tạo OPhimHttpClient, OPhimMapper, OPhimImportService
   - Admin API `/api/admin/movies/import/*`
   - Test với vài phim mẫu

2. **Tool Mua Bản Quyền** (3-4 ngày)
   - Mở rộng Movie entity (license fields)
   - Tạo LicensePurchaseService, AuditLog
   - Admin API `/api/admin/movies/license/*`
   - Update StreamingService để check license

3. **Tích hợp** (1-2 ngày)
   - Import xong → Admin có thể mua bản quyền ngay
   - Test end-to-end workflow

### Lưu ý

- **Video storage**: Hiện tại dùng link OPhim tạm thời. Sau này có thể tích hợp S3/MinIO.
- **DRM**: Chỉ set flag `drmRequired`, chưa encrypt thật. Cần license server (Widevine/FairPlay) để triển khai đầy đủ.
- **Transcode**: Bỏ qua giai đoạn đầu. Có thể tích hợp AWS MediaConvert/GCP Transcoder sau.

---

## 📝 Checklist Implementation

### Tool Import OPhim
- [ ] Tạo OPhimMovieDto, OPhimListResponse DTOs
- [ ] Tạo OPhimHttpClient (RestTemplate/WebClient)
- [ ] Tạo OPhimMapper
- [ ] Tạo OPhimImportService
- [ ] Tạo MovieImportController (admin API)
- [ ] Test import từ home API
- [ ] Test import từ slug cụ thể
- [ ] Xử lý conflict (skip/update)
- [ ] Rate limiting + retry logic

### Tool Mua Bản Quyền
- [ ] Mở rộng Movie entity (license fields)
- [ ] Tạo LicensePurchaseRequest DTO
- [ ] Tạo LicensePurchaseService
- [ ] Tạo LicensePurchaseController (admin API)
- [ ] Tạo AuditLog entity + repository
- [ ] Update StreamingService (check license)
- [ ] Test purchase workflow
- [ ] Test license expiration check

---

**Tài liệu này có thể được cập nhật khi triển khai thực tế.**
