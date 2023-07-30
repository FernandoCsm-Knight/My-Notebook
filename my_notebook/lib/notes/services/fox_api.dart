import 'dart:convert';

import 'package:http/http.dart' as http;

class FoxApi {
  static const String baseUrl = 'https://randomfox.ca/floof';
  
  static Future<String> getFoxImage() async {
    http.Response response = await http.get(Uri.parse(baseUrl));
    Map<String, dynamic> data = jsonDecode(response.body);
    return data['image'];
  }
}