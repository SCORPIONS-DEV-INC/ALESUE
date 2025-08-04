import 'dart:convert';
import 'package:http/http.dart' as http;

class AluxeDatabase {
  static final AluxeDatabase _instance = AluxeDatabase._init();
  // Cambia esta URL por la de tu backend en Render para producción
  static const String baseUrl = 'https://alesue.onrender.com/';

  AluxeDatabase._init();
  factory AluxeDatabase.instance() => _instance;

  /// Registro de estudiante (llama a /estudiantes del backend)
  Future<bool> registerEstudiante({
    required String dni,
    required String nombre,
    required String apellido,
    required int edad,
    required String grado,
    required String seccion,
    required String sexo,
    required String correo,
    required String tenantId,
  }) async {
    final url = Uri.parse('${baseUrl}estudiantes/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dni': dni,
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'grado': grado,
        'seccion': seccion,
        'sexo': sexo,
        'correo': correo,
        'tenant_id': tenantId,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
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
}
