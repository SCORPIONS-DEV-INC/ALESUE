// screens/login_screen.dart
import 'package:aluxe/backend/db/aluxe_database.dart';
import 'package:flutter/material.dart';
import '../../backend/models/estudiante.dart';
import 'home_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController =
      TextEditingController(); // Nombre (usuario)
  final TextEditingController _dniController =
      TextEditingController(); // DNI (contraseña)
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usuarioController.dispose();
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Maneja el inicio de sesión
  Future<void> _login() async {
    final String usuario = _usuarioController.text.trim();
    final String dni = _dniController.text.trim();
    final String password = _passwordController.text;

    // Validaciones
    if (usuario.isEmpty || dni.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Por favor, completa todos los campos';
      });
      return;
    }

    if (dni.length != 8 || !dni.isNumericOnly) {
      setState(() {
        _error = 'El DNI debe tener 8 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 🔐 Autenticación: usuario = nombre, contraseña = dni
      final userData = await AluxeDatabase.instance().login(usuario, dni);

      if (userData != null) {
        // ✅ Login exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(userData: userData, estudiante: null),
          ),
        );
      } else {
        // Aquí iría la lógica de autenticación real con la base de datos
        await Future.delayed(const Duration(seconds: 1)); // Simulación

        // Por ahora, simulamos una validación simple
        if (dni == '12345678' && password == 'password123') {
          // Ejemplo de estudiante para pruebas
          final estudiante = Estudiante(
            nombre: 'Juan',
            apellido: 'Pérez',
            edad: 12,
            dni: dni,
            correo: 'juan@example.com',
            grado: '3°',
            seccion: 'A',
            sexo: 'Masculino',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(estudiante: estudiante),
            ),
          );
        } else {
          setState(() {
            _error = 'Nombre o DNI incorrectos';
          });
        }
      }
    } on Exception catch (e) {
      setState(() {
        _error = 'Error al conectar con la base de datos';
      });
      print('❌ Error en login: $e');
    } catch (e) {
      setState(() {
        _error = 'Error al iniciar sesión';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'aluxe app',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Ingresa tu DNI y contraseña para acceder',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Campo: Nombre (Usuario)
                TextField(
                  controller: _usuarioController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Tu nombre',
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),

                // Campo: DNI
                TextField(
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'DNI (8 dígitos)',
                    prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),

                // Campo: Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),

                // Mensaje de error
                const SizedBox(height: 20),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),

                // Enlace a registro
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿No tienes una cuenta? Regístrate',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Al hacer clic en continuar, acepta nuestros Términos de servicio y Política de privacidad.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extensión para verificar si un String es solo numérico
extension IsNumericOnly on String {
  bool get isNumericOnly => RegExp(r'^[0-9]+$').hasMatch(this);
}
