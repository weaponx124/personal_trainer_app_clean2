import 'package:http/http.dart' as http;
import 'dart:convert' show json, utf8, base64;

class FatSecretService {
  // OAuth 2.0 credentials from FatSecret developer portal
  static const String _clientId = '4a4f7fd3016e4cedba709f38af5e7b7d';
  static const String _clientSecret = '71fb8f19082240338143a374dab2ff39';

  String? _accessToken;

  FatSecretService() {
    print('FatSecretService: Initializing FatSecretService...');
  }

  Future<void> fetchAccessToken() async {
    const tokenUrl = 'https://oauth.fatsecret.com/connect/token';
    final auth = base64.encode(utf8.encode('$_clientId:$_clientSecret'));

    try {
      print('FatSecretService: Fetching access token...');
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $auth',
        },
        body: {
          'grant_type': 'client_credentials',
          'scope': 'basic',
        },
      );

      print('FatSecretService: Token Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        print('FatSecretService: Access Token: $_accessToken');
      } else {
        print('FatSecretService: Failed to fetch access token: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch access token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('FatSecretService: Error fetching access token: $e');
      throw Exception('Error fetching access token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFoods(String query) async {
    if (_accessToken == null) {
      await fetchAccessToken();
    }

    final uri = Uri.parse('https://platform.fatsecret.com/rest/server.api').replace(
      queryParameters: {
        'method': 'foods.search',
        'search_expression': query,
        'format': 'json',
        'max_results': '10',
      },
    );

    try {
      print('FatSecretService: Making request to URI: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      print('FatSecretService: Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          print('FatSecretService: API Error: ${data['error']}');
          throw Exception('API Error: ${data['error']}');
        }
        final foods = data['foods']?['food'] as List? ?? [];
        print('FatSecretService: Foods: $foods');

        return foods.map((food) {
          print('FatSecretService: Processing food: ${food['food_name']}');
          print('FatSecretService: Food description: ${food['food_description']}');

          // Handle different response formats
          final description = food['food_description']?.split(' - ')[0] ?? 'Per serving';
          final nutritionString = food['food_description']?.split(' - ')[1] ?? '';
          print('FatSecretService: Nutrition string: $nutritionString');

          // Flexible parsing of nutritional data
          double parseNutrition(String key, String text) {
            print('FatSecretService: Parsing $key from text: $text');
            // Use regex to extract the numerical value after the key
            final regex = RegExp('$key:\\s*([0-9.]+)\\s*(kcal|g|mg)?');
            final match = regex.firstMatch(text);
            final result = match != null ? double.tryParse(match.group(1) ?? '0.0') ?? 0.0 : 0.0;
            print('FatSecretService: Parsed $key: $result');
            return result;
          }

          // Extract macros using the entire nutrition string
          final calories = parseNutrition('Calories', nutritionString);
          final protein = parseNutrition('Protein', nutritionString);
          final carbs = parseNutrition('Carbs', nutritionString);
          final fat = parseNutrition('Fat', nutritionString);
          final sodium = parseNutrition('Sodium', nutritionString);
          final fiber = parseNutrition('Fiber', nutritionString);

          return {
            'food': food['food_name'],
            'measurement': description,
            'quantityPerServing': 1.0,
            'calories': calories,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'sodium': sodium,
            'fiber': fiber,
            'servings': 1.0,
            'isRecipe': food['food_type'] == 'Recipe',
          };
        }).toList();
      } else {
        print('FatSecretService: API Failed with status: ${response.statusCode} - ${response.body}');
        throw Exception('API Failed with status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('FatSecretService: Error fetching foods: $e');
      throw Exception('Error fetching foods: $e');
    }
  }
}