# 👔 AI Personal Stylist

Ứng dụng Flutter giúp quản lý tủ đồ thông minh với AI. Sử dụng **Google Gemini AI** để phân tích quần áo và gợi ý phối đồ dựa trên thời tiết, dịp đi, và màu sắc.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)
![Gemini](https://img.shields.io/badge/AI-Gemini%202.0-green?logo=google)

---

## 🎓 Bắt Đầu Học Project

### � Mới vào project? Đọc theo thứ tự:
1. **[LEARNING_GUIDE.md](LEARNING_GUIDE.md)** ← **BẮT ĐẦU Ở ĐÂY!**
   - Chiến lược học bằng thực hành (không phải đọc docs dài)
   - 8 bước từ chạy app → debug → code feature
   - ⏱️ ~2-3 giờ để hiểu toàn bộ flow

2. **[DEBUG_CHEAT_SHEET.md](DEBUG_CHEAT_SHEET.md)** ← Tra nhanh khi code
   - Debug từng feature
   - Common errors & solutions
   - Phím tắt, techniques

3. **[docs/](docs/)** ← Đọc khi cần chi tiết
   - Tham khảo khi gặp code không hiểu
   - Mỗi file ~5-10 phút đọc

---

## ✨ Tính năng chính

### 1. 📸 Thêm quần áo với AI
- Chụp ảnh hoặc chọn từ thư viện
- **AI tự động phân tích**: loại đồ, màu sắc, chất liệu, phong cách
- Lưu vào tủ đồ cá nhân

### 2. 👗 Quản lý tủ đồ
- Xem tất cả quần áo theo danh mục (Áo, Quần, Giày, Phụ kiện...)
- Tìm kiếm, lọc theo loại/màu/phong cách
- Đánh dấu yêu thích

### 3. 🎯 Gợi ý phối đồ thông minh
- Chọn dịp đi (đi làm, hẹn hò, tiệc tùng...)
- AI gợi ý outfit phù hợp từ tủ đồ của bạn
- Tính đến thời tiết hiện tại

### 4. 🎨 Chấm điểm hợp màu
- Chọn 2 món đồ bất kỳ
- AI đánh giá độ hài hòa màu sắc (0-100 điểm)
- Gợi ý cách phối tốt hơn

## 🛠️ Công nghệ sử dụng

| Công nghệ | Mục đích |
|-----------|----------|
| **Flutter 3.9** | Framework phát triển đa nền tảng |
| **Firebase Auth** | Xác thực người dùng (Google, Email, Anonymous) |
| **Cloud Firestore** | Cơ sở dữ liệu NoSQL lưu trữ items |
| **Google Gemini 2.0** | AI phân tích ảnh và gợi ý outfit |
| **Provider** | Quản lý state |
| **OpenWeatherMap** | API lấy thời tiết |

## 📁 Cấu trúc Project

```
ai_personal_stylist/
├── lib/
│   ├── main.dart                 # Entry point, khởi tạo Firebase & Providers
│   ├── firebase_options.dart     # Cấu hình Firebase (auto-generated)
│   │
│   ├── models/                   # Data models
│   │   ├── clothing_item.dart    # Model quần áo
│   │   ├── outfit.dart           # Model outfit/bộ đồ
│   │   └── weather.dart          # Model thời tiết
│   │
│   ├── services/                 # Business logic, API calls
│   │   ├── firebase_service.dart # Auth, Firestore CRUD
│   │   ├── gemini_service.dart   # Google Gemini AI
│   │   └── weather_service.dart  # OpenWeatherMap API
│   │
│   ├── providers/                # State management
│   │   ├── auth_provider.dart    # Trạng thái đăng nhập
│   │   └── wardrobe_provider.dart# Quản lý tủ đồ, gọi AI
│   │
│   ├── screens/                  # UI screens
│   │   ├── login_screen.dart     # Màn hình đăng nhập
│   │   ├── home_screen.dart      # Trang chủ + Bottom navigation
│   │   ├── wardrobe_screen.dart  # Danh sách tủ đồ
│   │   ├── add_item_screen.dart  # Thêm quần áo mới
│   │   ├── item_detail_screen.dart # Chi tiết món đồ
│   │   ├── outfit_suggest_screen.dart # Gợi ý outfit
│   │   ├── color_harmony_screen.dart  # Chấm điểm hợp màu
│   │   └── profile_screen.dart   # Hồ sơ cá nhân
│   │
│   ├── widgets/                  # Reusable UI components
│   │   ├── clothing_card.dart    # Card hiển thị món đồ
│   │   ├── outfit_card.dart      # Card hiển thị outfit
│   │   ├── loading_widgets.dart  # Shimmer loading
│   │   └── common_widgets.dart   # Widgets dùng chung
│   │
│   └── utils/                    # Utilities
│       ├── constants.dart        # App constants, prompts
│       ├── api_keys.dart         # 🔐 API keys (gitignored)
│       ├── api_keys.example.dart # Template cho api_keys.dart
│       ├── theme.dart            # Theme, colors, styles
│       └── helpers.dart          # Helper functions
│
└── docs/                         # 📚 Tài liệu chi tiết
    ├── ARCHITECTURE.md           # Kiến trúc tổng quan
    ├── MODELS.md                 # Data models chi tiết
    ├── PROVIDERS.md              # State management
    ├── SERVICES.md               # Services & APIs
    ├── SCREENS.md                # Các màn hình UI
    ├── WIDGETS.md                # Reusable widgets
    ├── THEME.md                  # Theme & Styling
    └── AI_INTEGRATION.md         # Tích hợp Gemini AI
```

## 🚀 Cài đặt & Chạy

### Yêu cầu
- Flutter SDK 3.9+
- Dart SDK 3.0+
- Firebase project đã cấu hình
- Gemini API key
- OpenWeatherMap API key (optional)

### Bước 1: Clone project
```bash
git clone https://github.com/doanthetin193/ai-personal-stylist.git
cd ai-personal-stylist
```

### Bước 2: Cài dependencies
```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase
1. Tạo project trên [Firebase Console](https://console.firebase.google.com)
2. Bật **Authentication** (Google, Email, Anonymous)
3. Tạo **Firestore Database**
4. Cấu hình **Firestore Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
5. Tạo **Composite Index** cho collection `items`:
   - Field: `userId` (Ascending)
   - Field: `createdAt` (Descending)

### Bước 4: Cấu hình API Keys ⚠️ QUAN TRỌNG

**File `lib/utils/api_keys.dart` đã được gitignore để bảo vệ API keys.**

1. Copy file template:
```bash
cp lib/utils/api_keys.example.dart lib/utils/api_keys.dart
```

2. Mở `lib/utils/api_keys.dart` và điền API keys của bạn:
```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
}
```

3. Lấy API keys tại:
   - **Gemini**: https://aistudio.google.com/app/apikey
   - **Weather**: https://openweathermap.org/api

### Bước 5: Chạy app
```bash
# Chạy trên Chrome (Web)
flutter run -d chrome

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios
```

## 📱 Screenshots

| Trang chủ | Tủ đồ | Gợi ý Outfit |
|-----------|-------|--------------|
| ![Home](screenshots/home.png) | ![Wardrobe](screenshots/wardrobe.png) | ![Outfit](screenshots/outfit.png) |

## 🔑 API Keys cần thiết

### 1. Google Gemini API
1. Vào [Google AI Studio](https://aistudio.google.com/)
2. Click "Get API Key"
3. Tạo key mới

### 2. OpenWeatherMap API (Optional)
1. Đăng ký tại [OpenWeatherMap](https://openweathermap.org/api)
2. Tạo API key miễn phí

## 🤝 Đóng góp

1. Fork project
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 📚 Tài liệu

> **🚀 Mới bắt đầu?** Đọc [START_HERE.md](docs/START_HERE.md) trước!

Xem thư mục `docs/` để đọc tài liệu chi tiết về từng phần của project:

| Tài liệu | Mô tả |
|----------|-------|
| [🚀 START_HERE.md](docs/START_HERE.md) | **Bắt đầu từ đây** - Lộ trình đọc tài liệu |
| [📐 ARCHITECTURE.md](docs/ARCHITECTURE.md) | Kiến trúc tổng quan, data flow, design patterns |
| [📦 MODELS.md](docs/MODELS.md) | Data models: ClothingItem, Outfit, Weather |
| [🔄 PROVIDERS.md](docs/PROVIDERS.md) | State management với Provider pattern |
| [⚙️ SERVICES.md](docs/SERVICES.md) | Firebase, Gemini AI, Weather services |
| [📱 SCREENS.md](docs/SCREENS.md) | Các màn hình UI và navigation flow |
| [🧩 WIDGETS.md](docs/WIDGETS.md) | Reusable UI components |
| [🎨 THEME.md](docs/THEME.md) | Theme system, colors, typography |
| [🤖 AI_INTEGRATION.md](docs/AI_INTEGRATION.md) | Tích hợp Google Gemini AI |

## 👨‍💻 Tác giả

- **Đoàn Thế Tín** - [GitHub](https://github.com/doanthetin193)

---

⭐ Nếu project hữu ích, hãy cho một star nhé!
