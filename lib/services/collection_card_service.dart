import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../model/PokeCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionCardService {
  Future<List<PokeCard>> getUserCards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final response = await http.get(
      Uri.parse("${Config_URL.baseUrl}CardHolder"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((card) => PokeCard.fromJson(card)).toList();
    }
    throw Exception('Failed to load collection');
  }
}
