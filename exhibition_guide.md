---
title: "KỊCH BẢN & HƯỚNG DẪN DEMO: AI PERSONAL STYLIST"
author: 
  - Sinh viên: Đoàn Thế Tín
  - Lớp: Kỹ thuật phần mềm K45
  - MSSV: 4551190056
date: "Bản cập nhật mới nhất - Phiên bản Premium UI"
geometry: "left=2cm,right=2cm,top=2cm,bottom=2cm"
---

# KỊCH BẢN & HƯỚNG DẪN TRÌNH BÀY ĐỒ ÁN
**Dự án: AI Personal Stylist - Trợ lý thời trang cá nhân thông minh**

---

## 1. LỜI MỞ ĐẦU (Gây ấn tượng ban đầu)
- **Chào hỏi:** "Kính chào quý thầy cô và các bạn. Hôm nay, em xin phép trình bày dự án **AI Personal Stylist** – không chỉ là một ứng dụng quản lý tủ đồ, mà còn là một trợ lý thời trang cá nhân thực thụ ứng dụng sức mạnh của Trí tuệ Nhân tạo."
- **Nêu vấn đề:** "Hầu hết chúng ta đều có rất nhiều quần áo, nhưng mỗi buổi sáng vẫn luôn tự hỏi: *'Hôm nay mặc gì?'* Đồng thời, thời trang không chỉ là che chắn, nó là sự tự tin. Ứng dụng này sinh ra để giải quyết trọn vẹn cả hai vấn đề đó."

## 2. NHỮNG ĐIỂM NHẤN CÔNG NGHỆ CHÍNH
- **Đa nền tảng:** Code 1 lần bằng Flutter, chạy mượt mà trên Mobile và Web (đang live trên Firebase Hosting).
- **Core AI:** Ứng dụng tích hợp API của Google Gemini và Llama 3 (qua Groq) mang đến tốc độ phản hồi tính bằng mili-giây và khả năng phân tích ngữ cảnh trang phục thông minh.
- **Trải nghiệm người dùng cao cấp (Premium UI/UX):** Giao diện liên tục được nâng cấp với các xu hướng thiết kế mới nhất như Glassmorphism (Kính mờ), hiệu ứng Gradient sinh động.

---

## 3. KỊCH BẢN DEMO THỰC TẾ (Step-by-step)

### Bước 1: Màn hình Home – Ấn tượng từ ánh nhìn đầu tiên
- **Thao tác:** Mở ứng dụng, dừng lại 3-5 giây ở màn hình Home để Hội đồng quan sát.
- **Lời dẫn:** 
  > *"Ngay khi mở ứng dụng, người dùng được chào đón bởi một giao diện sang trọng. Chú ý phần Header được thiết kế theo phong cách Glassmorphism nổi bật trên nền Gradient Tím-Indigo. Bảng Thời Tiết thông minh (được thiết kế tối giản, tinh tế như các ứng dụng cao cấp) không chỉ báo nhiệt độ mà còn **gợi ý cách mặc đồ** phù hợp. Đặc biệt, ứng dụng sẽ luôn hiển thị một **Trích dẫn thời trang kinh điển** mỗi ngày, mang lại cảm hứng mặc đẹp cho người dùng ngay giây phút đầu tiên."*

### Bước 2: Quản lý Tủ đồ thông minh
- **Thao tác:** Chuyển sang Tab "Tủ đồ", click vào biểu tượng bộ lọc (Filter) và lướt qua danh sách đồ.
- **Lời dẫn:** 
  > *"Với tủ đồ cá nhân, toàn bộ dữ liệu metadata (Màu sắc, Loại đồ, Phong cách, Mùa) được lưu trữ trên Firebase. Các bộ lọc được em thiết kế tối ưu, kết hợp với các Icon logic giúp người dùng phân loại trang phục chỉ bằng 1 chạm."*

### Bước 3: Lên đồ theo sự kiện & Llama 3 AI (Tính năng "Ăn tiền")
- **Thao tác:** Chuyển sang Tab "Phối đồ", nhấn vào "Lên đồ cho sự kiện".
- **Lời dẫn:** 
  > *"Khi chúng ta sắp có một sự kiện quan trọng, AI Personal Stylist sẽ lo phần trang phục. Ở đây có thẻ **Đếm ngược sự kiện** vô cùng trực quan. Chỉ cần nhập nội dung như 'Đi dự tiệc cưới người yêu cũ', Trợ lý AI (với não bộ của Llama 3 / Gemini) sẽ lập tức tổng hợp phân tích thời tiết, phong cách và những món đồ có sẵn để đưa ra một set đồ hoàn hảo nhất. (Demo việc AI gợi ý thành công)."*

### Bước 4: Màn hình Profile tinh tế & Quản lý Sở thích
- **Thao tác:** Chuyển sang Tab "Tôi" (Profile).
- **Lời dẫn:**
  > *"Ở màn hình Cá nhân, các thông số về tủ đồ (Tổng số đồ, Đồ yêu thích) được thống kê rõ ràng. Các cài đặt cá nhân như Giới tính, Phong cách sở thích được thiết kế dưới dạng thẻ (Card) đổ bóng bo góc cực kỳ hiện đại, giúp ứng dụng không hề kém cạnh bất kỳ sản phẩm thương mại nào trên thị trường."*

---

## 4. TẦM NHÌN TƯƠNG LAI (Chốt hạ ấn tượng)
*(Nếu Hội đồng hỏi về hướng phát triển hoặc để tự nói vào cuối buổi)*

- **Dọn Dẹp Tủ Đồ (Wardrobe Cleanup AI):** Ứng dụng sẽ tự động phân tích tần suất mặc, sau đó đưa ra "Chiến dịch Detox tủ đồ", gợi ý bán thanh lý hoặc quyên góp những món đồ đã lâu không chạm tới.
- **Trải nghiệm vuốt Tinder cho Set đồ:** Ứng dụng sẽ đưa ra các gợi ý mix&match mỗi ngày, người dùng chỉ cần vuốt trái (Bỏ qua) hoặc vuốt phải (Thích) để AI học hỏi và ngày càng "bắt đúng gu" hơn.

---
**Chúc buổi thuyết trình thành công rực rỡ! Hãy tự tin vì ứng dụng của bạn hiện tại đã đạt đến độ hoàn thiện rất cao cả về Logic lẫn Thẩm mỹ.**
