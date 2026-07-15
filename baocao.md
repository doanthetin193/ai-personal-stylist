---
title: "BÁO CÁO ĐỒ ÁN: ỨNG DỤNG AI PERSONAL STYLIST"
author: 
  - Sinh viên thực hiện: Đoàn Thế Tín
  - Lớp: Kỹ thuật phần mềm K45
  - MSSV: 4551190056
date: "Cập nhật mới nhất: Tháng 7/2026"
geometry: margin=2cm
colorlinks: true
---

# TỔNG QUAN DỰ ÁN

**AI Personal Stylist** không chỉ đơn thuần là một tủ đồ số hóa, mà là một trải nghiệm trợ lý thời trang cao cấp (Premium) mang hơi hướng hiện đại, tinh tế. Mục tiêu cốt lõi của ứng dụng là giải quyết triệt để bài toán "Hôm nay mặc gì?" bằng cách kết hợp thông tin thời tiết theo thời gian thực, bối cảnh sự kiện cá nhân và Trí tuệ Nhân tạo (Generative AI).

Giao diện ứng dụng được thiết kế tỉ mỉ, lấy cảm hứng từ các tạp chí thời trang danh tiếng với dải màu gradient mượt mà, hiệu ứng kính (glassmorphism) và sự bố trí tối ưu trải nghiệm người dùng (UX).

---

# CÁC CHỨC NĂNG CỐT LÕI VÀ ĐIỂM NHẤN

## 1. Giao diện "Premium" & Trích dẫn Truyền cảm hứng (Live Quotes)
- Ngay khi người dùng bước vào ứng dụng, họ sẽ được chào đón bằng giao diện gọn gàng cùng một câu nói kinh điển từ các huyền thoại thời trang.
- **Điểm nổi bật**: Câu trích dẫn được tích hợp hệ thống đếm thời gian thực (Timer), tự động chuyển đổi mượt mà mỗi 10 giây, mang lại sức sống và định hình gu thẩm mỹ cao cấp cho người dùng ngay từ cái nhìn đầu tiên.

## 2. Thông tin Thời tiết & Đề xuất Outfit Tức thì
- Ứng dụng tự động lấy vị trí hiện tại và cung cấp thông tin thời tiết (Nhiệt độ, Độ ẩm, Sức gió).
- AI phân tích điều kiện thời tiết để đưa ra lời khuyên trang phục phù hợp (Ví dụ: "Nên mặc đồ thoáng mát" nếu trời nóng).
- Giao diện dạng lưới với các phím tắt (Quick Actions) được thu gọn hợp lý, cho phép thao tác một chạm nhanh chóng.

## 3. Lên Kế Hoạch Sự Kiện (Smart Plan Ahead) & Live Countdown
- Người dùng có thể tạo trước kế hoạch trang phục cho bất kỳ sự kiện nào trong tương lai (Đi làm, Dự tiệc, Cà phê...).
- **Đồng hồ đếm ngược (Live Countdown)**: Thẻ sự kiện sở hữu thiết kế "Badge" nổi bật với icon đồng hồ đếm ngược thời gian (Ngày/Giờ/Phút/Giây) hoạt động liên tục (Live tick). Điều này mang đến trải nghiệm đốc thúc đầy hứng khởi tương tự như việc chờ đón một show diễn thời trang sắp ra mắt.
- Tích hợp tính năng thêm sự kiện trực tiếp vào Google Calendar.

## 4. Dọn Dẹp Tủ Đồ (Wardrobe Cleanup AI)
- Nhận diện những món đồ không còn được sử dụng thường xuyên hoặc lỗi mốt.
- Trợ lý AI sẽ gợi ý các quy tắc loại bỏ hoặc tái chế (Tái sử dụng, Cho tặng, Bán thanh lý) dựa trên phong cách hiện tại, giúp "detox" tủ đồ một cách khoa học nhất.

## 5. Duyệt Đồ Dạng Tinder (Tinder-style Outfit Swiping)
- Một trải nghiệm vuốt (Swipe Right/Left) thú vị để chọn hoặc bỏ qua các set đồ do AI gợi ý. Góp phần khiến ứng dụng trở nên trẻ trung và có tính tương tác cao.

---

# KIẾN TRÚC & CÔNG NGHỆ ÁP DỤNG

1. **Giao diện & Logic Frontend**: Framework Flutter (Ngôn ngữ Dart).
2. **Quản lý trạng thái (State Management)**: Sử dụng mô hình `Provider` để quản lý luồng dữ liệu thời tiết, trạng thái đăng nhập và tủ đồ xuyên suốt ứng dụng.
3. **Trí tuệ Nhân tạo (AI Core)**: Tích hợp mạnh mẽ API của **Google Gemini** và **Llama 3 (via Groq API)** để mang lại phản hồi sinh ngữ nghĩa tự nhiên và chính xác.
4. **Backend & Cloud**:
   - `Firebase Authentication`: Quản lý danh tính người dùng.
   - `Cloud Firestore`: Lưu trữ toàn bộ dữ liệu metadata của quần áo.
   - `Firebase Hosting`: Triển khai trực tiếp phiên bản Web.

---

# TỔNG KẾT

Ứng dụng **AI Personal Stylist** là kết tinh của việc ứng dụng công nghệ GenAI hiện đại kết hợp với nghệ thuật thiết kế giao diện (UI/UX) sắc sảo. Sản phẩm hoàn toàn đáp ứng được nhu cầu cá nhân hóa thời trang của người dùng thời đại số, chứng minh năng lực kỹ thuật và tư duy phát triển sản phẩm thực tiễn của sinh viên.
