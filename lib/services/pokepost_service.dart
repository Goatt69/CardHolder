import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../model/OfferedCard.dart';
import '../model/PokePost.dart';
import '../model/TradeOffer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokePostService {
  Future<List<PokePost>> getAllPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final response = await http.get(
      Uri.parse("${Config_URL.baseUrl}PokemonPost"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => PokePost.fromJson(post)).toList();
    }
    throw Exception('Failed to load posts');
  }

  Future<PokePost> createPost(String cardId, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final response = await http.post(
      Uri.parse("${Config_URL.baseUrl}PokemonPost"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "cardId": cardId,
        "description": description
      }),
    );

    if (response.statusCode == 201) {
      return PokePost.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create post');
  }

  Future<TradeOffer> createTradeOffer(int postId, List<String> offeredCardIds) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // Debug prints
    print('Request URL: ${Config_URL.baseUrl}PokemonPost/$postId/offers');
    print('Offered Card IDs: $offeredCardIds');

    final response = await http.post(
      Uri.parse("${Config_URL.baseUrl}PokemonPost/$postId/offers"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "offeredCardIds": offeredCardIds
      }),
    );

    // Debug response
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return TradeOffer.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create trade offer: ${response.body}');
  }

  Future<void> acceptTradeOffer(int offerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse("${Config_URL.baseUrl}PokemonPost/offers/$offerId/accept"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to accept trade offer');
    }
  }
  
  Future<List<TradeOffer>> getTradeOffers(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse("${Config_URL.baseUrl}PokemonPost/$postId/offers"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((offer) => TradeOffer.fromJson(offer)).toList();
    }
    throw Exception('Failed to load trade offers');
  }
}



