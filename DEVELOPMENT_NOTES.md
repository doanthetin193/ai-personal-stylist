# 📚 Tài liệu chi tiết: Những gì đã làm trong dự án AI Personal Stylist

> **Tài liệu này dành cho người mới học Flutter**, giải thích từng bước và từng khái niệm đã sử dụng trong dự án.

---

## 📋 Mục lục

1. [Tổng quan dự án](#1-tổng-quan-dự-án)
2. [Các công nghệ đã sử dụng](#2-các-công-nghệ-đã-sử-dụng)
3. [Cấu trúc thư mục và vai trò từng file](#3-cấu-trúc-thư-mục-và-vai-trò-từng-file)
4. [Flow hoạt động của app](#4-flow-hoạt-động-của-app)
5. [Chi tiết các vấn đề đã gặp và cách giải quyết](#5-chi-tiết-các-vấn-đề-đã-gặp-và-cách-giải-quyết)
6. [Giải thích các khái niệm quan trọng](#6-giải-thích-các-khái-niệm-quan-trọng)
7. [Firebase - Cấu hình chi tiết](#7-firebase---cấu-hình-chi-tiết)
8. [Hướng dẫn tiếp tục phát triển](#8-hướng-dẫn-tiếp-tục-phát-triển)

---

## 1. Tổng quan dự án

### Mục đích
Xây dựng ứng dụng **quản lý tủ đồ thông minh** với các tính năng:
- Chụp ảnh quần áo → AI phân tích tự động
- Lưu trữ vào database cá nhân
- Gợi ý phối đồ dựa trên thời tiết và dịp

### Kế hoạch ban đầu (4 tuần)
```
Tuần 1: Setup project, Firebase, UI cơ bản
Tuần 2: Tích hợp AI (Gemini), phân tích ảnh
Tuần 3: Gợi ý outfit, chấm điểm màu
Tuần 4: Polish UI, testing, deploy
```

### Kết quả đạt được
- ✅ Đăng nhập/Đăng ký (Google, Email, Anonymous)
- ✅ Thêm quần áo với AI phân tích
- ✅ Xem danh sách tủ đồ
- ✅ Gợi ý outfit
- ✅ Chấm điểm hợp màu

---

## 2. Các công nghệ đã sử dụng

### 2.1 Flutter
**Flutter là gì?**
- Framework của Google để xây dựng app đa nền tảng (iOS, Android, Web, Desktop)
- Viết 1 lần code, chạy được trên nhiều platform
- Sử dụng ngôn ngữ **Dart**

**Tại sao chọn Flutter?**
- Hot Reload: Thay đổi code → thấy kết quả ngay
- Widget-based: Mọi thứ đều là widget, dễ customize
- Cộng đồng lớn, nhiều package

### 2.2 Firebase
**Firebase là gì?**
- Backend-as-a-Service (BaaS) của Google
- Cung cấp sẵn các dịch vụ: Auth, Database, Storage, Hosting...
- Không cần viết backend từ đầu

**Các service Firebase dùng trong project:**

| Service | Mục đích |
|---------|----------|
| **Firebase Auth** | Xác thực người dùng (đăng nhập/đăng ký) |
| **Cloud Firestore** | Database NoSQL lưu trữ dữ liệu |
| **Firebase Storage** | Lưu trữ file (ảnh, video) - *Yêu cầu Blaze plan* |

### 2.3 Google Gemini AI
**Gemini là gì?**
- AI model của Google (tương tự ChatGPT)
- Có khả năng hiểu ảnh (multimodal)
- Dùng để phân tích ảnh quần áo

**Cách hoạt động trong app:**
1. User chụp ảnh quần áo
2. Gửi ảnh lên Gemini API
3. Gemini phân tích và trả về JSON: `{type, color, material, styles, seasons}`
4. App hiển thị kết quả cho user chỉnh sửa

### 2.4 Provider (State Management)
**State Management là gì?**
- Cách quản lý "trạng thái" (data) trong app
- Ví dụ: User đã đăng nhập chưa? Danh sách quần áo có những gì?

**Provider là gì?**
- Package phổ biến nhất để quản lý state trong Flutter
- Dễ học, dễ dùng cho người mới

**Cách dùng Provider:**
```dart
// 1. Tạo Provider (chứa data + logic)
class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  
  void login() {
    isLoggedIn = true;
    notifyListeners(); // Báo cho UI biết data đã thay đổi
  }
}

// 2. Wrap app với Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MyApp(),
)

// 3. Sử dụng trong UI
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    if (auth.isLoggedIn) {
      return HomeScreen();
    }
    return LoginScreen();
  },
)
```

---

## 3. Cấu trúc thư mục và vai trò từng file

### 3.1 Thư mục `lib/models/`
**Chứa các Data Model** - định nghĩa cấu trúc dữ liệu

```dart
// clothing_item.dart - Định nghĩa 1 món quần áo
class ClothingItem {
  final String id;
  final String userId;
  final String? imageUrl;      // URL ảnh (nếu dùng Storage)
  final String? imageBase64;   // Ảnh dạng Base64 (nếu lưu Firestore)
  final ClothingType type;     // Loại: áo, quần, giày...
  final String color;          // Màu sắc
  final String? material;      // Chất liệu
  // ...
}
```

### 3.2 Thư mục `lib/services/`
**Chứa Business Logic** - giao tiếp với API/Database

| File | Vai trò |
|------|---------|
| `firebase_service.dart` | CRUD với Firestore, Auth methods |
| `gemini_service.dart` | Gọi Gemini API phân tích ảnh |
| `weather_service.dart` | Gọi OpenWeatherMap API |

```dart
// Ví dụ: firebase_service.dart
class FirebaseService {
  // Đăng nhập Google
  Future<UserCredential?> signInWithGoogle() async { ... }
  
  // Thêm item vào Firestore
  Future<String?> addClothingItem(ClothingItem item) async { ... }
  
  // Lấy danh sách items của user
  Future<List<ClothingItem>> getUserItems() async { ... }
}
```

### 3.3 Thư mục `lib/providers/`
**Chứa State Management** - quản lý trạng thái app

| File | Vai trò |
|------|---------|
| `auth_provider.dart` | Quản lý trạng thái đăng nhập |
| `wardrobe_provider.dart` | Quản lý tủ đồ, gọi AI |

```dart
// wardrobe_provider.dart
class WardrobeProvider extends ChangeNotifier {
  List<ClothingItem> _items = [];
  bool _isLoading = false;
  
  // Thêm item mới
  Future<void> addItem(imageBytes, type, color, ...) async {
    _isLoading = true;
    notifyListeners();
    
    // Convert ảnh sang Base64
    // Lưu vào Firestore
    // Thêm vào danh sách local
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### 3.4 Thư mục `lib/screens/`
**Chứa các màn hình UI**

| File | Màn hình |
|------|----------|
| `login_screen.dart` | Đăng nhập/Đăng ký |
| `home_screen.dart` | Trang chủ + Bottom Navigation |
| `wardrobe_screen.dart` | Danh sách tủ đồ |
| `add_item_screen.dart` | Thêm quần áo mới |
| `item_detail_screen.dart` | Chi tiết món đồ |
| `outfit_suggest_screen.dart` | Gợi ý phối đồ |
| `color_harmony_screen.dart` | Chấm điểm hợp màu |
| `profile_screen.dart` | Hồ sơ cá nhân |

### 3.5 Thư mục `lib/widgets/`
**Chứa Reusable Components** - widget dùng lại nhiều nơi

```dart
// clothing_card.dart - Card hiển thị 1 món đồ
class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  // ...
}

// ClothingImage - Widget hiển thị ảnh từ Base64 hoặc URL
class ClothingImage extends StatelessWidget {
  final ClothingItem item;
  // Tự động detect Base64 hay URL để hiển thị đúng
}
```

### 3.6 Thư mục `lib/utils/`
**Chứa Utilities** - constants, helpers, theme

| File | Nội dung |
|------|----------|
| `constants.dart` | API keys, collection names, AI prompts |
| `theme.dart` | Colors, TextStyles, AppTheme |
| `helpers.dart` | Hàm tiện ích (format date, clean JSON...) |

---

## 4. Flow hoạt động của app

### 4.1 Flow Đăng nhập
```
[Mở app] 
    → main.dart khởi tạo Firebase
    → AuthProvider check trạng thái
    → Nếu chưa login → LoginScreen
    → User chọn Google/Anonymous
    → FirebaseService.signInWithGoogle()
    → AuthProvider cập nhật isAuthenticated = true
    → UI tự động chuyển sang HomeScreen
```

### 4.2 Flow Thêm quần áo
```
[HomeScreen] → Click "Thêm đồ" → [AddItemScreen]
    → Chọn ảnh từ Gallery/Camera
    → Ảnh được convert thành Uint8List (bytes)
    → GeminiService.analyzeClothingImageBytes(bytes)
    → Gemini trả về JSON {type, color, material, styles, seasons}
    → Hiển thị kết quả cho user chỉnh sửa
    → User click "Lưu"
    → WardrobeProvider.addItemFromBytes()
        → Convert bytes → Base64 string
        → Tạo ClothingItem object
        → FirebaseService.addClothingItem() → Lưu Firestore
    → Quay về WardrobeScreen với item mới
```

### 4.3 Flow Gợi ý Outfit
```
[HomeScreen] → Tab "Gợi ý" → [OutfitSuggestScreen]
    → User chọn dịp (đi làm, hẹn hò...)
    → Click "Gợi ý cho tôi"
    → WardrobeProvider.getOutfitSuggestion()
        → Lấy tất cả items của user
        → Tạo prompt với danh sách items + dịp + thời tiết
        → Gọi Gemini AI
        → Gemini trả về outfit gợi ý
    → Hiển thị các món đồ được chọn
```

---

## 5. Chi tiết các vấn đề đã gặp và cách giải quyết

### 5.1 Lỗi: Image.file không hoạt động trên Web
**Vấn đề:**
```dart
Image.file(File('path/to/image')) // ❌ Không work trên Web
```

**Nguyên nhân:**
- Flutter Web chạy trong browser
- Browser không có quyền truy cập file system
- `dart:io` không available trên Web

**Giải pháp:**
```dart
// Dùng Image.memory với Uint8List (bytes)
Image.memory(imageBytes) // ✅ Work trên cả Mobile và Web
```

### 5.2 Lỗi: Provider<GeminiService> not found
**Vấn đề:**
```
Error: Could not find the correct Provider<GeminiService>
```

**Nguyên nhân:**
- Các screen đang cố gắng access GeminiService qua Provider
- Nhưng chưa đăng ký trong main.dart

**Giải pháp:**
```dart
// main.dart
MultiProvider(
  providers: [
    Provider<GeminiService>.value(value: _geminiService), // ✅ Thêm dòng này
    Provider<WeatherService>.value(value: _weatherService),
    Provider<FirebaseService>.value(value: _firebaseService),
    // ...
  ],
)
```

### 5.3 Lỗi: Gemini model "gemini-1.5-flash" not found
**Vấn đề:**
```
404: models/gemini-1.5-flash is not found
```

**Nguyên nhân:**
- Model name đã thay đổi hoặc không available

**Giải pháp:**
```dart
// Đổi từ
final model = genAI.generativeModel(model: 'gemini-1.5-flash');
// Sang
final model = genAI.generativeModel(model: 'gemini-2.0-flash');
```

### 5.4 Lỗi: Firebase Storage yêu cầu Blaze plan
**Vấn đề:**
```
To use Storage, upgrade your project's billing plan
```

**Nguyên nhân:**
- Firebase Storage không còn miễn phí trên Spark plan
- Cần upgrade lên Blaze (trả phí) hoặc dùng giải pháp khác

**Giải pháp đã chọn: Lưu ảnh dạng Base64 vào Firestore**

```dart
// Thay vì upload lên Storage
final imageUrl = await storage.uploadImage(file);

// Chuyển sang lưu Base64 trong Firestore
final base64 = base64Encode(imageBytes);
final item = ClothingItem(
  imageBase64: base64, // Lưu trực tiếp vào document
);
await firestore.add(item.toJson());
```

**Ưu điểm:**
- Không cần Firebase Storage
- Không cần upgrade Blaze plan
- Không cần thẻ tín dụng

**Nhược điểm:**
- Giới hạn 1MB/document (Firestore limit)
- Cần compress ảnh nếu quá lớn

### 5.5 Lỗi: Firestore timeout 30 giây
**Vấn đề:**
```
Exception: Firestore timeout after 30 seconds
```

**Nguyên nhân:**
- **Firestore Database chưa được tạo** (chỉ thấy "Create database")
- Hoặc Firestore Rules đang block write

**Giải pháp:**
1. Vào Firebase Console → Firestore Database
2. Click "Create database"
3. Chọn location (asia-southeast1)
4. Sửa Rules:
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

### 5.6 Lỗi: Query requires an index
**Vấn đề:**
```
[cloud_firestore/failed-precondition] The query requires an index
```

**Nguyên nhân:**
- Firestore yêu cầu **Composite Index** khi query có:
  - WHERE + ORDER BY trên các field khác nhau
  
```dart
// Query này cần Index
query.where('userId', '==', uid)
     .orderBy('createdAt', descending: true)
```

**Giải pháp:**
1. Vào Firebase Console → Firestore → Indexes
2. Click "Create index"
3. Collection: `items`
4. Fields:
   - `userId` - Ascending
   - `createdAt` - Descending
5. Click Create và chờ vài phút

---

## 6. Giải thích các khái niệm quan trọng

### 6.1 Widget là gì?
- Mọi thứ trong Flutter đều là **Widget**
- Widget = building block của UI
- Có 2 loại:
  - **StatelessWidget**: Không có state, UI không thay đổi
  - **StatefulWidget**: Có state, UI có thể thay đổi

```dart
// StatelessWidget - UI cố định
class MyText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}

// StatefulWidget - UI có thể thay đổi
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() { // Gọi setState để rebuild UI
          count++;
        });
      },
      child: Text('Count: $count'),
    );
  }
}
```

### 6.2 async/await là gì?
- Cách xử lý **bất đồng bộ** (asynchronous) trong Dart
- Dùng khi gọi API, đọc file, query database...

```dart
// Hàm async - trả về Future
Future<String> fetchData() async {
  // await = chờ cho đến khi hoàn thành
  final response = await http.get('https://api.example.com');
  return response.body;
}

// Cách gọi
void loadData() async {
  final data = await fetchData();
  print(data);
}
```

### 6.3 BuildContext là gì?
- "Vị trí" của widget trong widget tree
- Dùng để:
  - Truy cập Provider: `Provider.of<MyProvider>(context)`
  - Navigate: `Navigator.push(context, ...)`
  - Show dialog: `showDialog(context: context, ...)`

### 6.4 ChangeNotifier và notifyListeners()
```dart
class MyProvider extends ChangeNotifier {
  int _value = 0;
  int get value => _value;
  
  void increment() {
    _value++;
    notifyListeners(); // ⚠️ QUAN TRỌNG: Báo cho UI rebuild
  }
}
```

- Khi gọi `notifyListeners()`, tất cả widget đang "listen" sẽ được rebuild
- Quên gọi → UI không cập nhật

### 6.5 JSON và Serialization
```dart
// Object → JSON (toJson)
class User {
  String name;
  int age;
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };
}

// JSON → Object (fromJson)
factory User.fromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'],
    age: json['age'],
  );
}
```

### 6.6 Base64 là gì?
- Cách **encode binary data thành text**
- Ảnh (binary) → Base64 string → Lưu vào database (text)

```dart
import 'dart:convert';

// Encode: Bytes → Base64 string
String base64String = base64Encode(imageBytes);

// Decode: Base64 string → Bytes
Uint8List bytes = base64Decode(base64String);
```

**Ví dụ:**
- Ảnh 200KB → Base64 khoảng 270KB (tăng ~33%)

---

## 7. Firebase - Cấu hình chi tiết

### 7.1 Cấu trúc Firestore
```
/items (collection)
    /documentId1
        userId: "abc123"
        imageBase64: "data:image/jpeg;base64,..."
        type: "tshirt"
        color: "trắng sọc đen"
        material: "cotton"
        styles: ["casual", "minimalist"]
        seasons: ["spring", "summer"]
        createdAt: Timestamp
        isFavorite: false
    /documentId2
        ...

/users (collection)
    /userId1
        displayName: "John"
        email: "john@gmail.com"
        ...
```

### 7.2 Firestore Security Rules giải thích
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Áp dụng cho tất cả documents
    match /{document=**} {
      // Chỉ cho phép nếu user đã đăng nhập
      allow read, write: if request.auth != null;
    }
  }
}
```

**Giải thích:**
- `request.auth != null`: Kiểm tra user đã authenticate chưa
- `read`: Cho phép đọc (get, list)
- `write`: Cho phép ghi (create, update, delete)

### 7.3 Composite Index giải thích
**Khi nào cần Index?**
```dart
// Query đơn giản - KHÔNG cần index
query.where('userId', '==', uid);

// Query phức tạp - CẦN composite index
query.where('userId', '==', uid)
     .orderBy('createdAt', descending: true);
```

**Cách Firestore hoạt động:**
- Firestore lưu data theo **document ID**
- Để query nhanh, cần **index** (giống mục lục sách)
- Composite index = index trên nhiều field

---

## 8. Hướng dẫn tiếp tục phát triển

### 8.1 Cải thiện AI prompt
File: `lib/utils/constants.dart`
```dart
static const String analyzeClothing = '''
// Prompt tiếng Việt đã cải thiện
// Thêm hướng dẫn phân biệt áo thun vs áo sơ mi
// Hỗ trợ nhận diện nhiều màu (áo sọc)
''';
```

### 8.2 Thêm tính năng mới
1. **Lịch sử outfit đã mặc**
2. **Thống kê tần suất mặc đồ**
3. **Gợi ý mua sắm** dựa trên tủ đồ thiếu gì
4. **Chia sẻ outfit** lên social media

### 8.3 Tối ưu performance
1. **Compress ảnh** trước khi lưu Base64
2. **Pagination** cho danh sách items
3. **Cache** AI responses

### 8.4 Deploy lên Production
```bash
# Build Web
flutter build web

# Deploy lên Firebase Hosting
firebase deploy --only hosting
```

---

## 📞 Liên hệ hỗ trợ

Nếu có thắc mắc, liên hệ:
- GitHub Issues: [ai-personal-stylist/issues](https://github.com/doanthetin193/ai-personal-stylist/issues)

---

*Tài liệu được tạo ngày 29/11/2024*
*Phiên bản: 1.0.0*
