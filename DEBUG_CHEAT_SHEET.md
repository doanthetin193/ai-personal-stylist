# 🔍 Debug Cheat Sheet - Tra Nhanh Khi Code

## 📍 Tìm Code Nhanh

### Muốn tìm:
| Cần tìm | Cách tìm |
|---------|----------|
| **Màn hình nào** | Search file `*_screen.dart` |
| **Widget nào** | Search trong `lib/widgets/` |
| **Provider nào xử lý** | Search `Provider` trong file screen |
| **API nào được gọi** | Search trong `lib/services/` |
| **Model có field gì** | Mở `lib/models/` |

### Phím tắt VSCode:
- `Ctrl + P` → Tìm file
- `Ctrl + Shift + F` → Tìm text trong project
- `Ctrl + Click` → Jump to definition
- `Alt + ←` → Quay lại vị trí cũ

---

## 🔧 Debug Từng Feature

### 1. Thêm Quần Áo (Add Item)
**Files quan trọng:**
```
lib/screens/add_item_screen.dart      (UI)
lib/providers/wardrobe_provider.dart   (Logic - method addItemFromBytes)
lib/services/gemini_service.dart       (AI - method analyzeClothingImage)
lib/services/firebase_service.dart     (DB - method addClothingItem)
```

**Breakpoints đặt ở:**
- `add_item_screen.dart:715` → Khi user chọn ảnh
- `wardrobe_provider.dart:167` → Sau khi nén ảnh
- `gemini_service.dart:~160` → Trước gọi AI

**Lỗi thường gặp:**
- ❌ "Failed to load image" → Check file path
- ❌ "AI timeout" → Check API key, network
- ❌ "Firestore error" → Check user logged in

---

### 2. Gợi Ý Outfit (Suggest Outfit)
**Files quan trọng:**
```
lib/screens/outfit_suggest_screen.dart
lib/providers/wardrobe_provider.dart   (method suggestOutfit)
lib/services/gemini_service.dart       (method suggestOutfit)
```

**Debug log:**
```dart
// Thêm vào wardrobe_provider.dart, method suggestOutfit()
print('📦 Items count: ${_items.length}');
print('🌤️ Weather: ${_weather?.description}');
print('🎯 Occasion: $occasion');
```

**Lỗi thường gặp:**
- ❌ "No items" → User chưa thêm đồ vào tủ
- ❌ "Invalid JSON" → AI trả về sai format
- ❌ "Items not found" → AI suggest ID không tồn tại

---

### 3. Chấm Điểm Màu (Color Harmony)
**Files quan trọng:**
```
lib/screens/color_harmony_screen.dart
lib/providers/wardrobe_provider.dart   (method evaluateColorHarmony)
lib/services/gemini_service.dart       (method evaluateColorHarmony)
```

**Debug log:**
```dart
print('Item 1: ${item1.color}, Item 2: ${item2.color}');
print('AI Response: $jsonResponse');
```

---

### 4. Đăng Nhập (Auth)
**Files quan trọng:**
```
lib/screens/login_screen.dart
lib/providers/auth_provider.dart
lib/services/firebase_service.dart    (methods signInWithGoogle, signInWithEmail)
```

**Debug log:**
```dart
// auth_provider.dart
print('🔐 Attempting login...');
print('✅ Logged in: ${user.email}');
```

**Lỗi thường gặp:**
- ❌ "Google Sign-in failed" → Check Firebase config
- ❌ "Network error" → Check internet, Firebase rules

---

## 🐛 Debug Techniques

### 1. Print Debugging (Nhanh nhất)
```dart
// Trước:
final result = await someFunction();

// Sau:
print('🔵 [DEBUG] Before call');
final result = await someFunction();
print('🟢 [DEBUG] Result: $result');
```

### 2. Breakpoint Debugging
```
F9: Toggle breakpoint
F5: Start debugging
F10: Step over
F11: Step into
```

### 3. Widget Inspector
```
Trong VSCode: Ctrl+Shift+P → "Flutter: Open Widget Inspector"
→ Xem tree UI, state của widgets
```

### 4. Network Inspector
```
Flutter DevTools → Network tab
→ Xem API calls, timing
```

---

## 🔥 Hot Reload vs Hot Restart

| | Hot Reload (Ctrl+S) | Hot Restart (Ctrl+Shift+F5) |
|---|---|---|
| **Tốc độ** | < 1s | 3-5s |
| **State** | Giữ nguyên | Reset |
| **Khi nào dùng** | Sửa UI, logic nhỏ | Thay đổi init, state global |

**Rule:** Luôn thử Hot Reload trước!

---

## 📊 Check State Hiện Tại

### Provider State:
```dart
// Trong bất kỳ widget nào:
final wardrobe = context.read<WardrobeProvider>();
print('Items count: ${wardrobe.items.length}');
print('Status: ${wardrobe.status}');
print('Error: ${wardrobe.errorMessage}');
```

### Firebase State:
```dart
final firebase = context.read<FirebaseService>();
print('User: ${firebase.currentUser?.email}');
print('Logged in: ${firebase.isLoggedIn}');
```

---

## 🎯 Common Errors & Solutions

### Error 1: "Provider not found"
```
Lỗi: Could not find the correct Provider<T> above this Widget
Fix: Wrap widget với MultiProvider trong main.dart
```

### Error 2: "API Key invalid"
```
Lỗi: API key not valid. Please pass a valid API key.
Fix: Check lib/utils/api_keys.dart
```

### Error 3: "Firestore permission denied"
```
Lỗi: [cloud_firestore/permission-denied]
Fix: 
1. Check user logged in: firebase.currentUser != null
2. Check Firestore rules trong Firebase Console
```

### Error 4: "setState called after dispose"
```
Lỗi: setState() called after dispose()
Fix: Wrap setState với if (mounted) { ... }
```

### Error 5: "Image not loading"
```
Lỗi: Base64 decode failed
Fix: Check imageBase64 field not null/empty
```

---

## 🚀 Performance Debug

### Check build time:
```dart
@override
Widget build(BuildContext context) {
  final stopwatch = Stopwatch()..start();
  final widget = ... // your widget tree
  print('Build took: ${stopwatch.elapsedMilliseconds}ms');
  return widget;
}
```

### Check Firestore reads:
```
Firebase Console → Firestore → Usage tab
→ Xem số lượng reads/writes
```

### Check AI cost:
```
Google AI Studio → API Keys → Usage
→ Xem số requests
```

---

## 📞 Khi Cần Giúp

1. **Check console log** trước tiên
2. **Copy full error message** → Google
3. **Check file liên quan** trong bảng trên
4. **Thử comment code** để isolate lỗi
5. **Hỏi với context đầy đủ**: Error message + Code snippet + Đã thử gì

---

**💡 Tip:** Bookmark file này, Ctrl+F để tìm nhanh khi debug!
