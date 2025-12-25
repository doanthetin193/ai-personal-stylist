# 🔍 Cơ chế Filter trong Tủ đồ

## Tổng quan

Filter trong app có **2 phần**:
1. **UI (Screen)**: Làm chip sáng lên
2. **Data (Provider)**: Lọc items thực sự

---

## Phần 1: UI - Làm chip sáng

### Biến lưu trữ (wardrobe_screen.dart):

```dart
String _selectedCategory = 'all';  // Chip nào đang chọn
```

### Cách hoạt động:

```dart
// Kiểm tra chip có đang chọn không
final isSelected = _selectedCategory == category['id'];

// Đổi màu dựa vào isSelected
gradient: isSelected ? AppTheme.primaryGradient : null,
color: isSelected ? null : Colors.white,
```

### Kết quả:

```
_selectedCategory = 'top'

[Tất cả] [✅Áo] [Quần] [Giày]
           ↑
         Sáng
```

---

## Phần 2: Provider - Lọc data

### Biến lưu trữ (wardrobe_provider.dart):

```dart
List<ClothingItem> _items = [];   // Tất cả items
String? _filterCategory;           // null = không lọc
```

### Getter lọc:

```dart
List<ClothingItem> get items => _filteredItems;

List<ClothingItem> get _filteredItems {
  if (_filterCategory == null) {
    return _items;  // Không lọc → trả về hết
  }
  
  // Có lọc → chỉ trả về items phù hợp
  return _items.where((item) => 
    item.type.category == _filterCategory
  ).toList();
}
```

### Hai methods:

```dart
// Bật filter
void setFilterCategory(String category) {
  _filterCategory = category;
  notifyListeners();
}

// Tắt filter
void clearFilter() {
  _filterCategory = null;
  notifyListeners();
}
```

---

## Luồng hoạt động

```
USER BẤM CHIP "Áo"
        │
        ├── 1. setState(_selectedCategory = 'top')
        │      → Chip "Áo" sáng lên
        │
        └── 2. provider.setFilterCategory('top')
               │
               ├── _filterCategory = 'top'
               │
               └── notifyListeners()
                       │
                       ▼
               Consumer rebuild
                       │
                       ▼
               wardrobe.items được gọi
                       │
                       ▼
               _filteredItems lọc data
                       │
                       ▼
               [áo thun, áo sơ mi] (2 items)
                       │
                       ▼
               Grid hiện 2 cards
```

---

## Hai getter khác nhau

| Getter | Trả về | Dùng cho |
|--------|--------|----------|
| `items` | Items đã lọc | Grid Tủ đồ |
| `allItems` | TẤT CẢ items | Badge "X món", AI, thống kê... |

### Ví dụ:

```dart
// Grid dùng items (đã lọc)
GridView(itemCount: wardrobe.items.length)

// Badge dùng allItems (tất cả)
Text('${wardrobe.allItems.length} món')
```

---

## Tóm tắt

```
┌─────────────────────────────────────────────────────┐
│  SCREEN                                              │
│  _selectedCategory = 'top' → Chip sáng              │
└──────────────────────┬──────────────────────────────┘
                       │ setFilterCategory('top')
                       ▼
┌─────────────────────────────────────────────────────┐
│  PROVIDER                                            │
│  _filterCategory = 'top' → Data lọc                 │
│  notifyListeners() → UI rebuild                     │
│  get items → [items đã lọc]                         │
└─────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  UI                                                  │
│  Grid hiện items đã lọc                             │
└─────────────────────────────────────────────────────┘
```
