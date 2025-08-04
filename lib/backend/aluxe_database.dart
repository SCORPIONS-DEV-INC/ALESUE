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
    String? password, // Hacer password opcional
  }) async {
    try {
      final result = await registerUsuario(
        username: dni, // Usar DNI como username para estudiantes
        email: correo,
        password:
            password ??
            "estudiante123", // Password por defecto si no se proporciona
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
    try {
      // Verificar que el token no esté vacío
      if (token.trim().isEmpty) {
        throw Exception('Token de autenticación requerido');
      }

      final url = Uri.parse('${baseUrl}retos/');
      print('Enviando reto a: $url');

      final requestBody = {
        'titulo': titulo,
        'descripcion': descripcion,
        'puntos': puntos,
        'nivel': nivel,
        'materia': materia,
        'tenant_id': tenantId,
      };

      print('Body del request: $requestBody');
      print('Token usado: ${token.substring(0, 20)}...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Manejar diferentes tipos de errores
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? 'Error al crear el reto';
        } catch (e) {
          // Si no es JSON válido, usar el texto directo
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Error ${response.statusCode}';
        }

        // Proporcionar mensajes más específicos
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
  } // Crear reto con preguntas (solo profesores)

  Future<Map<String, dynamic>?> createRetoConPreguntas({
    required String token,
    required String titulo,
    required String descripcion,
    required int puntos,
    required String nivel,
    required String materia,
    required String tenantId,
    required List preguntas, // Lista de preguntas con sus opciones
  }) async {
    try {
      // Por ahora, usar el método tradicional ya que el backend no soporta preguntas
      print(
        'Creando reto con ${preguntas.length} preguntas (usando método tradicional)',
      );

      return createReto(
        token: token,
        titulo: titulo,
        descripcion: descripcion,
        puntos: puntos,
        nivel: nivel,
        materia: materia,
        tenantId: tenantId,
      );
    } catch (e) {
      print('Error en createRetoConPreguntas: $e');
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
    String? email, // Hacer email opcional
    required String password,
    required String tenantId,
  }) async {
    final url = Uri.parse('${baseUrl}auth/crear-estudiante');

    // Construir el body dinámicamente, excluyendo email si es null
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

    // Solo agregar email si no es null
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
      print('Obteniendo mis retos de: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Mis retos status code: ${response.statusCode}');
      print('Mis retos response: ${response.body}');

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
}
