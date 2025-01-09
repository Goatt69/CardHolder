import 'dart:convert';
import 'package:cardholder/model/CardHolder.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../model/PokeCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class CollectionCardService {
  Future<List<CardHolder>> getUserCards() async {
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
      return jsonResponse.map((card) => CardHolder.fromJson(card)).toList();
    }
    throw Exception('Failed to load collection');
  }
  Future<bool> addCardToCollection(String cardId, {int quantity = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}CardHolder/$cardId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: json.encode(quantity),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

}
