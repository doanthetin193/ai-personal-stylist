# 📚 Kiến thức Services trong AI Personal Stylist

> Tài liệu tóm tắt từ buổi học ngày 25/12/2024

---

## 🔥 Firebase Authentication

### Khái niệm chính

| Khái niệm | Giải thích |
|-----------|------------|
| `FirebaseAuth.instance` | Singleton để truy cập Firebase Auth |
| `User` | Object chứa thông tin user (uid, email, displayName...) |
| `UserCredential` | Kết quả trả về sau khi đăng nhập thành công, chứa `user` |
| `authStateChanges()` | Stream tự động emit khi user login/logout |
| `setPersistence()` | Giữ session đăng nhập (trên Web dùng localStorage) |

### Firebase SDK cung cấp sẵn methods

```dart
// Ta chỉ "bọc" lại, không tự code
_auth.signInWithEmailAndPassword(email, password)
_auth.signInAnonymously()
_auth.signInWithPopup(googleProvider)
_auth.signOut()
_auth.authStateChanges()  // Stream<User?>
```

### authStateChanges() - Stream hoạt động như nào?

```dart
// Gọi 1 LẦN khi khởi tạo
_firebaseService.authStateChanges.listen((user) {
  // Code này chạy NHIỀU LẦN - mỗi khi auth state thay đổi
  // - App start (check session cũ)
  // - User login → emit User
  // - User logout → emit null
});
```

### Token tự động refresh

- Firebase SDK **tự động** refresh token trước khi hết hạn
- User **hiếm khi** phải đăng nhập lại (khác với JWT tự quản lý)
- Token hết hạn → `authStateChanges()` emit `null` → UI chuyển về LoginScreen

### Firebase.initializeApp()

```dart
// main.dart - BẮT BUỘC gọi trước khi dùng Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Config (API key, project ID) từ firebase_options.dart
}
```

---

## 📦 Cloud Firestore

### Cấu trúc dữ liệu

```
Firestore Database
└── items (Collection)
    ├── doc_abc123 (Document)
    │   ├── userId: "user_xyz"
    │   ├── type: "tshirt"
    │   ├── color: "trắng"
    │   ├── imageBase64: "/9j/4AAQ..."  (~270KB)
    │   └── ...
```

### CRUD Operations

```dart
// CREATE - Thêm document (Firestore tự tạo ID)
final docRef = await _itemsRef.add(item.toJson());

// READ - Query với điều kiện
final snapshot = await _itemsRef
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .get();

// UPDATE - Cập nhật fields
await _itemsRef.doc(itemId).update({'isFavorite': true});
await _itemsRef.doc(itemId).update({'wearCount': FieldValue.increment(1)});

// DELETE
await _itemsRef.doc(itemId).delete();
```

### Tại sao lưu ảnh bằng Base64 thay vì Cloud Storage?

| | Cloud Storage | Base64 (App này dùng) |
|-|--------------|------------------------|
| **Giá** | Trả phí | ✅ Free |
| **Limit** | Không giới hạn | 1MB/document |
| **Độ phức tạp** | Phải quản lý URL | ✅ Đơn giản |

---

## 🖼️ Xử lý ảnh Base64

### Luồng hoàn chỉnh

```
User chọn ảnh (XFile)
    ↓ readAsBytes()
Uint8List (ảnh gốc ~3MB)
    ↓ FlutterImageCompress (nén xuống 800x800, quality 85%)
Uint8List (sau nén ~200KB)
    ↓ base64Encode()
String Base64 (~270KB)
    ↓ Firestore.add()
LƯU VÀO FIRESTORE
    ↓ Firestore.get()
String Base64
    ↓ base64Decode()
Uint8List
    ↓ Image.memory()
HIỂN THỊ TRÊN UI
```

### Các khái niệm

| Khái niệm | Giải thích |
|-----------|------------|
| `Uint8List` | Danh sách bytes (số 0-255), đại diện cho ảnh |
| `base64Encode()` | Bytes → String (để lưu database/gửi HTTP) |
| `base64Decode()` | String → Bytes (để hiển thị) |
| `Image.memory()` | Widget Flutter hiển thị ảnh từ bytes |
| Overhead 37% | Base64 tăng kích thước 33-37% (3 bytes → 4 chars) |

---

## 🤖 Groq API (AI)

### 2 Models sử dụng

| Model | Loại | Dùng cho |
|-------|------|----------|
| `meta-llama/llama-4-scout-17b-16e-instruct` | Vision | Phân tích ảnh quần áo |
| `llama-3.3-70b-versatile` | Text | Gợi ý outfit, chấm màu |

### Cấu trúc request

```dart
final body = jsonEncode({
  'model': 'llama-4-scout...',
  'messages': [
    {
      'role': 'user',
      'content': [
        {'type': 'text', 'text': prompt},
        {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}},
      ],
    },
  ],
  'max_tokens': 1024,    // Giới hạn độ dài output (~700 từ)
  'temperature': 0.3,    // 0=chính xác, 1=sáng tạo
});
```

### Gửi ảnh cho AI qua Base64

```
Ảnh cũng phải chuyển sang Base64 vì:
- HTTP là giao thức TEXT-based
- Không gửi trực tiếp bytes được
- Server nhận Base64 → decode → phân tích ảnh
```

### Xử lý Response (QUAN TRỌNG!)

```dart
// Response từ Groq API
response.body = '{"id":"...","choices":[{"message":{"content":"{...}"}}]}'

// Bước 1: Parse toàn bộ response
final json = jsonDecode(response.body);  // String → Map

// Bước 2: Đào vào lấy content (text AI sinh ra)
final content = json['choices'][0]['message']['content'];  // Vẫn là String!

// Bước 3: Parse content (vì AI viết JSON dạng text)
final result = safeParseJson(content);  // String → Map
```

**Tại sao parse 2 lần?**
- Lần 1: Parse cấu trúc API response
- Lần 2: Parse nội dung AI sinh ra (chuỗi JSON trong `content`)

### max_tokens và temperature

| Param | Giá trị | Ý nghĩa |
|-------|---------|---------|
| `max_tokens: 1024` | ~700 từ | Giới hạn output |
| `temperature: 0.3` | Chính xác | Phân tích ảnh (luôn nhất quán) |
| `temperature: 0.7` | Cân bằng | Gợi ý outfit (đa dạng hơn) |

---

## 🌤️ Weather API (OpenWeatherMap)

### Đơn giản nhất trong 3 APIs

```dart
// GET request đơn giản
final url = Uri.parse(
  'https://api.openweathermap.org/data/2.5/weather'
  '?q=Quy Nhon,VN'
  '&appid=$apiKey'
  '&units=metric'  // Celsius
);

final response = await http.get(url);
final weather = WeatherInfo.fromJson(jsonDecode(response.body));
```

### Cache 30 phút

```dart
if (_cachedWeather != null && _lastFetchTime != null) {
  final diff = DateTime.now().difference(_lastFetchTime!);
  if (diff < Duration(minutes: 30)) {
    return _cachedWeather;  // Dùng cache, không gọi API
  }
}
```

### Fallback khi lỗi

```dart
// Luôn có giá trị mặc định, app không crash
WeatherInfo _getDefaultWeather() {
  return WeatherInfo(
    temperature: 28,
    cityName: 'Quy Nhon',
    // ...
  );
}
```

### Dùng cho AI gợi ý

```dart
// Gửi mô tả thời tiết cho AI
final weatherContext = weather.toAIDescription();
// "Temperature: 28°C, Humidity: 70%, Condition: Ấm áp"
```

---

## 📋 So sánh 3 Services

| Service | Độ phức tạp | Đặc điểm |
|---------|-------------|----------|
| **Firebase Auth** | ⭐⭐⭐⭐ | SDK làm hết, chỉ gọi methods |
| **Firestore** | ⭐⭐⭐ | CRUD đơn giản, cần convert Model ↔ JSON |
| **Groq AI** | ⭐⭐⭐⭐⭐ | Prompts, parse JSON 2 lần, xử lý nhiều |
| **Weather** | ⭐⭐ | GET đơn giản, có cache & fallback |

---

## 🔑 Best Practices đã áp dụng

1. **Separation of Concerns**: Services riêng biệt (FirebaseService, GroqService, WeatherService)
2. **Error Handling**: Try-catch + fallback values
3. **Caching**: Weather cache 30 phút, tiết kiệm API calls
4. **Type Safety**: Model classes (ClothingItem, WeatherInfo, ColorHarmonyResult)
5. **Clean Architecture**: Screen → Provider → Service → API
