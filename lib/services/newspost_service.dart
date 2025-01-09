import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../model/NewsPosts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsPostService {
  Future<List<NewsPost>> getAllNewsPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse("${Config_URL.baseUrl}NewsPost"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => NewsPost.fromJson(post)).toList();
    }
    throw Exception('Failed to load news posts');
  }

  Future<NewsPost> createNewsPost(String title, String content, String? imageUrl, bool isPublished) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.post(
      
      Uri.parse("${Config_URL.baseUrl}NewsPost"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "content": content,
        "imageUrl": imageUrl,
        "isPublished": isPublished
      }),
    );

    if (response.statusCode == 201) {
      return NewsPost.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create news post');
  }

  Future<NewsPost> updateNewsPost(int id, String title, String content, String? imageUrl, bool isPublished) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse("${Config_URL.baseUrl}NewsPost/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "content": content,
        "imageUrl": imageUrl,
        "isPublished": isPublished
      }),
    );

    if (response.statusCode == 200) {
      return NewsPost.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update news post');
  }
}
