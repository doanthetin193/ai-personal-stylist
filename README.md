# 👔 AI Personal Stylist

Ứng dụng Flutter giúp quản lý tủ đồ thông minh với AI. Sử dụng **Groq API** (Llama 4 Scout) để phân tích quần áo và gợi ý phối đồ dựa trên thời tiết, dịp đi, và màu sắc.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)
![Groq](https://img.shields.io/badge/AI-Groq%20Llama%204-green)

---

## 📚 Tài liệu

| File | Mục đích |
|------|----------|
| **[FLOWS.md](FLOWS.md)** | ⭐ Tất cả các luồng xử lý trong app |
| **[AI_INTEGRATION_ISSUES.md](AI_INTEGRATION_ISSUES.md)** | Ghi chú về migration từ Gemini sang Groq |

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

---

## 🛠️ Công nghệ sử dụng

| Công nghệ | Mục đích |
|-----------|----------|
| **Flutter 3.9** | Framework phát triển đa nền tảng |
| **Firebase Auth** | Xác thực người dùng (Google, Email, Anonymous) |
| **Cloud Firestore** | Cơ sở dữ liệu NoSQL lưu trữ items |
| **Groq API** | AI phân tích ảnh và gợi ý outfit (Llama 4 Scout) |
| **Provider** | Quản lý state |
| **OpenWeatherMap** | API lấy thời tiết |

---

## 📁 Cấu trúc Project

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
│
├── models/                   # Data models
│   ├── clothing_item.dart    # Model quần áo
│   ├── outfit.dart           # Model outfit
│   └── weather.dart          # Model thời tiết
│
├── services/                 # API calls
│   ├── firebase_service.dart # Auth, Firestore CRUD
│   ├── groq_service.dart     # ⭐ Groq AI (Llama 4)
│   ├── gemini_service.dart   # (backup - không dùng)
│   └── weather_service.dart  # OpenWeatherMap
│
├── providers/                # State management
│   ├── auth_provider.dart    # Trạng thái đăng nhập
│   └── wardrobe_provider.dart# Quản lý tủ đồ, gọi AI
│
├── screens/                  # UI screens (9 screens)
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── wardrobe_screen.dart
│   ├── add_item_screen.dart
│   ├── item_detail_screen.dart
│   ├── outfit_suggest_screen.dart
│   ├── color_harmony_screen.dart
│   ├── wardrobe_cleanup_screen.dart
│   └── profile_screen.dart
│
├── widgets/                  # Reusable components
│   ├── clothing_card.dart
│   ├── outfit_card.dart
│   ├── loading_widgets.dart
│   └── common_widgets.dart
│
└── utils/                    # Utilities
    ├── constants.dart        # App constants, AI prompts
    ├── api_keys.dart         # 🔐 API keys (gitignored)
    ├── api_keys.example.dart # Template
    ├── theme.dart            # Theme, colors
    └── helpers.dart          # Helper functions
```

---

## 🚀 Cài đặt & Chạy

### Yêu cầu
- Flutter SDK 3.9+
- Dart SDK 3.0+
- Firebase project đã cấu hình
- **Groq API key** (miễn phí tại https://console.groq.com)
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
4. Cấu hình Firestore Rules

### Bước 4: Cấu hình API Keys ⚠️ QUAN TRỌNG

1. Copy file template:
```bash
cp lib/utils/api_keys.example.dart lib/utils/api_keys.dart
```

2. Mở `lib/utils/api_keys.dart` và điền API keys:
```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';  // backup
  static const String groqApiKey = 'gsk_YOUR_GROQ_API_KEY';  // ⭐ dùng cái này
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
}
```

3. Lấy API keys:
   - **Groq**: https://console.groq.com (miễn phí!)
   - **Weather**: https://openweathermap.org/api

### Bước 5: Chạy app
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 🔑 API Keys

### Groq API (Đang dùng)
1. Vào [Groq Console](https://console.groq.com)
2. Đăng ký miễn phí
3. Tạo API key
4. **Free tier:** 30 req/phút, 14,400 req/ngày

### OpenWeatherMap (Optional)
1. Đăng ký tại [OpenWeatherMap](https://openweathermap.org/api)
2. Tạo API key miễn phí

---

## 👨‍💻 Tác giả

- **Đoàn Thế Tín** - [GitHub](https://github.com/doanthetin193)

---

## 📄 License

MIT License

---

⭐ Nếu project hữu ích, hãy cho một star nhé!
