import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config_URL {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null) {
      print("BASE_URL is not set in the .env file. Using default URL.");
      //đường dẫn API nếu không đọc được URL trong file .env
      return "http://localhost:5138/api/";
    }
    return url;
  }
  static String get imageUrl {
    final url = dotenv.env['URL'];
    if (url == null) {
      print("URL is not set in the .env file.");
      return "http://localhost:8000";
    }
    return url;
  }
}
