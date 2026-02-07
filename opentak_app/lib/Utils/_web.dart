import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenTAKHTTPClient {
  final String serverUrl;
  final String authToken;

  OpenTAKHTTPClient({required this.serverUrl, required this.authToken});

  Future<http.Response> get(String endpoint) async {
    final url = Uri.https(serverUrl.replaceFirst(RegExp(r'^https?://'), ''), endpoint);
    return await http.get(url, headers: {
      'token': authToken,
    });
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.https(serverUrl.replaceFirst(RegExp(r'^https?://'), ''), endpoint);
    return await http.post(url,
        headers: {
          'token': authToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body));
  }

  Future<bool> register(String username, String email, String password, String? secretCode) async {
    final url = Uri.https(serverUrl.replaceFirst(RegExp(r'^https?://'), ''), '/register');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json', 'x-secret-code': secretCode ?? ''},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }));
      
    if (response.statusCode == 403) {
      throw Exception('Invalid secret code');
    }

    return response.statusCode == 200;
  }

  Future<String?> login(String username, String password) async {
    final url = Uri.https(serverUrl.replaceFirst(RegExp(r'^https?://'), ''), '/login');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    }
  }

  Future<String> getMQTTBrokerUrl() async {
    final response = await get('/mqtt-broker');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mqttBrokerUrl'];
    } else {
      throw Exception('Failed to fetch MQTT broker URL: ${response.statusCode}');
    }
  }

  Future<List<String>> getAvailableMaps() async {
    final response = await get('/list-maps');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['maps']);
    } else {
      throw Exception('Failed to fetch maps: ${response.statusCode}');
    }
  }
}