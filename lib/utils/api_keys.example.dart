/// API Keys Configuration - EXAMPLE FILE
/// 
/// 📋 Hướng dẫn:
/// 1. Copy file này thành 'api_keys.dart' (cùng thư mục)
/// 2. Điền API keys thật của bạn vào
/// 3. File api_keys.dart sẽ được gitignore, không bị push lên GitHub
///
/// ⚠️ KHÔNG SỬA FILE NÀY - Chỉ dùng làm template!
library;

class ApiKeys {
  // Gemini AI API Key
  // Lấy tại: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // OpenWeatherMap API Key  
  // Lấy tại: https://openweathermap.org/api
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY_HERE';
}
