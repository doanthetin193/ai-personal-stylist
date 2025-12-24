# 🤖 VẤN ĐỀ TÍCH HỢP AI - CẦN GIẢI QUYẾT

> **Ngày ghi nhận:** 21/12/2025
> **Trạng thái:** ⏳ Chờ xử lý
> **Mức độ ưu tiên:** Cao

---

## 📋 MÔ TẢ VẤN ĐỀ

### Tình trạng hiện tại:
- App đang sử dụng **Google Gemini API** (model `gemini-2.0-flash`)
- Từ ngày **18/12/2025**, Google cập nhật Terms of Service mới
- **Free tier không còn hoạt động** được nữa (limit = 0)
- Error messages:
  ```
  generate_content_free_tier_requests, limit: 0, model: gemini-2.0-flash
  Please retry in X seconds
  ```

### Nguyên nhân:
1. Google thay đổi chính sách API ngày 18/12/2025
2. Free tier bị giới hạn nghiêm ngặt hơn (có thể limit = 0)
3. Region restrictions mới (Việt Nam có thể không trong available regions)
4. API keys cũ bị đánh dấu "leaked" do đã từng lộ

### Các tính năng bị ảnh hưởng:
- ❌ `GeminiService.analyzeClothingImageBytes()` - Phân tích ảnh quần áo
- ❌ `GeminiService.suggestOutfit()` - Gợi ý outfit
- ❌ `GeminiService.evaluateColorHarmony()` - Chấm điểm phối màu
- ❌ `GeminiService.getCleanupSuggestions()` - Gợi ý dọn tủ đồ

---

## 💡 CÁC PHƯƠNG ÁN GIẢI QUYẾT

### PHƯƠNG ÁN 1: Kích hoạt Google Cloud Billing ⭐ KHUYÊN DÙNG

**Mô tả:**
Kích hoạt billing account với $300 free credit từ Google.

**Ưu điểm:**
- ✅ Không cần thay đổi code
- ✅ $300 credit miễn phí (đủ ~300,000 requests)
- ✅ Chất lượng AI tốt nhất
- ✅ Nhanh chóng triển khai

**Nhược điểm:**
- ❌ Cần thẻ credit/debit để verify
- ❌ Lo ngại bị charge khi hết credit (có thể set budget alert)

**Cách thực hiện:**
1. Vào https://console.cloud.google.com
2. Click "Activate" để nhận $300 credit
3. Thêm thẻ credit/debit (chỉ verify, không charge)
4. Tạo API key mới từ project có billing
5. Set budget alert $5/tháng để yên tâm
6. Thay key vào `lib/utils/api_keys.dart`

**Chi phí ước tính:**
- Gemini Flash: ~$0.001/request
- $300 credit ÷ $0.001 = 300,000 requests
- Dùng 100 requests/ngày = dùng được 8+ năm!

---

### PHƯƠNG ÁN 2: Chuyển sang Groq API (Llama 3.2 Vision)

**Mô tả:**
Sử dụng Groq API với model Llama 3.2 11B Vision - hoàn toàn miễn phí.

**Ưu điểm:**
- ✅ **MIỄN PHÍ** hoàn toàn
- ✅ Free tier rộng rãi: 30 req/phút, 14,400 req/ngày
- ✅ Tốc độ cực nhanh (nhanh nhất thị trường)
- ✅ Hỗ trợ Vision (phân tích ảnh)

**Nhược điểm:**
- ❌ Cần viết lại code `GeminiService`
- ❌ Chất lượng có thể không bằng Gemini
- ❌ Cần test lại prompt

**Cách thực hiện:**
1. Đăng ký tại https://console.groq.com
2. Tạo API key miễn phí
3. Cài đặt package: `dart pub add groq_sdk` (hoặc dùng HTTP)
4. Tạo file `lib/services/groq_service.dart`
5. Viết lại các function tương tự `GeminiService`
6. Thay đổi injection trong `main.dart`

**Code mẫu:**
```dart
// lib/services/groq_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  final String _apiKey;
  
  GroqService(this._apiKey);
  
  Future<Map<String, dynamic>?> analyzeClothingImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.2-11b-vision-preview',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'Phân tích quần áo trong ảnh...' // Prompt tương tự Gemini
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'max_tokens': 1024,
      }),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final content = json['choices'][0]['message']['content'];
      return safeParseJson(content);
    }
    return null;
  }
}
```

---

### PHƯƠNG ÁN 3: Sử dụng OpenRouter

**Mô tả:**
OpenRouter là gateway cho nhiều AI models, có free tier.

**Ưu điểm:**
- ✅ Có free tier
- ✅ Hỗ trợ nhiều model (Llama, Claude, Gemini, GPT...)
- ✅ API tương tự OpenAI (dễ tích hợp)
- ✅ Linh hoạt chuyển đổi model

**Nhược điểm:**
- ❌ Free tier hạn chế
- ❌ Cần viết lại code
- ❌ Một số model Vision tốn phí

**Cách thực hiện:**
1. Đăng ký tại https://openrouter.ai
2. Tạo API key
3. Tích hợp tương tự OpenAI API

---

### PHƯƠNG ÁN 4: Hugging Face Inference API

**Mô tả:**
Sử dụng các model Vision trên Hugging Face miễn phí.

**Ưu điểm:**
- ✅ **MIỄN PHÍ** hoàn toàn
- ✅ Nhiều model Vision để chọn
- ✅ Open source

**Nhược điểm:**
- ❌ Tốc độ chậm (model lớn cần queue)
- ❌ Cần viết lại code
- ❌ Chất lượng không đồng đều

**Các model Vision miễn phí:**
- `Salesforce/blip-image-captioning-large`
- `nlpconnect/vit-gpt2-image-captioning`
- `microsoft/Florence-2-large`

---

### PHƯƠNG ÁN 5: Ollama (chạy local)

**Mô tả:**
Chạy AI model trực tiếp trên máy local với Ollama.

**Ưu điểm:**
- ✅ **MIỄN PHÍ** hoàn toàn
- ✅ Không phụ thuộc internet
- ✅ Không bị rate limit
- ✅ Bảo mật dữ liệu

**Nhược điểm:**
- ❌ Cần máy mạnh (GPU recommended)
- ❌ Không chạy được trên web
- ❌ Khó setup cho mobile
- ❌ Cần viết lại code

**Cách thực hiện:**
1. Cài đặt Ollama: https://ollama.ai
2. Pull model: `ollama pull llava`
3. Chạy server: `ollama serve`
4. Call API từ Flutter: `http://localhost:11434/api/generate`

---

### PHƯƠNG ÁN 6: Tắt AI, để user chọn thủ công

**Mô tả:**
Tắt tính năng AI phân tích, hiển thị form để user tự chọn.

**Ưu điểm:**
- ✅ Không tốn phí
- ✅ Không phụ thuộc API
- ✅ Sửa code rất ít
- ✅ App vẫn hoạt động

**Nhược điểm:**
- ❌ Mất tính năng hay nhất của app
- ❌ UX kém hơn

**Cách thực hiện:**
1. Trong `add_item_screen.dart`, tắt gọi `_analyzeImage()`
2. Hiển thị form chọn thủ công ngay sau khi chọn ảnh:
   ```dart
   // Thay vì:
   await _analyzeImage();
   
   // Thành:
   setState(() {
     _selectedType = ClothingType.other;
     _selectedColor = 'unknown';
     _selectedStyles = [ClothingStyle.casual];
     _selectedSeasons = [Season.summer];
   });
   ```

---

## 📊 BẢNG SO SÁNH TỔNG QUAN

| Phương án | Chi phí | Độ khó | Chất lượng | Tốc độ | Khuyên dùng |
|-----------|---------|--------|------------|--------|-------------|
| Google Billing | $0 (có credit) | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Groq | $0 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| OpenRouter | ~$0 | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| Hugging Face | $0 | ⭐⭐ | ⭐⭐ | ⭐ | ⭐ |
| Ollama | $0 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐ |
| Tắt AI | $0 | ⭐ | N/A | N/A | ⭐ |

---

## 🎯 KHUYẾN NGHỊ

### Ngắn hạn (để demo/nộp project):
1. **Kích hoạt Google Billing** với $300 credit
2. Hoặc **tắt AI** tạm thời, để user chọn thủ công

### Dài hạn (nếu phát triển tiếp):
1. **Chuyển sang Groq** - Miễn phí, đủ tốt
2. Hoặc **giữ Gemini với billing** - Chất lượng tốt nhất

---

## 📁 FILES LIÊN QUAN

- `lib/services/gemini_service.dart` - Service hiện tại
- `lib/screens/add_item_screen.dart` - Màn hình thêm đồ
- `lib/utils/api_keys.dart` - Chứa API keys
- `lib/utils/constants.dart` - Chứa prompts AI

---

## 📝 GHI CHÚ

- Điều khoản mới của Google: https://ai.google.dev/gemini-api/terms
- Groq Console: https://console.groq.com
- OpenRouter: https://openrouter.ai
- Hugging Face: https://huggingface.co/inference-api

---

*Cập nhật lần cuối: 21/12/2025*
