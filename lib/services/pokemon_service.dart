import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
class PokemonService {
  final String baseUrl = dotenv.env['URL'] ?? ''; // Đổi thành URL của bạn

  Future<Map<String, String>?> matchPokemonName(String ocrText) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/names'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        Map<String, String>? bestMatch;
        double highestSimilarity = 0.0;

        for (final item in data) {
          final name = item['name'] as String;
          final id = item['id'] as String;

          double similarity = calculateSimilarity(ocrText, name);

          if (similarity > highestSimilarity) {
            highestSimilarity = similarity;
            bestMatch = {'id': id, 'name': name};
          }

          // Nếu similarity đạt 100%, dừng vòng lặp
          if (highestSimilarity == 1.0) {
            break;
          }
        }

        return bestMatch;
      } else {
        print("Error fetching Pokémon data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in matchPokemonName: $e");
      return null;
    }
  }

  double calculateSimilarity(String text1, String text2) {
    text1 = text1.toLowerCase().replaceAll(RegExp(r'\W+'), '');
    text2 = text2.toLowerCase().replaceAll(RegExp(r'\W+'), '');

    int matches = 0;
    for (int i = 0; i < text1.length && i < text2.length; i++) {
      if (text1[i] == text2[i]) {
        matches++;
      }
    }

    return matches / math.max(text1.length, text2.length);
  }
}
