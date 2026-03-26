# Tài liệu chi tiết: Ràng buộc giới tính, phong cách hồ sơ, và tinh chỉnh prompt AI

## 1) Mục tiêu tài liệu
Tài liệu này ghi lại đầy đủ những gì đã triển khai trong ngày để:
- Hiểu chính xác chức năng đang làm gì.
- Biết rõ file nào chịu trách nhiệm gì.
- Tra cứu được vị trí dòng code để chỉnh sửa nhanh.
- Nắm lý do thiết kế, tác dụng thực tế, và giới hạn hiện tại.
- Dễ bàn giao hoặc tiếp tục nâng cấp ở các phiên làm việc sau.

## 2) Bối cảnh bài toán
### 2.1 Vấn đề trước khi triển khai
Trước đây hệ thống gợi ý outfit có thể đưa ra tổ hợp không hợp lý với bối cảnh người dùng, ví dụ:
- Hồ sơ nam nhưng vẫn có khả năng gợi ý váy/chân váy.
- Tín hiệu phong cách có thể chưa đủ rõ nên AI đôi lúc trả về outfit thiếu ổn định.

### 2.2 Mục tiêu nghiệp vụ
- Bắt buộc người dùng xác định hồ sơ ngay từ lần đầu vào app.
- Cho phép người dùng chọn phong cách hồ sơ để phản ánh đúng gu phối đồ.
- Giảm độ lệch và tăng tính ổn định của AI khi có nhiều tín hiệu cùng lúc.

## 3) Phạm vi đã làm
Đã triển khai đầy đủ 4 lớp:
1. Lớp thu thập hồ sơ người dùng trên giao diện.
2. Lớp lưu và đọc hồ sơ từ Firestore.
3. Lớp ràng buộc logic trong provider trước và sau AI.
4. Lớp prompt engineering để giảm tín hiệu chồng chéo.

Đã sửa thêm lỗi giao diện tràn đáy khi mở bottom sheet trên màn hình nhỏ.

## 4) Danh sách file đã tác động
- [lib/providers/wardrobe_provider.dart](lib/providers/wardrobe_provider.dart)
- [lib/screens/home_screen.dart](lib/screens/home_screen.dart)
- [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart)
- [lib/services/firebase_service.dart](lib/services/firebase_service.dart)
- [lib/services/groq_service.dart](lib/services/groq_service.dart)
- [lib/utils/constants.dart](lib/utils/constants.dart)

## 5) Thiết kế dữ liệu và ý nghĩa từng tín hiệu
### 5.1 Tín hiệu 1: Giới tính hồ sơ
Mục tiêu: mô tả hồ sơ nhận diện cơ bản của người dùng.

Định nghĩa enum tại:
- [lib/providers/wardrobe_provider.dart#L42](lib/providers/wardrobe_provider.dart#L42)

Giá trị hiện có:
- male
- female

### 5.2 Tín hiệu 2: Phong cách hồ sơ
Mục tiêu: mô tả định hướng vibe phối đồ, độc lập với form-fit.

Định nghĩa enum tại:
- [lib/providers/wardrobe_provider.dart#L90](lib/providers/wardrobe_provider.dart#L90)

Giá trị hiện có:
- masculine
- feminine
- unisex
- flexible

### 5.3 Tín hiệu 3: Sở thích phong cách cũ
Mục tiêu: tinh chỉnh form dáng, không quyết định vibe chính.

Định nghĩa enum tại:
- [lib/providers/wardrobe_provider.dart#L14](lib/providers/wardrobe_provider.dart#L14)

Giá trị hiện có:
- loose
- regular
- fitted

Tín hiệu này đã được hạ mức ưu tiên và mô tả rõ là secondary tại:
- [lib/providers/wardrobe_provider.dart#L29](lib/providers/wardrobe_provider.dart#L29)

## 6) Cơ chế lưu trữ Firestore
### 6.1 Collection users
Khai báo collection users tại:
- [lib/utils/constants.dart#L18](lib/utils/constants.dart#L18)

Truy cập users collection trong service:
- [lib/services/firebase_service.dart#L162](lib/services/firebase_service.dart#L162)

### 6.2 Các field đã dùng trong users/{uid}
- gender
- styleProfile
- updatedAt

Các hàm đọc/ghi:
- Đọc gender: [lib/services/firebase_service.dart#L165](lib/services/firebase_service.dart#L165)
- Đọc styleProfile: [lib/services/firebase_service.dart#L205](lib/services/firebase_service.dart#L205)
- Ghi đồng thời gender + styleProfile: [lib/services/firebase_service.dart#L227](lib/services/firebase_service.dart#L227)

Ghi chú tương thích:
- Hàm cũ ghi riêng gender vẫn còn tồn tại để không phá API nội bộ ngay lập tức: [lib/services/firebase_service.dart#L187](lib/services/firebase_service.dart#L187)

## 7) Luồng hoạt động đầu vào hồ sơ người dùng
## 7.1 Luồng bắt buộc lúc vào Home
Kiểm tra đã có đủ hồ sơ chưa:
- [lib/screens/home_screen.dart#L44](lib/screens/home_screen.dart#L44)

Nếu chưa đủ, mở dialog thiết lập:
- [lib/screens/home_screen.dart#L45](lib/screens/home_screen.dart#L45)
- [lib/screens/home_screen.dart#L49](lib/screens/home_screen.dart#L49)

Trong dialog có 2 nhóm chọn:
- Giới tính: [lib/screens/home_screen.dart#L80](lib/screens/home_screen.dart#L80)
- Phong cách hồ sơ: [lib/screens/home_screen.dart#L135](lib/screens/home_screen.dart#L135)

Khi xác nhận sẽ ghi cả 2 thông tin một lần:
- [lib/screens/home_screen.dart#L156](lib/screens/home_screen.dart#L156)

### 7.2 Luồng chỉnh sửa trong Profile
Menu hồ sơ có hai mục riêng:
- Giới tính hồ sơ: [lib/screens/profile_screen.dart#L160](lib/screens/profile_screen.dart#L160)
- Sở thích phong cách cũ: [lib/screens/profile_screen.dart#L169](lib/screens/profile_screen.dart#L169)

Dialog chỉnh hồ sơ giới tính + phong cách mới:
- [lib/screens/profile_screen.dart#L781](lib/screens/profile_screen.dart#L781)

Dialog chỉnh sở thích form-fit cũ:
- [lib/screens/profile_screen.dart#L713](lib/screens/profile_screen.dart#L713)

Hiển thị subtitle tổng hợp giới tính và phong cách hồ sơ:
- [lib/screens/profile_screen.dart#L224](lib/screens/profile_screen.dart#L224)

## 8) Luồng xử lý trong provider trước khi gọi AI
### 8.1 Trạng thái hồ sơ hiệu lực
Cờ đã đủ hồ sơ:
- [lib/providers/wardrobe_provider.dart#L230](lib/providers/wardrobe_provider.dart#L230)

Phong cách hiệu lực (có fallback theo giới tính nếu chưa có styleProfile):
- [lib/providers/wardrobe_provider.dart#L233](lib/providers/wardrobe_provider.dart#L233)

Lý do thiết kế:
- Tránh null gây gãy luồng.
- Luôn có một styleProfile hợp lệ để đưa vào AI.

### 8.2 Nạp và lưu hồ sơ
Nạp từ Firestore vào provider:
- [lib/providers/wardrobe_provider.dart#L419](lib/providers/wardrobe_provider.dart#L419)

Lưu đồng thời identity:
- [lib/providers/wardrobe_provider.dart#L452](lib/providers/wardrobe_provider.dart#L452)

### 8.3 Lọc ràng buộc trước AI
Hàm kiểm tra món đồ có bị hạn chế bởi styleProfile không:
- [lib/providers/wardrobe_provider.dart#L475](lib/providers/wardrobe_provider.dart#L475)

Hiện tại rule cứng đang áp dụng:
- masculine thì hạn chế dress và skirt.

Hàm lọc wardrobe trước khi đưa vào AI:
- [lib/providers/wardrobe_provider.dart#L484](lib/providers/wardrobe_provider.dart#L484)

Chiến lược fallback quan trọng:
- Nếu lọc xong rỗng, trả về lại toàn bộ tủ đồ để tránh fail cứng: [lib/providers/wardrobe_provider.dart#L493](lib/providers/wardrobe_provider.dart#L493)

Ý nghĩa fallback:
- Tránh trải nghiệm bị chặn hoàn toàn khi dữ liệu tủ đồ còn ít.

## 9) Luồng gọi AI và tinh chỉnh prompt
### 9.1 Điểm gọi AI trong provider
Hàm suggestOutfit của provider:
- [lib/providers/wardrobe_provider.dart#L498](lib/providers/wardrobe_provider.dart#L498)

Nơi truyền ba tín hiệu vào service:
- stylePreference: [lib/providers/wardrobe_provider.dart#L519](lib/providers/wardrobe_provider.dart#L519)
- genderProfile: [lib/providers/wardrobe_provider.dart#L520](lib/providers/wardrobe_provider.dart#L520)
- styleProfile: [lib/providers/wardrobe_provider.dart#L521](lib/providers/wardrobe_provider.dart#L521)

### 9.2 Service Groq nhận đủ ba tín hiệu
Chữ ký hàm service:
- [lib/services/groq_service.dart#L103](lib/services/groq_service.dart#L103)

Tham số tín hiệu:
- stylePreference: [lib/services/groq_service.dart#L107](lib/services/groq_service.dart#L107)
- genderProfile: [lib/services/groq_service.dart#L108](lib/services/groq_service.dart#L108)
- styleProfile: [lib/services/groq_service.dart#L109](lib/services/groq_service.dart#L109)

Nơi build prompt:
- [lib/services/groq_service.dart#L127](lib/services/groq_service.dart#L127)

### 9.3 Prompt đã tinh chỉnh chống chồng chéo
Hàm prompt chính:
- [lib/utils/constants.dart#L95](lib/utils/constants.dart#L95)

Ba block tín hiệu trong prompt:
- STYLE PREFERENCE: [lib/utils/constants.dart#L104](lib/utils/constants.dart#L104)
- USER GENDER PROFILE: [lib/utils/constants.dart#L107](lib/utils/constants.dart#L107)
- USER STYLE PROFILE: [lib/utils/constants.dart#L110](lib/utils/constants.dart#L110)

Thứ tự ưu tiên mới trong prompt:
- [lib/utils/constants.dart#L126](lib/utils/constants.dart#L126)
- [lib/utils/constants.dart#L127](lib/utils/constants.dart#L127)
- [lib/utils/constants.dart#L128](lib/utils/constants.dart#L128)
- [lib/utils/constants.dart#L129](lib/utils/constants.dart#L129)

Rule quan trọng để ổn định kết quả:
- styleProfile masculine tránh dress/skirt: [lib/utils/constants.dart#L155](lib/utils/constants.dart#L155)
- styleProfile unisex ưu tiên trung tính: [lib/utils/constants.dart#L156](lib/utils/constants.dart#L156)
- stylePreference chỉ refine fit, không override styleProfile: [lib/utils/constants.dart#L158](lib/utils/constants.dart#L158)

Lý do phải làm thứ tự ưu tiên:
- Nếu không có thứ tự rõ, model dễ bị dao động giữa vibe và fit.
- Khi có mâu thuẫn tín hiệu, model có xu hướng trả kết quả thiếu nhất quán.

## 10) Lớp bảo vệ sau AI
Ngay cả khi AI trả item lệch rule, provider vẫn chặn lại ở bước build outfit:
- [lib/providers/wardrobe_provider.dart#L541](lib/providers/wardrobe_provider.dart#L541)
- [lib/providers/wardrobe_provider.dart#L549](lib/providers/wardrobe_provider.dart#L549)

Tác dụng:
- Không phụ thuộc hoàn toàn vào prompt.
- Có lớp phòng thủ cuối để tránh hiển thị outfit sai trên UI.

## 11) Quan hệ giữa hai loại phong cách
### 11.1 Sở thích phong cách cũ có xung đột với phong cách hồ sơ mới không
Không xung đột nếu hiểu đúng vai trò:
- Phong cách hồ sơ: quyết định vibe chính của outfit.
- Sở thích phong cách cũ: tinh chỉnh độ rộng và độ ôm.

### 11.2 Vì sao cần giữ cả hai
- Chỉ có vibe mà không có fit thì outfit đúng hướng nhưng chưa đúng cảm giác mặc.
- Chỉ có fit mà không có vibe thì outfit có thể hợp form nhưng sai tinh thần.
- Kết hợp cả hai giúp AI gợi ý gần thói quen sử dụng thật hơn.

## 12) Sửa lỗi giao diện trong quá trình triển khai
### 12.1 Lỗi gặp phải
- BOTTOM OVERFLOWED khi mở bottom sheet chọn giới tính và phong cách.

### 12.2 Cách sửa
Ở profile bottom sheet:
- Bật cuộn toàn sheet: [lib/screens/profile_screen.dart#L793](lib/screens/profile_screen.dart#L793)
- Khống chế chiều cao tối đa: [lib/screens/profile_screen.dart#L799](lib/screens/profile_screen.dart#L799)
- Bọc an toàn + cuộn nội dung: [lib/screens/profile_screen.dart#L801](lib/screens/profile_screen.dart#L801), [lib/screens/profile_screen.dart#L810](lib/screens/profile_screen.dart#L810)

Ở dialog khởi tạo home:
- Bọc content bằng SingleChildScrollView: [lib/screens/home_screen.dart#L71](lib/screens/home_screen.dart#L71)

## 13) Kịch bản hoạt động end-to-end
### 13.1 Lần đầu user vào app
1. Home kiểm tra hasIdentityPreferences.
2. Nếu thiếu, buộc mở dialog identity.
3. User chọn gender và styleProfile.
4. App gọi saveIdentityPreferences.
5. Dữ liệu lưu vào users/{uid}.

### 13.2 Khi user bấm gợi ý outfit
1. Provider lấy weather context.
2. Provider lọc wardrobe theo styleProfile.
3. Provider gọi GroqService với 3 tín hiệu.
4. Prompt áp dụng thứ tự ưu tiên rõ ràng.
5. AI trả ID item.
6. Provider build outfit và chặn item trái rule thêm một lần.
7. UI hiển thị outfit cuối.

## 14) Tác dụng thực tế theo từng trường hợp
### 14.1 Hồ sơ Nam tính
- Trước AI: wardrobe có thể bị loại dress/skirt.
- Trong AI: prompt buộc tránh dress/skirt.
- Sau AI: nếu vẫn lọt qua, bị chặn ở provider.

### 14.2 Hồ sơ Unisex
- Không chặn cứng theo giới.
- Prompt ưu tiên đồ trung tính, hạn chế cực đoan.

### 14.3 Hồ sơ Linh hoạt
- Cho phép mix mạnh hơn nếu tổng thể hài hòa.
- Vẫn giữ nguyên logic màu sắc, thời tiết, dịp sử dụng.

## 15) Kiểm thử và xác nhận
Đã chạy kiểm thử tự động:
- flutter test
- Kết quả: 43 trên 43 test pass

Đã kiểm tra compile các file chính không lỗi.

## 16) Giới hạn hiện tại
- Rule cứng theo styleProfile mới chỉ chặn dress/skirt khi masculine.
- Chưa có nhãn giới tính ở cấp từng món đồ.
- Chưa có strict, balanced, flexible mode tách riêng ở cấp policy tổng.

## 17) Đề xuất nâng cấp tiếp theo
1. Bổ sung policy mode strict, balanced, flexible làm lớp điều phối cấp cao.
2. Gắn nhãn item-level theo masculine, feminine, unisex, unknown để lọc chính xác hơn.
3. Thêm feedback sau gợi ý để AI học dần theo phản hồi thực tế người dùng.
4. Bổ sung rules Firestore để chặn dữ liệu bẩn ở tầng server khi sẵn sàng triển khai.

## 18) Ghi chú vận hành và bảo trì
- Không nên đổi tên field gender và styleProfile tùy ý vì sẽ ảnh hưởng dữ liệu đã lưu.
- Nếu đổi enum value, cần chuẩn bị hàm migrate dữ liệu cũ.
- Khi chỉnh prompt, giữ nguyên tinh thần thứ tự ưu tiên để tránh quay lại lỗi tín hiệu chồng chéo.

## 19) Tóm tắt quyết định kiến trúc
- Quyết định 1: Tách rõ identity theo hai trục gender và styleProfile.
- Quyết định 2: Giữ stylePreference cũ nhưng hạ mức ưu tiên thành fit refinement.
- Quyết định 3: Dùng cơ chế phòng thủ nhiều lớp: lọc trước AI, hướng dẫn prompt, chặn sau AI.

Ba quyết định này giúp hệ thống:
- Hợp lý hơn với ngữ cảnh người dùng.
- Ổn định hơn khi AI suy luận.
- An toàn hơn trước các câu trả lời lệch từ model.
