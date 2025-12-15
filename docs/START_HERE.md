# 🚀 BẮT ĐẦU TỪ ĐÂY

> **Đừng lo!** Tài liệu này sẽ hướng dẫn bạn đọc hiểu project từng bước một.

---

## 🤔 Tại sao bạn thấy khó hiểu?

Vì các file .md kia viết cho người đã biết Flutter. Nếu bạn mới học, hãy đọc theo thứ tự dưới đây.

---

## 📚 LỘ TRÌNH ĐỌC TÀI LIỆU

### ⭐ LEVEL 1: Hiểu app này làm gì (10 phút)

**Mục tiêu:** Hiểu tổng quan app trước khi đọc code

1. Mở app lên chạy thử (`flutter run -d chrome`)
2. Thử các chức năng:
   - Đăng nhập
   - Thêm quần áo (chụp ảnh)
   - Xem AI phân tích
   - Gợi ý outfit

**Sau bước này bạn biết:** App làm được gì

---

### ⭐ LEVEL 2: Hiểu cấu trúc thư mục (15 phút)

**Đọc file:** [ARCHITECTURE.md](ARCHITECTURE.md) - **CHỈ ĐỌC PHẦN 1 & 2**

```
lib/
├── models/      ← Dữ liệu (quần áo, outfit, thời tiết)
├── services/    ← Gọi API (Firebase, Gemini AI)
├── providers/   ← Quản lý state (dữ liệu chung)
├── screens/     ← Các màn hình
├── widgets/     ← Các component nhỏ
└── utils/       ← Tiện ích (màu sắc, helper)
```

**Sau bước này bạn biết:** File nào nằm ở đâu

---

### ⭐ LEVEL 3: Hiểu dữ liệu (20 phút)

**Đọc file:** [MODELS.md](MODELS.md)

**Tập trung vào:** ClothingItem - đây là model chính

```dart
// Đơn giản: 1 món đồ có các thông tin sau
ClothingItem(
  name: "Áo thun trắng",      // Tên
  category: "Áo",              // Loại
  color: "Trắng",              // Màu
  imageBase64: "base64...",    // Ảnh (Base64 encoded)
  // ... các field khác
)
```

**Sau bước này bạn biết:** App lưu dữ liệu gì

---

### ⭐ LEVEL 4: Hiểu luồng dữ liệu (30 phút)

**Đọc file:** [PROVIDERS.md](PROVIDERS.md)

**Tập trung vào sơ đồ này:**

```
User bấm nút → Provider xử lý → Service gọi API → Kết quả về → UI update
```

Ví dụ thêm quần áo:
```
1. User chọn ảnh
2. WardrobeProvider.analyzeWithAI(ảnh)
3. GeminiService.analyzeClothing(ảnh) → gọi Gemini API
4. Gemini trả về: {name, color, category...}
5. Provider lưu vào Firebase
6. UI hiện món đồ mới
```

**Sau bước này bạn biết:** Dữ liệu chạy như thế nào

---

### ⭐ LEVEL 5: Hiểu Services (30 phút)

**Đọc file:** [SERVICES.md](SERVICES.md)

**3 service chính:**

| Service | Làm gì |
|---------|--------|
| FirebaseService | Đăng nhập + Lưu/đọc dữ liệu |
| GeminiService | Gọi AI phân tích ảnh |
| WeatherService | Lấy thời tiết |

**Sau bước này bạn biết:** App gọi API gì, ở đâu

---

### ⭐ LEVEL 6: Hiểu UI (45 phút)

**Đọc file:** [SCREENS.md](SCREENS.md) và [WIDGETS.md](WIDGETS.md)

**9 màn hình chính:**

```
LoginScreen → HomeScreen → [WardrobeScreen, OutfitScreen, ProfileScreen...]
```

**Sau bước này bạn biết:** Các màn hình liên kết với nhau thế nào

---

### ⭐ LEVEL 7: Hiểu AI (30 phút)

**Đọc file:** [AI_INTEGRATION.md](AI_INTEGRATION.md)

**4 tính năng AI:**
1. Phân tích quần áo từ ảnh
2. Gợi ý outfit
3. Chấm điểm hợp màu
4. Gợi ý dọn tủ đồ

**Sau bước này bạn biết:** AI được tích hợp như thế nào

---

### ⭐ LEVEL 8: Hiểu Theme (15 phút)

**Đọc file:** [THEME.md](THEME.md)

**Sau bước này bạn biết:** Màu sắc, font chữ được quản lý ra sao

---

## 🗺️ SƠ ĐỒ TỔNG QUAN

```
┌─────────────────────────────────────────────────────────────┐
│                        USER (Bạn)                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SCREENS (Màn hình)                       │
│  LoginScreen, HomeScreen, WardrobeScreen, AddItemScreen...  │
│                                                             │
│  📱 Hiển thị UI, nhận input từ user                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   PROVIDERS (Quản lý state)                 │
│           AuthProvider, WardrobeProvider                    │
│                                                             │
│  🔄 Xử lý logic, giữ data, thông báo UI update              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SERVICES (Gọi API)                       │
│     FirebaseService, GeminiService, WeatherService          │
│                                                             │
│  ⚙️ Gọi API bên ngoài, xử lý response                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL APIs                            │
│           Firebase, Google Gemini, OpenWeatherMap           │
│                                                             │
│  ☁️ Dịch vụ cloud bên ngoài                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 MẸO ĐỌC CODE HIỆU QUẢ

### 1. Đọc từ trên xuống
```
main.dart → screens → providers → services → models
```

### 2. Trace theo chức năng
Ví dụ muốn hiểu "Thêm quần áo":
```
1. Mở add_item_screen.dart (xem UI)
2. Tìm hàm được gọi khi bấm nút (analyzeWithAI)
3. Mở wardrobe_provider.dart (xem logic)
4. Tìm GeminiService.analyzeClothing (xem gọi API)
5. Xem prompt gửi lên Gemini
```

### 3. Dùng VS Code
- `Ctrl + Click` vào tên hàm → nhảy đến định nghĩa
- `Ctrl + Shift + F` → tìm kiếm toàn bộ project
- `F12` → xem định nghĩa

---

## ✅ CHECKLIST TỰ KIỂM TRA

Sau khi đọc xong, bạn có thể trả lời các câu hỏi này không?

### Level 1-2 (Cơ bản)
- [ ] App này dùng để làm gì?
- [ ] Thư mục `models/` chứa gì?
- [ ] Thư mục `services/` chứa gì?

### Level 3-4 (Trung bình)
- [ ] ClothingItem có những field nào?
- [ ] Provider là gì? Dùng để làm gì?
- [ ] Khi user bấm "Thêm đồ", code chạy như thế nào?

### Level 5-6 (Khá)
- [ ] FirebaseService làm những việc gì?
- [ ] GeminiService gọi API ra sao?
- [ ] Có bao nhiêu màn hình? Kể tên?

### Level 7-8 (Nâng cao)
- [ ] Prompt gửi lên Gemini để phân tích ảnh là gì?
- [ ] App định nghĩa màu chính ở đâu?
- [ ] JSON schema trả về từ AI có cấu trúc thế nào?

---

## 🆘 VẪN KHÔNG HIỂU?

Nếu vẫn thấy khó, hãy:

1. **Chạy app trước** - Xem app hoạt động thế nào
2. **Debug step-by-step** - Đặt breakpoint, chạy từng dòng
3. **Hỏi AI** - Copy đoạn code, hỏi "Đoạn này làm gì?"
4. **Học Flutter cơ bản** - Nếu chưa biết Flutter, học widget/state trước

### Tài liệu Flutter cơ bản
- [Flutter.dev](https://flutter.dev/docs)
- [Dart.dev](https://dart.dev/guides)
- [Provider package](https://pub.dev/packages/provider)

---

## 📖 THỨ TỰ ĐỌC FILE

```
1. START_HERE.md      ← Bạn đang ở đây! ✅
2. ARCHITECTURE.md    ← Cấu trúc tổng quan
3. MODELS.md          ← Dữ liệu
4. PROVIDERS.md       ← State management
5. SERVICES.md        ← API calls
6. SCREENS.md         ← UI screens
7. WIDGETS.md         ← UI components
8. THEME.md           ← Styling
9. AI_INTEGRATION.md  ← Tích hợp AI
```

---

**Chúc bạn học tốt! 🎉**

> Nhớ: Đọc code giống như đọc truyện - phải đọc từ đầu, đừng nhảy lung tung!
