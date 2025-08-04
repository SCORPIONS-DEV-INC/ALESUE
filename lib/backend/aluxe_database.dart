import 'dart:convert';
import 'package:http/http.dart' as http;

class AluxeDatabase {
  static final AluxeDatabase _instance = AluxeDatabase._init();
  // Cambia esta URL por la de tu backend en Render para producción
  static const String baseUrl = 'https://alesue.onrender.com/';

  AluxeDatabase._init();
  factory AluxeDatabase.instance() => _instance;

  /// Registro de usuario (llama a /auth/register del backend)
  Future<Map<String, dynamic>?> registerUsuario({
    required String username,
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol, // "estudiante" o "profesor"
    String? dni,
    int? edad,
    String? grado,
    String? seccion,
    String? sexo,
    required String tenantId,
  }) async {
    final url = Uri.parse('${baseUrl}auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol,
        'dni': dni,
        'edad': edad,
        'grado': grado,
        'seccion': seccion,
        'sexo': sexo,
        'tenant_id': tenantId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Devolver el error para mostrarlo al usuario
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Error en el registro');
    }
  }

  /// Registro de estudiante (mantener compatibilidad, pero usar registerUsuario)
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
    try {
      final result = await registerUsuario(
        username: dni, // Usar DNI como username para estudiantes
        email: correo,
        password: "123456", // Password por defecto (cambiar luego)
        nombre: nombre,
        apellido: apellido,
        rol: "estudiante",
        dni: dni,
        edad: edad,
        grado: grado,
        seccion: seccion,
        sexo: sexo,
        tenantId: tenantId,
      );
      return result != null;
    } catch (e) {
      print('Error registrando estudiante: $e');
      return false;
    }
  }

  // Login (llama a /auth/login del backend)
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${baseUrl}auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Error en el login');
    }
  }

  // Obtener retos (requiere autenticación)
  Future<List<Map<String, dynamic>>> getRetos(String token) async {
    final url = Uri.parse('${baseUrl}retos/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Crear reto (solo profesores)
  Future<Map<String, dynamic>?> createReto({
    required String token,
    required String titulo,
    required String descripcion,
    required int puntos,
    required String nivel,
    required String materia,
    required String tenantId,
  }) async {
    final url = Uri.parse('${baseUrl}retos/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'puntos': puntos,
        'nivel': nivel,
        'materia': materia,
        'tenant_id': tenantId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
