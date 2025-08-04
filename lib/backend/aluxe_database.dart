import 'dart:convert';
import 'package:http/http.dart' as http;

class AluxeDatabase {
  static final AluxeDatabase _instance = AluxeDatabase._init();
  // Cambia esta URL por la de tu backend en Render para producción
  static const String baseUrl = 'https://alesue.onrender.com/';

  AluxeDatabase._init();
  factory AluxeDatabase.instance() => _instance;

  /// Registro de usuario (llama a /register del backend)
  Future<bool> registerUser({
    required String username,
    required String password,
    String role = 'estudiante', // Por defecto estudiante
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );
    return response.statusCode == 200;
  }

  // Login (llama a /login del backend)
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
    return null;
  }

  // Puedes agregar más métodos para retos, estudiantes, etc.
}
