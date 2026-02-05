# Đặc tả Use Case - Nozie Streaming Platform

Tài liệu này chi tiết hóa 27 Use Case của hệ thống theo mẫu chuẩn.

---

## 1. Identity Service (UC1 - UC8)

### UC1: Register (Đăng ký tài khoản)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đăng ký tài khoản |
| **2. Mã Use Case (ID)** | UC_001 |
| **3. Tác nhân (Actors)** | Khách hàng (Customer) |
| **4. Mô tả tóm tắt** | Cho phép người dùng mới tạo tài khoản trên hệ thống. |
| **5. Tiền điều kiện** | Người dùng truy cập trang đăng ký. |
| **6. Hậu điều kiện** | Tài khoản được tạo, Profile khách hàng được khởi tạo. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhập các thông tin: username, email, password.<br>**Bước 2:** Hệ thống validate dữ liệu.<br>**Bước 3:** Hệ thống kiểm tra xem username/email đã tồn tại chưa.<br>**Bước 4:** Hệ thống hash password và lưu User vào Identity DB.<br>**Bước 5:** Identity Service phát sự kiện `UserRegisteredEvent`.<br>**Bước 6:** Customer Service nhận sự kiện và tạo hồ sơ khách hàng.<br>**Bước 7:** Hệ thống trả về thông báo thành công. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Nếu dữ liệu không hợp lệ, hệ thống báo lỗi.<br>**Tại bước 3:** Nếu username/email đã tồn tại, hệ thống yêu cầu nhập thông tin khác. |
| **10. Quy tắc nghiệp vụ** | Email phải đúng định dạng; Password tối thiểu 8 ký tự. |

---

### UC2: Login via Credentials (Đăng nhập)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đăng nhập hệ thống |
| **2. Mã Use Case (ID)** | UC_002 |
| **3. Tác nhân (Actors)** | Khách hàng, Admin, Staff |
| **4. Mô tả tóm tắt** | Xác thực người dùng bằng username/password. |
| **5. Tiền điều kiện** | Người dùng đã có tài khoản. |
| **6. Hậu điều kiện** | Người dùng nhận được Access Token và Refresh Token. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhập username/email và password.<br>**Bước 2:** Hệ thống kiểm tra thông tin trong Identity DB.<br>**Bước 3:** Hệ thống kiểm tra mật khẩu đã mã hóa.<br>**Bước 4:** Hệ thống sinh Access Token (JWT) và Refresh Token.<br>**Bước 5:** Lưu Refresh Token vào Redis.<br>**Bước 6:** Trả về token và thông tin user. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2, 3:** Nếu thông tin sai, báo lỗi "Invalid credentials". |
| **10. Quy tắc nghiệp vụ** | Password phải khớp với bản hash trong DB. |

---

### UC2.1: Social Auth Login (Đăng nhập mạng xã hội)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đăng nhập qua mạng xã hội |
| **2. Mã Use Case (ID)** | UC_201 |
| **3. Tác nhân (Actors)** | Khách hàng, OAuth Provider (Google/FB) |
| **4. Mô tả tóm tắt** | Đăng nhập nhanh bằng tài khoản Google hoặc Facebook. |
| **5. Tiền điều kiện** | OAuth Provider khả dụng. |
| **6. Hậu điều kiện** | Tài khoản được liên kết hoặc tạo mới, cấp JWT. |
| **7. Luồng chính** | **Bước 1:** Người dùng chọn "Login with Google/FB".<br>**Bước 2:** Hệ thống chuyển hướng tới OAuth Provider.<br>**Bước 3:** Người dùng xác thực với Provider.<br>**Bước 4:** Provider trả về authorization code/token.<br>**Bước 5:** Identity Service xác thực token với Provider.<br>**Bước 6:** Tạo user mới (nếu chưa có) hoặc lấy user hiện tại.<br>**Bước 7:** Cấp JWT cho người dùng. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 5:** Nếu OAuth token không hợp lệ, báo lỗi. |
| **10. Quy tắc nghiệp vụ** | Email từ Provider được dùng làm định danh chính. |

---

### UC2.2: Two-Factor Auth (Xác thực 2 lớp)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xác thực 2 lớp |
| **2. Mã Use Case (ID)** | UC_202 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Yêu cầu thêm mã OTP sau khi đăng nhập cơ bản để tăng bảo mật. |
| **5. Tiền điều kiện** | Tài khoản đã bật 2FA; login cơ bản thành công. |
| **6. Hậu điều kiện** | Hoàn tất đăng nhập, cấp Access Token chính thức. |
| **7. Luồng chính** | **Bước 1:** Hệ thống gửi mã OTP qua Email/SMS.<br>**Bước 2:** Người dùng nhập mã OTP.<br>**Bước 3:** Hệ thống validate mã OTP.<br>**Bước 4:** Cấp JWT hoàn chỉnh và chuyển hướng vào Dashboard. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 3:** Mã OTP sai hoặc hết hạn, báo lỗi và yêu cầu nhập lại hoặc gửi lại mã. |
| **10. Quy tắc nghiệp vụ** | Mã OTP có hiệu lực trong 5 phút; tối đa 5 lần nhập sai. |

---

### UC3: Logout & Revoke Token (Đăng xuất)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đăng xuất hệ thống |
| **2. Mã Use Case (ID)** | UC_003 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Hủy bỏ phiên làm việc hiện tại và thu hồi token. |
| **5. Tiền điều kiện** | Người dùng đang đăng nhập. |
| **6. Hậu điều kiện** | Token hết hiệu lực, session bị xóa. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhấn "Đăng xuất".<br>**Bước 2:** Gửi Refresh Token lên hệ thống.<br>**Bước 3:** Hệ thống xóa Refresh Token trong Redis.<br>**Bước 4:** Đưa Access Token hiện tại vào Blacklist (nếu cần).<br>**Bước 5:** Xóa cookie/token tại Client. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 3:** Nếu Refresh Token không tồn tại, báo lỗi session không hợp lệ. |
| **10. Quy tắc nghiệp vụ** | Token bị thu hồi không thể dùng lại để lấy Access Token mới. |

---

### UC4: Change Password (Đổi mật khẩu)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đổi mật khẩu |
| **2. Mã Use Case (ID)** | UC_004 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Cho phép người dùng cập nhật mật khẩu mới. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Mật khẩu được cập nhật, các session cũ có thể bị đăng xuất. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhập: current password, new password, confirm password.<br>**Bước 2:** Hệ thống kiểm tra current password.<br>**Bước 3:** Hệ thống validate new password.<br>**Bước 4:** Hash mật khẩu mới và cập nhật vào Identity DB.<br>**Bước 5:** Gửi thông báo bảo mật qua email. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Mật khẩu hiện tại sai.<br>**Tại bước 3:** Mật khẩu mới trùng mật khẩu cũ hoặc không mạnh. |
| **10. Quy tắc nghiệp vụ** | Mật khẩu mới không được trùng mật khẩu cũ. |

---

### UC5: Manage User Sessions (Quản lý phiên đăng nhập)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Quản lý phiên đăng nhập |
| **2. Mã Use Case (ID)** | UC_005 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Xem và xóa các thiết bị đang đăng nhập tài khoản. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Phiên đăng nhập được chọn bị thu hồi. |
| **7. Luồng chính** | **Bước 1:** Người dùng truy cập trang "Sessions".<br>**Bước 2:** Hệ thống hiển thị danh sách session (IP, Device, Last Active).<br>**Bước 3:** Người dùng chọn "Revoke" một session cụ thể.<br>**Bước 4:** Hệ thống xóa session đó trong Redis/DB. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Không thể revoke session hiện tại của chính mình qua màn hình này (yêu cầu UC3). |

---

### UC6: Assign Roles/Permissions (Phân quyền)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Gán quyền/vai trò |
| **2. Mã Use Case (ID)** | UC_006 |
| **3. Tác nhân (Actors)** | System Admin |
| **4. Mô tả tóm tắt** | Quản trị tài khoản và cấp quyền cho Staff/Admin khác. |
| **5. Tiền điều kiện** | Admin đăng nhập quyền tối cao. |
| **6. Hậu điều kiện** | Vai trò của user được cập nhật. |
| **7. Luồng chính** | **Bước 1:** Admin tìm kiếm user.<br>**Bước 2:** Admin chọn vai trò (Staff, Admin, Moderator).<br>**Bước 3:** Hệ thống lưu thông tin quyền hạn.<br>**Bước 4:** Ghi log hành động audit. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Chỉ Admin mới có quyền gán vai trò Admin. |

---

### UC7: View System Audit Logs (Xem nhật ký hệ thống)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xem nhật ký hệ thống |
| **2. Mã Use Case (ID)** | UC_007 |
| **3. Tác nhân (Actors)** | System Admin |
| **4. Mô tả tóm tắt** | Theo dõi các hành động nhạy cảm trên hệ thống. |
| **5. Tiền điều kiện** | Admin đăng nhập. |
| **6. Hậu điều kiện** | Danh sách log được hiển thị. |
| **7. Luồng chính** | **Bước 1:** Admin vào mục Audit Logs.<br>**Bước 2:** Filter theo thời gian, user, loại hành động.<br>**Bước 3:** Hệ thống hiển thị chi tiết log. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Audit log không thể bị xóa bởi Admin thường. |

---

### UC8: Enrich User Profile (Cập nhật hồ sơ)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Cập nhật hồ sơ người dùng |
| **2. Mã Use Case (ID)** | UC_008 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Chỉnh sửa thông tin cá nhân. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Thông tin profile được cập nhật. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhấn "Edit Profile".<br>**Bước 2:** Nhập thông tin: avatar, bio, phone.<br>**Bước 3:** Hệ thống lưu vào Identity/Customer DB.<br>**Bước 4:** Trả về status 200. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Avatar quá lớn hoặc sai định dạng. |
| **10. Quy tắc nghiệp vụ** | Không cho phép đổi Email trực tiếp qua UC này (yêu cầu Verify Email mới). |

---

## 2. Movie Service (UC9 - UC16)

### UC9: Browse Movie Catalog (Duyệt danh mục phim)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Duyệt danh mục phim |
| **2. Mã Use Case (ID)** | UC_009 |
| **3. Tác nhân (Actors)** | Khách hàng, Staff |
| **4. Mô tả tóm tắt** | Xem danh sách phim theo các danh mục và bộ lọc khác nhau. |
| **5. Tiền điều kiện** | Không có. |
| **6. Hậu điều kiện** | Danh sách phim được hiển thị cho người dùng. |
| **7. Luồng chính** | **Bước 1:** Người dùng vào trang chủ hoặc trang phim.<br>**Bước 2:** Hệ thống mặc định hiển thị phim Trending/Latest.<br>**Bước 3:** Người dùng chọn filter theo Thể loại, Quốc gia, hoặc Năm.<br>**Bước 4:** Hệ thống truy vấn Movie DB theo filter.<br>**Bước 5:** Trả về danh sách phim có phân trang. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Phân trang mặc định 20 phim/trang. |

---

### UC10: Advanced Search (Tìm kiếm nâng cao)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Tìm kiếm phim |
| **2. Mã Use Case (ID)** | UC_010 |
| **3. Tác nhân (Actors)** | Khách hàng, Staff |
| **4. Mô tả tóm tắt** | Tìm kiếm phim theo từ khóa tên hoặc mô tả. |
| **5. Tiền điều kiện** | Không có. |
| **6. Hậu điều kiện** | Kết quả tìm kiếm được hiển thị. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhập từ khóa vào ô tìm kiếm.<br>**Bước 2:** Hệ thống thực hiện tìm kiếm text-search trong Movie DB.<br>**Bước 3:** Trả về danh sách phim khớp với từ khóa. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 3:** Nếu không tìm thấy, báo "Không tìm thấy phim nào khớp với từ khóa". |
| **10. Quy tắc nghiệp vụ** | Ưu tiên kết quả khớp với tên phim (Name) hơn là mô tả. |

---

### UC11: Watch Movie (Xem phim)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xem phim |
| **2. Mã Use Case (ID)** | UC_011 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Phát phim và các tập phim trực tuyến. |
| **5. Tiền điều kiện** | Người dùng đã chọn phim cụ thể. |
| **6. Hậu điều kiện** | Phát stream video thành công. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhấn "Play".<br>**Bước 2:** Hệ thống kiểm tra quyền xem (Include UC18 - Check Membership).<br>**Bước 3:** Nếu hợp lệ, hệ thống lấy link m3u8 từ CDN/Streaming Server.<br>**Bước 4:** Tăng lượt xem (View Count) của phim.<br>**Bước 5:** Bắt đầu phát video trên Player. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Nếu phim Premium nhưng user chưa mua gói, báo lỗi 403 Forbidden.<br>**Tại bước 3:** Link phim bị chết, báo lỗi "Video source not available". |
| **10. Quy tắc nghiệp vụ** | Phim PREMIUM yêu cầu Subscription active; Phim FREE cho phép khách vãng lai xem. |

---

### UC12: Add to Watchlist (Thêm vào danh sách chờ)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Thêm phim vào danh sách yêu thích |
| **2. Mã Use Case (ID)** | UC_012 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Lưu trữ phim vào danh sách để xem sau. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Phim được lưu vào watchlist của user. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhấn icon "Watchlist" tại phim.<br>**Bước 2:** Hệ thống lưu (UserId, MovieId) vào Customer Service DB.<br>**Bước 3:** Hiển thị thông báo "Đã thêm vào danh sách yêu thích". |
| **8. Luồng thay thế** | **Tại bước 1:** Nếu đã có trong list thì sẽ thực hiện xóa (Toggle). |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Watchlist giới hạn tối đa 200 phim/user. |

---

### UC13: Rate & Review Movie (Đánh giá & Bình luận)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đánh giá và bình luận phim |
| **2. Mã Use Case (ID)** | UC_013 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Gửi điểm đánh giá và nội dung nhận xét về phim. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Đánh giá được hiển thị công khai tại trang phim. |
| **7. Luồng chính** | **Bước 1:** Người dùng chọn số sao (1-10) và viết bình luận.<br>**Bước 2:** Hệ thống lưu review vào Movie DB.<br>**Bước 3:** Hệ thống tính toán lại điểm rating trung bình của phim. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 1:** Bình luận chứa từ ngữ nhạy cảm bị hệ thống lọc hoặc từ chối. |
| **10. Quy tắc nghiệp vụ** | Mỗi user chỉ được rate 1 lần/phim (có thể sửa). |

---

### UC14: Get AI Recommendations (Gợi ý phim)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Nhận gợi ý phim cá nhân hóa |
| **2. Mã Use Case (ID)** | UC_014 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Hệ thống đề xuất phim dựa trên lịch sử xem. |
| **5. Tiền điều kiện** | Người dùng có lịch sử xem phim. |
| **6. Hậu điều kiện** | Danh sách phim gợi ý hiển thị trên trang chủ. |
| **7. Luồng chính** | **Bước 1:** Hệ thống truy vấn lịch sử xem gần đây (Viewing History).<br>**Bước 2:** Phân tích các thể loại (Genres) yêu thích nhất.<br>**Bước 3:** Recommendation Service tìm các phim cùng thể loại có lượt xem cao mà user chưa xem.<br>**Bước 4:** Trả về danh sách đề xuất. |
| **8. Luồng thay thế** | **Nếu user mới:** Trả về danh sách phim Trending hiện tại. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Cập nhật gợi ý mỗi khi người dùng hoàn thành 1 bộ phim mới. |

---

### UC15: Upload & Manage Content (Quản lý nội dung phim)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Quản lý nội dung phim |
| **2. Mã Use Case (ID)** | UC_015 |
| **3. Tác nhân (Actors)** | Staff, Admin |
| **4. Mô tả tóm tắt** | Thêm, sửa, xóa thông tin phim và tập phim. |
| **5. Tiền điều kiện** | Nhân viên đăng nhập quyền quản lý. |
| **6. Hậu điều kiện** | Nội dung phim thay đổi trên hệ thống. |
| **7. Luồng chính** | **Bước 1:** Nhân viên nhập metadata phim (tên, slug, poster, thể loại...).<br>**Bước 2:** Nhập link tập phim (embed, m3u8).<br>**Bước 3:** Hệ thống lưu vào Movie DB.<br>**Bước 4:** Xóa cache nếu phim đã tồn tại trước đó. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 3:** Lỗi lưu file poster hoặc metadata không đầy đủ. |
| **10. Quy tắc nghiệp vụ** | Slug phim phải là duy nhất. |

---

### UC16: Sync Data with TMDB (Đồng bộ metadata)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Đồng bộ dữ liệu phim từ TMDB |
| **2. Mã Use Case (ID)** | UC_016 |
| **3. Tác nhân (Actors)** | Staff |
| **4. Mô tả tóm tắt** | Lấy thông tin phim tự động từ API TMDB để giảm công nhập liệu. |
| **5. Tiền điều kiện** | Nhân viên có ID phim trên TMDB. |
| **6. Hậu điều kiện** | Metadata phim được điền tự động. |
| **7. Luồng chính** | **Bước 1:** Nhân viên nhập TMDB_ID.<br>**Bước 2:** Hệ thống gọi API TMDB lấy thông tin: poster, trailer, diễn viên, nội dung.<br>**Bước 3:** Hệ thống mapping sang model Nozie Movie.<br>**Bước 4:** Hiển thị bản xem trước cho nhân viên xác nhận trước khi lưu. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Không tìm thấy ID trên TMDB. |
| **10. Quy tắc nghiệp vụ** | Đồng bộ không ghi đè link video hiện có trong hệ thống. |

---

## 3. Customer Service (UC17 - UC20)

### UC17: View Subscription Plans (Xem danh sách gói cước)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xem danh sách gói cước |
| **2. Mã Use Case (ID)** | UC_017 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Hiển thị các gói subscription có sẵn để người dùng lựa chọn. |
| **5. Tiền điều kiện** | Không có. |
| **6. Hậu điều kiện** | Người dùng thấy được giá và quyền lợi từng gói. |
| **7. Luồng chính** | **Bước 1:** Người dùng vào trang "Gói cước" hoặc nhấn "Nâng cấp".<br>**Bước 2:** Hệ thống truy vấn danh sách gói từ Payment DB (Subscription Plans).<br>**Bước 3:** Trả về danh sách: Tên gói, Giá, Thời hạn, Quyền lợi. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Giá được hiển thị khớp với cấu hình trên Stripe Dashboard. |

---

### UC18: Check Membership Status (Kiểm tra quyền truy cập)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Kiểm tra trạng thái hội viên |
| **2. Mã Use Case (ID)** | UC_018 |
| **3. Tác nhân (Actors)** | Hệ thống, Khách hàng |
| **4. Mô tả tóm tắt** | Xác định người dùng có đang trong thời hạn gói Premium hay không. |
| **5. Tiền điều kiện** | Hệ thống có UserId. |
| **6. Hậu điều kiện** | Trả về kết quả Boolean (Active/Inactive) và ngày hết hạn. |
| **7. Luồng chính** | **Bước 1:** Hệ thống (Movie Service) gọi Customer Service.<br>**Bước 2:** Customer Service kiểm tra trường `isSubscribed` và `endDate` trong DB.<br>**Bước 3:** Trả về trạng thái hội viên hiện tại. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Nếu không tìm thấy hồ sơ khách hàng, mặc định trả về FREE/Inactive. |
| **10. Quy tắc nghiệp vụ** | Trạng thái được cập nhật ngay lập tức khi nhận Webhook từ Stripe. |

---

### UC19: Track Viewing History (Theo dõi lịch sử xem)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xem lịch sử phim đã xem |
| **2. Mã Use Case (ID)** | UC_019 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Ghi lại và hiển thị các bộ phim người dùng đã phát. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Danh sách phim đã xem được cập nhật. |
| **7. Luồng chính** | **Bước 1:** Khi phim bắt đầu phát, Movie Service gửi command lưu history.<br>**Bước 2:** Customer Service lưu (UserId, MovieId, Timestamp).<br>**Bước 3:** Người dùng vào trang "Lịch sử" để xem lại danh sách. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Nếu lưu history thất bại thì vẫn cho phép xem phim bình thường. |
| **10. Quy tắc nghiệp vụ** | Lịch sử được sắp xếp theo thời gian mới nhất. |

---

### UC20: Manage Membership Rules (Quản lý quy tắc gói)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Quản lý quy tắc hội viên |
| **2. Mã Use Case (ID)** | UC_020 |
| **3. Tác nhân (Actors)** | System Admin |
| **4. Mô tả tóm tắt** | Cấu hình các đặc quyền cho từng loại gói hội viên. |
| **5. Tiền điều kiện** | Admin đăng nhập. |
| **6. Hậu điều kiện** | Logic kiểm soát truy cập thay đổi theo cấu hình mới. |
| **7. Luồng chính** | **Bước 1:** Admin thiết lập quyền xem cho các loại "AccessType" (vd: Phim 4K chỉ cho gói VIP).<br>**Bước 2:** Lưu cấu hình vào Global Config/DB. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Thay đổi quy tắc áp dụng cho tất cả user từ thời điểm lưu. |

---

## 4. Payment & Billing (UC21 - UC24)

### UC21: Checkout & Pay (Thanh toán gói cước)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Thanh toán gói cước |
| **2. Mã Use Case (ID)** | UC_021 |
| **3. Tác nhân (Actors)** | Khách hàng, Stripe |
| **4. Mô tả tóm tắt** | Thực hiện giao dịch mua gói thông qua cổng thanh toán Stripe. |
| **5. Tiền điều kiện** | Người dùng định danh và chọn gói. |
| **6. Hậu điều kiện** | Giao dịch được khởi tạo, chờ thanh toán từ Stripe. |
| **7. Luồng chính** | **Bước 1:** Người dùng nhấn "Mua ngay".<br>**Bước 2:** Payment Service gọi Stripe API tạo Checkout Session.<br>**Bước 3:** Hệ thống trả về Stripe Checkout URL.<br>**Bước 4:** Người dùng thực hiện thanh toán trên giao diện Stripe. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Lỗi kết nối tới Stripe, báo hệ thống bận. |
| **10. Quy tắc nghiệp vụ** | Mỗi session có thời hạn nhất định (thường 24h). |

---

### UC22: Receive Payment Webhook (Xử lý Webhook thanh toán)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xử lý Webhook thanh toán |
| **2. Mã Use Case (ID)** | UC_022 |
| **3. Tác nhân (Actors)** | Stripe Engine, Hệ thống |
| **4. Mô tả tóm tắt** | Hệ thống nhận thông báo kết quả giao dịch từ Stripe để cập nhật quyền hạn. |
| **5. Tiền điều kiện** | Sự kiện thanh toán xảy ra trên Stripe. |
| **6. Hậu điều kiện** | Subscription được kích hoạt, event được gửi đi. |
| **7. Luồng chính** | **Bước 1:** Stripe gửi POST request tới `/api/payments/webhook`.<br>**Bước 2:** Hệ thống xác thực signature của Stripe.<br>**Bước 3:** Nếu là `checkout.session.completed`, hệ thống kích hoạt subscription trong Payment DB.<br>**Bước 4:** Phát sự kiện `SubscriptionActivatedEvent` qua RabbitMQ. |
| **8. Luồng thay thế** | **Nếu là thanh toán thất bại:** Ghi log và có thể gửi email nhắc nhở user. |
| **9. Luồng ngoại lệ** | **Tại bước 2:** Signature không khớp (nghi ngờ giả mạo), từ chối xử lý. |
| **10. Quy tắc nghiệp vụ** | Xử lý Idempotency (đảm bảo 1 event Stripe chỉ xử lý 1 lần). |

---

### UC23: View Billing History (Xem lịch sử hóa đơn)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Xem lịch sử thanh toán |
| **2. Mã Use Case (ID)** | UC_023 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Xem lại các hóa đơn và giao dịch đã thực hiện. |
| **5. Tiền điều kiện** | Người dùng đã đăng nhập. |
| **6. Hậu điều kiện** | Danh sách hóa đơn được hiển thị. |
| **7. Luồng chính** | **Bước 1:** Người dùng vào mục "Hóa đơn/Billing".<br>**Bước 2:** Hệ thống truy vấn lịch sử từ Payment DB theo UserId.<br>**Bước 3:** Trả về: ngày thanh toán, số tiền, gói cước, trạng thái. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Hóa đơn hiển thị từ mới nhất đến cũ nhất. |

---

### UC24: Request Refund (Yêu cầu hoàn tiền)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Yêu cầu hoàn tiền |
| **2. Mã Use Case (ID)** | UC_024 |
| **3. Tác nhân (Actors)** | Khách hàng |
| **4. Mô tả tóm tắt** | Gửi yêu cầu hoàn lại tiền khi gói cước gặp lỗi hoặc không muốn sử dụng. |
| **5. Tiền điều kiện** | Subscription mới mua trong thời gian cho phép. |
| **6. Hậu điều kiện** | Yêu cầu được gửi tới bộ phận chăm sóc khách hàng. |
| **7. Luồng chính** | **Bước 1:** Người dùng chọn đơn hàng cần refund.<br>**Bước 2:** Nhập lý do refund.<br>**Bước 3:** Hệ thống ghi nhận yêu cầu và gửi alert cho Admin. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 1:** Đơn hàng đã quá hạn refund theo policy. |
| **10. Quy tắc nghiệp vụ** | Refund được xem xét thủ công trước khi trigger API Stripe Refund. |

---

## 5. Notification Service (UC25 - UC27)

### UC25: Send Transactional Alert (Gửi thông báo giao dịch)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Gửi thông báo giao dịch |
| **2. Mã Use Case (ID)** | UC_025 |
| **3. Tác nhân (Actors)** | Hệ thống |
| **4. Mô tả tóm tắt** | Tự động gửi email/push khi có các thay đổi quan trọng như thanh toán thành công. |
| **5. Tiền điều kiện** | Có sự kiện phát sinh từ Payment/Identity Service. |
| **6. Hậu điều kiện** | Người dùng nhận được thông báo. |
| **7. Luồng chính** | **Bước 1:** Notification Service lắng nghe sự kiện từ RabbitMQ.<br>**Bước 2:** Lấy template tương ứng (vd: Welcome email, Payment success).<br>**Bước 3:** Thay thế thông tin User vào template.<br>**Bước 4:** Gửi qua SMTP/FCM Gateway. |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | **Tại bước 4:** SMTP Server lỗi, hệ thống đẩy vào hàng đợi retry. |
| **10. Quy tắc nghiệp vụ** | Thông báo giao dịch phải được ưu tiên xử lý trước thông báo marketing. |

---

### UC26: Send Marketing Push (Gửi thông báo quảng cáo)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Gửi thông báo Marketing |
| **2. Mã Use Case (ID)** | UC_026 |
| **3. Tác nhân (Actors)** | System Admin, Staff |
| **4. Mô tả tóm tắt** | Gửi tin nhắn đồng loạt tới người dùng về phim mới hoặc khuyến mãi. |
| **5. Tiền điều kiện** | Nhân viên đăng nhập. |
| **6. Hậu điều kiện** | Các user trong tệp mục tiêu nhận được thông báo. |
| **7. Luồng chính** | **Bước 1:** Nhân viên soạn nội dung thông báo.<br>**Bước 2:** Chọn đối tượng (vd: tất cả user, user free).<br>**Bước 3:** Nhấn "Gửi".<br>**Bước 4:** Hệ thống xử lý gửi theo lô (Batch) để tránh quá tải. |
| **8. Luồng thay thế** | **Hẹn giờ gửi:** Chọn thời điểm gửi trong tương lai. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Phải có tùy chọn để user "Unsubscribe" thông báo marketing. |

---

### UC27: Send Security Alert (Gửi cảnh báo bảo mật)
| Mục (Item) | Nội dung chi tiết (Details) |
| :--- | :--- |
| **1. Tên Use Case** | Gửi cảnh báo bảo mật |
| **2. Mã Use Case (ID)** | UC_027 |
| **3. Tác nhân (Actors)** | Hệ thống |
| **4. Mô tả tóm tắt** | Cảnh báo khi có đăng nhập từ thiết bị lạ hoặc đổi mật khẩu. |
| **5. Tiền điều kiện** | Có sự kiện nhạy cảm từ Identity Service. |
| **6. Hậu điều kiện** | Người dùng nhận cảnh báo tức thời. |
| **7. Luồng chính** | **Bước 1:** Identity Service phát sự kiện `PasswordChanged` hoặc `LoginFromNewDevice`.<br>**Bước 2:** Notification Service nhận event và gửi email cảnh báo ngay lập tức.<br>**Bước 3:** Hướng dẫn user hành động (vd: Nhấn link nếu không phải bạn). |
| **8. Luồng thay thế** | Không có. |
| **9. Luồng ngoại lệ** | Không có. |
| **10. Quy tắc nghiệp vụ** | Cảnh báo bảo mật được gửi tới Email chính chủ ngay cả khi tắt nhận marketing. |
