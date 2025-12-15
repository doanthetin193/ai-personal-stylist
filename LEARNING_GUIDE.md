# 🎯 Hướng Dẫn Học Project - Cách Tiếp Cận Thực Hành

> **Chiến lược:** Thay vì đọc docs dài, ta sẽ học bằng cách **CHẠY → QUAN SÁT → PHÂN TÍCH CODE**

---

## 📱 BƯỚC 1: Chạy App & Trải Nghiệm (15 phút)

### Mục tiêu: Hiểu app làm được gì

```bash
flutter run -d chrome
```

**Làm theo checklist này:**

- [ ] **Đăng nhập** (Google hoặc Email test)
- [ ] **Thêm 1 món đồ** (chụp ảnh áo/quần bất kỳ)
  - Quan sát: AI phân tích → tự động điền màu, loại, style
- [ ] **Xem tủ đồ** → danh sách items
- [ ] **Gợi ý outfit** → chọn "Đi làm" → xem AI suggest
- [ ] **Chấm điểm màu** → chọn 2 items → xem AI đánh giá

**✍️ Ghi chú ngay:**
```
- App có mấy màn hình chính? → Đếm tabs bottom nav
- Luồng thêm đồ: Click nút + → Chụp ảnh → ??? → Hiện trong list
- AI xuất hiện ở đâu? → Khi nào gọi API?
```

---

## 🔍 BƯỚC 2: Hiểu Luồng Dữ Liệu Cơ Bản (20 phút)

### Tập trung vào 1 feature: **THÊM QUẦN ÁO**

#### 2.1. Mở file theo thứ tự:

**① Màn hình UI:**
```
lib/screens/add_item_screen.dart
```
- Tìm dòng 715: `final bytes = await File(_pickedFile!.path).readAsBytes();`
- **→ Đọc file ảnh thành bytes**

- Tìm dòng 716: `item = await wardrobeProvider.addItemFromBytes(...)`
- **→ Gọi Provider để xử lý**

**② Provider (Xử lý logic):**
```
lib/providers/wardrobe_provider.dart
```
- Tìm method `addItemFromBytes()` (dòng 150)
- Đọc từng bước trong method này:
  ```dart
  1. Nén ảnh → Base64 (dòng 167)
  2. Gọi AI phân tích (dòng 170-172)
  3. Parse kết quả AI (dòng 174-190)
  4. Tạo ClothingItem object (dòng 192-202)
  5. Lưu vào Firestore (dòng 204)
  ```

**③ Service (Gọi API):**
```
lib/services/gemini_service.dart
```
- Tìm method `analyzeClothingImage()` (dòng ~160)
- Xem prompt gửi cho AI
- Xem format JSON trả về

**④ Model (Cấu trúc dữ liệu):**
```
lib/models/clothing_item.dart
```
- Xem các fields: `id`, `imageBase64`, `type`, `color`, `styles`, `seasons`
- Xem method `toJson()` → cách lưu Firestore
- Xem method `fromJson()` → cách đọc từ Firestore

---

## 📊 BƯỚC 3: Vẽ Sơ Đồ Luồng (10 phút)

### Vẽ tay hoặc dùng paper:

```
┌─────────────────────────────────────────────────────┐
│          FLOW: THÊM QUẦN ÁO                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. User chọn ảnh                                   │
│     └─→ AddItemScreen                              │
│         └─→ ImagePicker.pickImage()                │
│                                                     │
│  2. Đọc ảnh thành bytes                             │
│     └─→ File.readAsBytes()                         │
│                                                     │
│  3. Gọi Provider                                    │
│     └─→ wardrobeProvider.addItemFromBytes()        │
│         │                                           │
│         ├─→ 3a. Nén & convert Base64               │
│         │    └─→ FirebaseService                   │
│         │        .compressAndConvertToBase64()     │
│         │                                           │
│         ├─→ 3b. Gọi AI phân tích                   │
│         │    └─→ GeminiService                     │
│         │        .analyzeClothingImage()           │
│         │        [Gửi: prompt + ảnh]               │
│         │        [Nhận: JSON {type, color...}]     │
│         │                                           │
│         ├─→ 3c. Parse JSON thành Model             │
│         │    └─→ ClothingItem()                    │
│         │                                           │
│         └─→ 3d. Lưu Firestore                      │
│              └─→ FirebaseService                   │
│                  .addClothingItem()                │
│                                                     │
│  4. Cập nhật UI                                     │
│     └─→ notifyListeners()                          │
│         └─→ WardrobeScreen rebuild                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎮 BƯỚC 4: Thực Hành Debug (30 phút)

### Thử sửa code để hiểu:

**① Thay đổi UI:**
```dart
// File: add_item_screen.dart
// Tìm dòng ~80: Text('Thêm vào tủ đồ')
// Sửa thành: Text('UPLOAD ẢNH CỦA BẠN')
// Save → Hot reload → Xem thay đổi
```

**② In log để hiểu flow:**
```dart
// File: wardrobe_provider.dart, method addItemFromBytes()
// Thêm vào đầu method:
print('🔵 [1] Bắt đầu thêm item');

// Sau dòng 167:
print('🔵 [2] Đã nén ảnh: ${imageBase64.length} chars');

// Sau dòng 172:
print('🔵 [3] Đã gọi AI xong');

// Sau dòng 204:
print('🔵 [4] Đã lưu Firestore');
```

**③ Chạy lại & xem Console:**
```
Khi add item, sẽ thấy:
🔵 [1] Bắt đầu thêm item
🖼️ Original image size: 2500.5KB
📦 Image compressed: 2500.5KB → 180.3KB (saved 92.8%)
🔵 [2] Đã nén ảnh: 240654 chars
🔵 [3] Đã gọi AI xong
📝 Preparing to add item to Firestore...
🔵 [4] Đã lưu Firestore
```

**→ Giờ bạn ĐÃ THẤY luồng chạy thật!**

---

## 🗺️ BƯỚC 5: Map Toàn Bộ App (20 phút)

### Dùng bảng này để check từng màn:

| Màn hình | File | Làm gì | Provider dùng | Service gọi |
|----------|------|--------|---------------|-------------|
| **Login** | `login_screen.dart` | Đăng nhập | `AuthProvider` | `FirebaseService` (signIn...) |
| **Home** | `home_screen.dart` | Bottom nav | - | - |
| **Wardrobe** | `wardrobe_screen.dart` | List items | `WardrobeProvider` | `FirebaseService` (getUserItems) |
| **Add Item** | `add_item_screen.dart` | Thêm đồ | `WardrobeProvider` | `GeminiService` + `FirebaseService` |
| **Item Detail** | `item_detail_screen.dart` | Chi tiết | `WardrobeProvider` | - |
| **Suggest Outfit** | `outfit_suggest_screen.dart` | Gợi ý outfit | `WardrobeProvider` | `GeminiService` (suggestOutfit) |
| **Color Harmony** | `color_harmony_screen.dart` | Chấm điểm màu | `WardrobeProvider` | `GeminiService` (evaluateColorHarmony) |
| **Profile** | `profile_screen.dart` | Cài đặt | `AuthProvider` | - |

**Cách dùng bảng:**
- Pick 1 màn → Mở file
- Tìm `onPressed` hoặc `onTap` → Xem gọi Provider gì
- Vào Provider → Xem gọi Service gì
- **Lặp lại với màn khác**

---

## 🧩 BƯỚC 6: Hiểu Patterns Dùng Lại (15 phút)

### App dùng 3 patterns chính:

**① Provider Pattern:**
```dart
// Bất kỳ widget nào cũng có thể:
final provider = context.watch<WardrobeProvider>();
// → Tự động rebuild khi provider thay đổi

provider.addItemFromBytes(...);  // Gọi method
// → Provider gọi Service → Service gọi API → Provider notify → UI rebuild
```

**② Service Pattern:**
```dart
// Provider KHÔNG gọi API trực tiếp
// Provider → Service → API

FirebaseService: Auth, Firestore CRUD, Image compression
GeminiService: AI calls (analyze, suggest, evaluate)
WeatherService: OpenWeatherMap API
```

**③ Model Pattern:**
```dart
// Mọi data đều có Model
ClothingItem → 1 món đồ
Outfit → 1 bộ đồ
WeatherInfo → thông tin thời tiết

// Convert qua lại:
item.toJson() → Lưu Firestore
ClothingItem.fromJson(json) → Đọc từ Firestore
```

---

## 🚀 BƯỚC 7: Thử Thêm Feature Nhỏ (30-60 phút)

### Challenge: Thêm nút "Xóa Tất Cả" vào Wardrobe

**Gợi ý từng bước:**

1. **UI** - Thêm button trong `wardrobe_screen.dart`:
```dart
IconButton(
  icon: Icon(Icons.delete_sweep),
  onPressed: () async {
    // TODO: Gọi Provider
  },
)
```

2. **Provider** - Thêm method trong `wardrobe_provider.dart`:
```dart
Future<void> deleteAllItems() async {
  for (final item in _items) {
    await _firebaseService.deleteClothingItem(item.id);
  }
  _items.clear();
  notifyListeners();
}
```

3. **Test** - Chạy app → Click nút → Xem items biến mất

**→ Giờ bạn đã tự code 1 feature!**

---

## 📚 BƯỚC 8: Đọc Docs (Khi Cần)

**KHÔNG đọc hết docs 1 lúc!** Chỉ đọc khi:

- ❓ Gặp code không hiểu → Mở `docs/ARCHITECTURE.md` tìm phần đó
- 🔧 Muốn customize AI → Mở `docs/AI_INTEGRATION.md`
- 🎨 Muốn sửa UI/theme → Mở `docs/THEME.md`

**Rule:** Đọc 1 section ngắn (5-10 phút) → Ngay lập tức áp dụng vào code

---

## 🎯 Checklist Hoàn Thành

Sau khi làm hết 8 bước, bạn sẽ:

- [ ] Biết app làm được gì (user perspective)
- [ ] Hiểu luồng 1 feature hoàn chỉnh (Add Item)
- [ ] Vẽ được sơ đồ flow
- [ ] Debug được bằng print/log
- [ ] Map được toàn bộ màn hình
- [ ] Hiểu 3 patterns chính (Provider, Service, Model)
- [ ] Tự code được 1 feature nhỏ
- [ ] Biết đọc docs đúng lúc

---

## 💡 Tips Học Nhanh

### ✅ DO:
- Chạy code trước, đọc sau
- Debug bằng `print()` nhiều nhiều
- Vẽ sơ đồ tay (giúp nhớ lâu)
- Sửa code nhỏ → hot reload → xem kết quả
- Tập trung 1 feature mỗi lần

### ❌ DON'T:
- Đọc hết docs mới chạy code
- Nhảy lung tung giữa các files
- Cố nhớ hết 1 lúc
- Sợ sửa code (có Git để rollback)

---

## 🔥 Lộ Trình Đề Xuất

### Tuần 1: Hiểu Core Flow
- Ngày 1-2: BƯỚC 1-4 (Chạy, quan sát, debug)
- Ngày 3-4: BƯỚC 5-6 (Map app, hiểu patterns)
- Ngày 5-7: BƯỚC 7 (Thử code feature)

### Tuần 2: Customize
- Thay đổi UI (màu sắc, layout)
- Thêm field mới vào ClothingItem (vd: price)
- Sửa AI prompt để nhận dạng tốt hơn

### Tuần 3: Advanced
- Hiểu Firebase Security Rules
- Optimize performance
- Thêm feature lớn (vd: Share outfit)

---

## 🆘 Khi Gặp Khó

1. **Không hiểu code?** → In log ra xem
2. **Không biết file nào?** → Search (Ctrl+Shift+F)
3. **Error không hiểu?** → Copy error → Google
4. **Vẫn bí?** → Hỏi trên chat hoặc đọc phần đó trong docs

---

**🎓 Bắt đầu từ BƯỚC 1 ngay!** Đừng đọc hết guide này, hãy làm từng bước một.

Good luck! 🚀
