import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Para Flutter Web usa localhost
  // Para emulador Android cambia a http://10.0.2.2:8000
  // Para dispositivo fisico cambia a http://TU_IP_LOCAL:8000
  static const String baseUrl = 'http://localhost:8000';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      await prefs.setString('nombre', data['nombre']);
      return data;
    }
    throw Exception('Login fallido: ${res.body}');
  }

  static Future<List<dynamic>> getPaquetes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/paquetes'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error: ${res.body}');
  }

  static Future<void> entregarPaquete(
      int paqueteId, String fotoBase64, double lat, double lng) async {
    final res = await http.post(
      Uri.parse('$baseUrl/entregar'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'paquete_id': paqueteId,
        'foto_base64': fotoBase64,
        'latitud': lat,
        'longitud': lng,
      }),
    );
    if (res.statusCode != 200) throw Exception('Error: ${res.body}');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
