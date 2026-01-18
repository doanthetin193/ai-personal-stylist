# PHIẾU ĐÁNH GIÁ - NHÓM ....

**Môn:** Một số vấn đề hiện đại CNPM  
**Trưởng nhóm:** ........  
**Đề tài:** AI Personal Stylist - Ứng dụng quản lý tủ đồ thông minh

---

## ĐIỂM ĐÁNH GIÁ (Quy về thang điểm 10)

| Nhóm tiêu chí | Tiêu chí | Mô tả | Điểm tối đa | Ghi chú/Nhận xét |
|---------------|----------|-------|-------------|------------------|
| **0. Tính trung thực** | | Sự thiếu trung thực trong các kết quả báo cáo | 0% | *GV vấn đáp, đánh giá trực tiếp.* |
| **1. Kiến thức tổng quan (5 điểm)** | Kiến thức tổng quan | Có kiến thức tổng quan về kỹ thuật/công nghệ | 5 | *GV vấn đáp, đánh giá trực tiếp.* |
| **2. Xây dựng giao diện (UI) (50 điểm)** | Khả năng sử dụng kiến thức để xây dựng giao diện | Sử dụng tốt các thành phần giao diện cơ bản: Text, Image, Icon, Button, Container, Column, Row, Stack, ListView, GridView, Navigation... | 20 | **Đã sử dụng:** `Scaffold`, `AppBar`, `Container`, `Column`, `Row`, `Stack`, `Text`, `Image`, `Icon`, `ElevatedButton`, `TextButton`, `IconButton`, `OutlinedButton`, `ListView`, `GridView.builder`, `CustomScrollView`, `SliverList`, `SliverToBoxAdapter`, `SliverPadding`, `SliverChildListDelegate`, `BottomNavigationBar`, `Navigator`, `Hero`, `ClipRRect`, `Positioned`, `Positioned.fill`, `CircleAvatar`, `Card`, `Chip`, `RadioListTile`, `RadioGroup`, `TextField`, `AlertDialog`, `ModalBottomSheet`, `DraggableScrollableSheet`, `Consumer`, `Consumer2`, `Provider`, `SafeArea`, `Wrap`, `ListTile`, `GestureDetector`, `InkWell` |
| | | Sử dụng tốt các thành phần Form, Validation | 10 | **Form:** `TextField` với `TextEditingController` trong AddItemScreen (custom occasion), ProfileScreen (đổi tên). **Validation:** Check null trước khi gọi AI (`_item1 != null && _item2 != null`), check empty wardrobe, check occasion selected |
| | | Áp dụng kỹ thuật nâng cao: Animation, Responsive | 10 | **Animation:** `Hero` animation cho ảnh quần áo, `LinearProgressIndicator` cho stats tủ đồ, `CircularProgressIndicator` cho loading, `LinearGradient` cho backgrounds. **Responsive:** `Expanded`, `Flexible`, `AspectRatio`, `SingleChildScrollView`, grid với `crossAxisCount` cố định |
| | Tổng thể về UI/UX | Giao diện ứng dụng đẹp, nhất quán, hợp lý, dễ sử dụng | 10 | *GV vấn đáp, đánh giá trực tiếp.* |
| **3. Nghiệp vụ và Dữ liệu (20 điểm)** | Xây dựng ứng dụng có khả năng lưu trữ, kết nối dữ liệu | Sử dụng kỹ thuật lưu trữ/chia sẻ dữ liệu cục bộ: SharedPreferences, File storage, SQLite... | 5 | **Firebase Auth:** Lưu session đăng nhập với `Persistence.LOCAL` trên Web. **Service Worker:** PWA caching cho offline access. **Base64 String:** Lưu ảnh quần áo dưới dạng Base64 trong Firestore |
| | | Sử dụng kỹ thuật kết nối dữ liệu bên ngoài: Web API, Firebase Firestore... | 5 | **Firebase Firestore:** CRUD quần áo (add/update/delete/deleteAll). **Groq API:** REST API call với HTTP POST, JSON encode/decode. **Weather API:** Lấy thông tin thời tiết để gợi ý outfit. **Google Sign-In:** OAuth 2.0 |
| | Nghiệp vụ | Dự án có tính phức tạp, nhiều chức năng/nghiệp vụ | 10 | *GV vấn đáp, đánh giá trực tiếp.* |
| **4. Nâng cao (15 điểm)** | Áp dụng kỹ thuật/công nghệ nâng cao | Áp dụng kiến thức nâng cao: dịch vụ chạy ngầm... | 5 | **State Management:** Provider pattern với `ChangeNotifier`, `notifyListeners()`. **Async:** `Future`, `async/await`, `StreamBuilder` cho auth. **Image Processing:** `FlutterImageCompress` nén ảnh. **Unit Testing:** 43 tests, 100% pass rate, test Models với `flutter_test` |
| | Sử dụng công nghệ phức tạp, hiện đại | Sử dụng, tích hợp Cloud, AI, thư viện hiện đại | 5 | **AI Integration:** Groq API với LLaMA 3.3 70B: (1) phân tích quần áo, (2) gợi ý outfit, (3) đánh giá hợp màu, (4) gợi ý dọn tủ, (5) kiểm tra ảnh quần áo (is_clothing validation). **Firebase Cloud:** Authentication + Firestore NoSQL. **Prompt Engineering:** Custom prompts cho từng tính năng AI |
| | Triển khai | Có triển khai thử nghiệm trên môi trường: Local / Cloud / Server | 5 | **✅ Đã Deploy:** https://ai-personal-stylist-b1162.web.app. **Firebase Hosting:** App chạy 24/7 trên server Google. **Local:** `flutter run -d chrome`. **PWA:** Progressive Web App với Service Worker |
| **5. Báo cáo & Thuyết trình (10 điểm)** | Chất lượng báo cáo | Báo cáo bằng Slides: khoảng 10 slides, nội dung đầy đủ, logic, định dạng tốt | 5 | *GV vấn đáp, đánh giá trực tiếp.* |
| | Thuyết trình & demo | Trình bày rõ ràng, mạch lạc, trả lời tốt câu hỏi, demo tốt | 5 | *GV vấn đáp, đánh giá trực tiếp.* |

---

## Tóm tắt các tính năng chính:

1. **Đăng nhập:** Google Sign-In, Email/Password, Anonymous
2. **Quản lý tủ đồ:** Thêm, xem, sửa, xóa quần áo với AI phân tích tự động (type, color, style, season)
3. **Gợi ý outfit:** AI gợi ý dựa trên dịp, thời tiết, sở thích phong cách
4. **Đánh giá hợp màu:** AI chấm điểm phối màu 2 món đồ (score, vibe, tips)
5. **Dọn tủ đồ:** AI gợi ý đồ trùng lặp, không phù hợp, tips dọn dẹp
6. **Thống kê:** Xem stats tủ đồ theo loại, đồ mặc nhiều/ít nhất
7. **Profile:** Chỉnh sửa thông tin, chọn style preference (loose/regular/fitted)
8. **Yêu thích:** Đánh dấu và lọc quần áo yêu thích
9. **Đếm số lần mặc:** Theo dõi wearCount cho từng item
10. **Kiểm tra ảnh:** AI phát hiện ảnh không phải quần áo, cảnh báo người dùng

## Công nghệ sử dụng:

- **Framework:** Flutter 3.32+ (Web)
- **State Management:** Provider + ChangeNotifier
- **Backend:** Firebase (Auth + Firestore)
- **AI:** Groq API với LLaMA 3.3 70B Versatile
- **Ngôn ngữ:** Dart
- **Thư viện:** provider, firebase_core, firebase_auth, cloud_firestore, google_sign_in, http, image_picker, flutter_image_compress

## Cấu trúc thư mục:

```
lib/
├── main.dart              # Entry point + AuthWrapper
├── firebase_options.dart  # Firebase config
├── models/                # 3 models
│   ├── clothing_item.dart # ClothingItem + enums (16 ClothingType, 8 ClothingStyle, 4 Season)
│   ├── outfit.dart        # Outfit + ColorHarmonyResult
│   └── weather.dart       # WeatherInfo
├── providers/             # 2 providers
│   ├── auth_provider.dart # AuthStatus enum + AuthProvider
│   └── wardrobe_provider.dart # StylePreference enum + WardrobeProvider
├── screens/               # 9 màn hình
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── wardrobe_screen.dart
│   ├── add_item_screen.dart
│   ├── item_detail_screen.dart
│   ├── outfit_suggest_screen.dart
│   ├── color_harmony_screen.dart
│   ├── profile_screen.dart
│   └── wardrobe_cleanup_screen.dart
├── services/              # 3 services (+ 1 backup)
│   ├── firebase_service.dart   # Auth + Firestore CRUD
│   ├── groq_service.dart       # AI API calls
│   └── weather_service.dart    # OpenWeatherMap API
├── utils/                 # 4 utils
│   ├── theme.dart         # AppTheme (colors, gradients)
│   ├── constants.dart     # AppConstants + AIPrompts
│   ├── helpers.dart       # Helper functions
│   └── api_keys.dart      # API keys config
├── widgets/               # 4 custom widgets
│   ├── clothing_card.dart    # ClothingCard + ClothingImage
│   ├── outfit_card.dart      # OutfitCard
│   ├── common_widgets.dart   # WeatherWidget, SectionHeader...
│   └── loading_widgets.dart  # Shimmer loading effects
└── test/                  # 5 test files, 43 tests
```

**Tổng: 2 config + 3 models + 2 providers + 9 screens + 3 services + 4 utils + 4 widgets = 27+ files Dart**

