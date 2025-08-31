import 'dart:convert';
import 'package:http/http.dart' as http;

class AluxeDatabase {
  /// Registro general de usuario (profesor o estudiante)
  Future<bool> registerUsuario({
    required String username,
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol,
    required String dni,
    String? sexo,
    int? edad,
    String? grado,
    String? seccion,
    String? tenantId,
  }) async {
    final url = Uri.parse('${AluxeDatabase.baseUrl}auth/register');
    final Map<String, dynamic> body = {
      'username': username,
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'dni': dni,
      'tenant_id': tenantId ?? 'default',
    };
    if (sexo != null) body['sexo'] = sexo;
    if (edad != null) body['edad'] = edad;
    if (grado != null) body['grado'] = grado;
    if (seccion != null) body['seccion'] = seccion;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al registrar usuario');
    }
  }

  /// Registro de estudiante con fecha de nacimiento (pantalla RegistroScreen)
  Future<bool> registerEstudianteConFechaNacimiento({
    required String dni,
    required String nombre,
    required String apellido,
    required String fechaNacimiento, // formato YYYY-MM-DD
    required String grado,
    required String seccion,
    required String sexo,
    required String correo,
    required String tenantId,
    String? password,
  }) async {
    final url = Uri.parse('${AluxeDatabase.baseUrl}estudiantes/');
    final Map<String, dynamic> body = {
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento,
      'grado': grado,
      'seccion': seccion,
      'sexo': sexo,
      'correo': correo,
      'password': password ?? 'estudiante123',
      'tenant_id': tenantId,
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al registrar estudiante');
    }
  }

  static final AluxeDatabase _instance = AluxeDatabase._init();
  static const String baseUrl = 'https://alesue.onrender.com/';
  AluxeDatabase._init();
  factory AluxeDatabase.instance() => _instance;

  // Crear reto (con o sin preguntas)
  Future<Map<String, dynamic>?> createReto({
    required String token,
    required String titulo,
    required String descripcion,
    required int puntos,
    required String nivel,
    required String materia,
    required String tenantId,
    List<dynamic>? preguntas, // Lista de preguntas opcional
  }) async {
    try {
      if (token.trim().isEmpty) {
        throw Exception('Token de autenticación requerido');
      }
      final url = Uri.parse('${baseUrl}retos/');
      final requestBody = {
        'titulo': titulo,
        'descripcion': descripcion,
        'puntos': puntos,
        'nivel': nivel,
        'materia': materia,
        'tenant_id': tenantId,
      };
      if (preguntas != null && preguntas.isNotEmpty) {
        requestBody['preguntas'] = preguntas;
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? 'Error al crear el reto';
        } catch (e) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Error ${response.statusCode}';
        }
        if (response.statusCode == 401) {
          errorMessage =
              'Token de autenticación inválido o expirado. Por favor, inicia sesión nuevamente.';
        } else if (response.statusCode == 403) {
          errorMessage = 'No tienes permisos para crear retos';
        } else if (response.statusCode == 500) {
          errorMessage =
              'Error interno del servidor. Intenta de nuevo en unos momentos.';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error en createReto: $e');
      rethrow;
    }
  }

  // Crear estudiante (solo profesores)
  Future<Map<String, dynamic>?> createEstudianteByProfesor({
    required String token,
    required String dni,
    required String nombre,
    required String apellido,
    required int edad,
    required String grado,
    required String seccion,
    required String sexo,
    String? email,
    required String password,
    required String tenantId,
  }) async {
    final url = Uri.parse('${baseUrl}auth/crear-estudiante');
    final Map<String, dynamic> requestBody = {
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'grado': grado,
      'seccion': seccion,
      'sexo': sexo,
      'password': password,
      'tenant_id': tenantId,
    };
    if (email != null && email.isNotEmpty) {
      requestBody['email'] = email;
    }
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al crear estudiante');
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

  // Completar reto (solo estudiantes)
  Future<bool> completarReto({
    required String token,
    required int retoId,
    required int puntosObtenidos,
  }) async {
    final url = Uri.parse('${baseUrl}retos/completar');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'reto_id': retoId,
        'puntos_obtenidos': puntosObtenidos,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Obtener ranking
  Future<List<Map<String, dynamic>>> getRanking({
    required String token,
    String? materia,
    String? grado,
  }) async {
    String url = '${baseUrl}auth/ranking';
    List<String> params = [];

    if (materia != null) params.add('materia=$materia');
    if (grado != null) params.add('grado=$grado');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
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

  // Obtener retos por materia
  Future<List<Map<String, dynamic>>> getRetosByMateria({
    required String token,
    required String materia,
  }) async {
    final url = Uri.parse('${baseUrl}retos/por-materia/$materia');
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

  // Obtener mi progreso (estudiantes)
  Future<List<Map<String, dynamic>>> getMiProgreso(String token) async {
    final url = Uri.parse('${baseUrl}retos/mi-progreso');
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

  // Obtener mis retos creados (profesores)
  Future<List<Map<String, dynamic>>> getMisRetos(String token) async {
    try {
      final url = Uri.parse('${baseUrl}retos/mis-retos');
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
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener mis retos');
      }
    } catch (e) {
      print('Error en getMisRetos: $e');
      rethrow;
    }
  }

  // Eliminar reto (solo profesores)
  Future<bool> eliminarReto({
    required String token,
    required int retoId,
  }) async {
    try {
      final url = Uri.parse('${baseUrl}retos/$retoId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar el reto');
      }
    } catch (e) {
      print('Error en eliminarReto: $e');
      rethrow;
    }
  }

  // Actualizar reto (solo profesores)
  Future<bool> actualizarReto({
    required String token,
    required int retoId,
    required String titulo,
    required String descripcion,
    required int puntos,
    required String nivel,
    required String materia,
  }) async {
    try {
      final url = Uri.parse('${baseUrl}retos/$retoId');
      final requestBody = {
        'titulo': titulo,
        'descripcion': descripcion,
        'puntos': puntos,
        'nivel': nivel,
        'materia': materia,
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar el reto');
      }
    } catch (e) {
      print('Error en actualizarReto: $e');
      rethrow;
    }
  }
}
