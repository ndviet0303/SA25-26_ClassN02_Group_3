# 5.2 Movie Microservice & Database per Service (Lab 5)

Movie Service được triển khai để minh chứng nguyên tắc **Database per Service** trong kiến trúc microservices của Nozie. Service này sở hữu cơ sở dữ liệu riêng, không truy cập trực tiếp vào database của Identity, Customer hay Payment Service, và được client gọi thống nhất qua API Gateway theo route `/api/movies/**`.

## Cơ sở dữ liệu riêng (Own Database)

Movie Service sử dụng kho dữ liệu riêng. Ở môi trường production, cơ sở dữ liệu được khai báo là **MongoDB** thông qua dependency `spring-boot-starter-data-mongodb` trong `pom.xml`. Ở môi trường phát triển local, cấu hình trong `application.yml` có thể ghi đè sang **H2** (in-memory) để chạy mà không cần cài đặt MongoDB. Toàn bộ dữ liệu liên quan đến phim—bao gồm thông tin phim, thể loại, quốc gia, tập phim (episodes) và đánh giá (reviews)—được lưu trữ trong database của Movie Service. Khi cần thông tin người dùng hoặc subscription (ví dụ để kiểm tra quyền xem phim hoặc lấy watchlist), Movie Service gọi đồng bộ tới Customer Service qua **OpenFeign** (chẳng hạn `CustomerClient`), chứ không đọc trực tiếp database của service khác. Cách làm này đảm bảo mỗi microservice sở hữu schema riêng, giảm coupling và cho phép triển khai, mở rộng hoặc thay đổi công nghệ database theo từng service một cách độc lập.

**Figure 5.3** – Movie Service boundary và database riêng (MongoDB); route Gateway `/api/movies/**`.

## API chính (Main APIs)

Các API do Movie Service cung cấp được expose qua API Gateway. Bảng dưới tóm tắt nhóm chức năng và endpoint chính.

| Nhóm | API | Mô tả |
|------|-----|--------|
| **Catalog** | `GET /api/movies` | Danh sách phim có phân trang (pagination) và bộ lọc: `type`, `genre`, `country`, `year`, từ khóa tìm kiếm `q`. |
| | `GET /api/movies/search?q=` | Tìm kiếm theo từ khóa. |
| | `GET /api/movies/{id}`, `GET /api/movies/slug/{slug}` | Chi tiết phim theo ID hoặc slug. |
| | `GET /api/movies/latest`, `/trending`, `/free` | Phim mới cập nhật, thịnh hành, miễn phí. |
| | `GET /api/movies/type/{type}`, `/genre/{slug}`, `/country/{slug}`, `/year/{year}` | Lọc theo loại phim, thể loại, quốc gia, năm. |
| **Metadata** | `GET /api/genres`, `/api/countries`, `/api/years` | Danh sách thể loại, quốc gia và năm (metadata). |
| **Streaming** | `GET /api/movies/{id}/play`, `/slug/{slug}/play` | URL phát với tham số `server`, `episode`; có kiểm soát truy cập (access control). |
| | `GET /api/movies/{id}/episodes`, `/slug/{slug}/episodes` | Danh sách tập (episodes) theo server. |
| | `POST /api/movies/{id}/view`, `/slug/{slug}/view` | Ghi nhận lượt xem. |
| **Recommendation** | `GET /api/recommendations/{userId}`, `/similar/{movieId}`, `/series/{movieId}`, `/trending` | Gợi ý theo user, phim tương tự, series, thịnh hành. |
| **Watchlist** | `GET /api/movies/user/{userId}/watchlist` | Danh sách phim trong watchlist (Movie Service gọi Customer Service qua Feign rồi kết hợp dữ liệu phim). |
| **CRUD (Staff)** | `POST /api/movies`, `PUT /api/movies/{id}`, `DELETE /api/movies/{id}` | Tạo, cập nhật, xóa phim. |
| **Review (UC13)** | `POST /api/movies/{id}/rate`, `GET /api/movies/{id}/reviews` | Gửi đánh giá và xem danh sách review. |

Một số route metadata có thể được Gateway map riêng (ví dụ `/api/genres/**`, `/api/countries/**`, `/api/years/**`) nhưng vẫn do Movie Service xử lý.

## Thành phần bên trong (Components)

Bên trong Movie Service, luồng xử lý tuân theo kiến trúc phân lớp và tổ chức theo nghiệp vụ. **CatalogController** nhận request REST, chuyển cho **CatalogService**, và CatalogService sử dụng **MovieRepository** cùng **MovieRepositoryCustom** để truy vấn MongoDB; nghiệp vụ catalog bao gồm danh sách phim, bộ lọc, phân trang, tìm kiếm, chi tiết theo id/slug, metadata genres/countries/years, và lấy danh sách phim watchlist theo user (kết hợp Feign **CustomerClient**). **StreamingController** ủy thác cho **StreamingService** và **AccessControlService** để cung cấp URL phát (`/play`), danh sách episodes và ghi nhận lượt xem; kiểm soát truy cập có thể dựa trên subscription hoặc membership thông qua gọi Feign tới Customer hoặc Payment Service khi cần. **RecommendationController** sử dụng **RecommendationService** để cung cấp gợi ý theo user, phim tương tự, series và trending; dữ liệu xem/lịch sử có thể lấy từ Customer Service qua Feign. Tóm lại, mọi luồng đều đi theo Controller → Service → Repository (và Feign client khi cần giao tiếp với service khác), và không có truy cập trực tiếp vào database của service khác.

## Kiểm thử độc lập (Isolation Testing)

Để xác nhận Movie Service chạy độc lập và không phụ thuộc trực tiếp vào database của các service khác, nhóm đã thực hiện kiểm thử isolation bằng cách gọi API trực tiếp tới Movie Service (ví dụ `http://localhost:8081/api/movies`) hoặc qua API Gateway (ví dụ `http://localhost:8080/api/movies`). Các request tiêu biểu gồm `GET /api/movies?page=0&size=10` và `GET /api/movies/{id}` (hoặc `GET /api/movies/slug/{slug}`). Công cụ sử dụng là Postman hoặc Bruno (có thể thay bằng curl). Kết quả kỳ vọng là HTTP 200 với body JSON chứa danh sách phim hoặc chi tiết phim; khi gọi qua Gateway, request được định tuyến đúng tới `movie-service` thông qua Eureka. Việc ghi lại request/response và screenshot được dùng làm minh chứng trong báo cáo.

**Figure 5.9** – Screenshot Postman/Bruno: request `GET /api/movies` hoặc `GET /api/movies/{id}` và response.

Kết luận, Movie Service triển khai đúng mô hình Database per Service với MongoDB (hoặc H2 cho môi trường dev), cung cấp đầy đủ API catalog, streaming và recommendation qua Gateway. Kiểm thử isolation với `GET /api/movies` và `GET /api/movies/{id}` chứng minh service chạy độc lập và không phụ thuộc trực tiếp vào database của các service khác.
