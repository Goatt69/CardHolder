import 'dart:convert';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  // Đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    var result = await _authService.login(email, password);
    return result; // returns a map with {success: bool, token: string?, role: string?, message: string?}
  }
  static Future<Map<String, dynamic>> setupTotp() async {
    return await _authService.setupTotp();
  }
  static Future<Map<String, dynamic>> loginWithTotp(String email, String password, String totpCode) async {
    return await _authService.loginWithTotp(email, password, totpCode);
  }
  // Đăng ký tài khoản mới
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Tạo body để gửi lên API
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
    };

    // Gọi API đăng ký thông qua ApiClient
    try {
      var response = await _apiClient.post('Authenticate/register', body: body);

      // Xử lý kết quả từ API
      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại, vui lòng thử lại.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }
}

