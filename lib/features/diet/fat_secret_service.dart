import 'package:http/http.dart' as http;
import 'dart:convert' show utf8, base64, json;

class FatSecretService {
  String? _fatSecretAccessToken;

  Future<void> fetchFatSecretAccessToken() async {
    const clientId = '4a4f7fd3016e4cedba709f38af5e7b7d';
    const clientSecret = 'e1796e15fba294a3a59a88642f3e975a';
    const tokenUrl = 'https://oauth.fatsecret.com/connect/token';

    final auth = base64.encode(utf8.encode('$clientId:$clientSecret'));

    try {
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

      print('FatSecret Token Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _fatSecretAccessToken = data['access_token'];
        print('FatSecret Access Token: $_fatSecretAccessToken');
      } else {
        print('Failed to fetch FatSecret access token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching FatSecret access token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFoods(String query) async {
    if (_fatSecretAccessToken == null) {
      print('No FatSecret access token available. Attempting to fetch a new one.');
      await fetchFatSecretAccessToken();
      if (_fatSecretAccessToken == null) {
        print('Failed to obtain FatSecret access token. Using mock response.');
        return [
          {
            'food': 'Apple',
            'measurement': '1 medium',
            'calories': 95.0,
            'protein': 0.5,
            'carbs': 25.0,
            'fat': 0.3,
            'sodium': 1.0,
            'fiber': 4.4,
            'servings': 1.0,
            'isRecipe': false,
          },
          {
            'food': 'Banana',
            'measurement': '1 medium',
            'calories': 90.0,
            'protein': 1.1,
            'carbs': 23.0,
            'fat': 0.3,
            'sodium': 1.0,
            'fiber': 2.6,
            'servings': 1.0,
            'isRecipe': false,
          },
        ];
      }
    }

    final url =
        'https://platform.fatsecret.com/rest/foods/search/v1?method=foods.search&search_expression=$query&format=json&max_results=10';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_fatSecretAccessToken',
        },
      );
      print('FatSecret Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          print('FatSecret API Error: ${data['error']}');
          return [];
        }
        final foods = data['foods']?['food'] as List? ?? [];
        return foods.map((food) {
          final description = food['food_description']?.split(' - ')[0] ?? 'Per serving';
          return {
            'food': food['food_name'],
            'measurement': description,
            'calories': double.tryParse(food['food_description']
                ?.split(' - ')[1]
                ?.split(' | ')[0]
                ?.replaceAll('Calories: ', '')
                ?.replaceAll('kcal', '') ??
                '0') ??
                0.0,
            'protein': 0.0,
            'carbs': 0.0,
            'fat': 0.0,
            'sodium': 0.0,
            'fiber': 0.0,
            'servings': 1.0,
            'isRecipe': food['food_type'] == 'Recipe',
          };
        }).toList();
      } else {
        print('API Failed with status: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching FatSecret foods: $e');
      return [];
    }
  }
}