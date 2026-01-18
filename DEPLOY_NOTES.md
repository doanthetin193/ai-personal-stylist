# 🚀 Hướng Dẫn Deploy - AI Personal Stylist

## Tổng Quan

App đã được deploy lên **Firebase Hosting** tại:
- **URL:** https://ai-personal-stylist-b1162.web.app

Do app đã cấu hình Firebase (Auth + Firestore) trước đó, việc deploy chỉ cần thêm config hosting và chạy vài lệnh.

---

## Yêu Cầu Trước Khi Deploy

| Yêu cầu | Đã có |
|---------|-------|
| Firebase project | ✅ `ai-personal-stylist-b1162` |
| Firebase CLI | ✅ `npm install -g firebase-tools` |
| Đã login CLI | ✅ `firebase login` |
| File `firebase.json` có hosting config | ✅ |

---

## Các Lệnh Deploy

### 🟢 Bật Server (Deploy)

```bash
# 1. Build Flutter web
flutter build web

# 2. Chọn project Firebase (nếu chưa chọn)
firebase use ai-personal-stylist-b1162

# 3. Deploy lên hosting
firebase deploy --only hosting
```

### 🔴 Tắt Server

```bash
firebase hosting:disable
```

### 🔄 Deploy Lại Sau Khi Sửa Code

```bash
flutter build web
firebase deploy --only hosting
```

### 📋 Các Lệnh Khác

```bash
# Xem lịch sử deployments
firebase hosting:releases:list

# Rollback về version trước
firebase hosting:rollback

# Xem project đang dùng
firebase projects:list
```

---

## ⚠️ Lưu Ý Quan Trọng

### 1. API Key Bị Lộ (Chấp Nhận Được)

| API Key | Vị trí | Mức độ |
|---------|--------|--------|
| Groq API | `lib/utils/api_keys.dart` | ⚠️ Lộ trong code |
| Weather API | `lib/utils/api_keys.dart` | ⚠️ Lộ trong code |
| Firebase | `firebase_options.dart` | ✅ OK (có Rules bảo vệ) |

**Giải pháp:**
- Groq free tier: 14,400 requests/ngày → Đủ demo
- Nếu bị abuse → Regenerate key mới trên Groq Console

### 2. Server Chạy Vĩnh Viễn

```
Sau khi deploy:
→ App chạy trên server Google 24/7
→ Tắt terminal, tắt máy tính = VẪN CHẠY
→ Chỉ tắt khi bạn chạy: firebase hosting:disable
```

### 3. Free Tier Limits

| Tài nguyên | Giới hạn miễn phí |
|------------|-------------------|
| Storage | 10 GB |
| Bandwidth | 360 MB/ngày |
| Firestore reads | 50K/ngày |
| Firestore writes | 20K/ngày |

### 4. Google Sign-In Không Hoạt Động Trong Embedded Browser

```
Lỗi: "Access blocked: disallowed_useragent"

Nguyên nhân: Mở link trong Messenger, Facebook Browser

Giải pháp: Mở bằng Chrome/Safari/Edge (trình duyệt thật)
```

---

## File Config

### `firebase.json`

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}]
  }
}
```

| Field | Ý nghĩa |
|-------|---------|
| `public` | Folder chứa web build |
| `ignore` | Files không upload |
| `rewrites` | Điều hướng mọi route về index.html (SPA) |

---

## Tóm Tắt

| Hành động | Lệnh |
|-----------|------|
| Build | `flutter build web` |
| Deploy | `firebase deploy --only hosting` |
| Tắt | `firebase hosting:disable` |
| Xem releases | `firebase hosting:releases:list` |
