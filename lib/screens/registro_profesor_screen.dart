import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class RegistroProfesorScreen extends StatefulWidget {
  const RegistroProfesorScreen({super.key});

  @override
  State<RegistroProfesorScreen> createState() => _RegistroProfesorScreenState();
}

class _RegistroProfesorScreenState extends State<RegistroProfesorScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  String? _sexoSeleccionado;
  bool _mostrarPassword = false;
  final AluxeDatabase _db = AluxeDatabase.instance();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final sexo = _sexoSeleccionado ?? '';

    // Validaciones
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        nombre.isEmpty ||
        apellido.isEmpty ||
        sexo.isEmpty) {
      setState(() {
        _error = 'Todos los campos son obligatorios';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Email inválido';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Llamar a la nueva API de registro
      await _db.registerUsuario(
        username: username,
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rol: "profesor",
        sexo: sexo,
        tenantId: "colegio_san_martin",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Registro exitoso')));
      _limpiarCampos();
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _limpiarCampos() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _nombreController.clear();
    _apellidoController.clear();
    _sexoSeleccionado = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icono de profesor
                const Icon(Icons.person, size: 80, color: Colors.green),

                const SizedBox(height: 20),

                const Text(
                  'Registro de Profesor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Username
                _buildTextField(
                  _usernameController,
                  'Nombre de usuario',
                  icon: Icons.account_circle,
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  _emailController,
                  'Email institucional',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: !_mostrarPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña (mínimo 6 caracteres)',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarPassword = !_mostrarPassword;
                        });
                      },
                    ),
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
                const SizedBox(height: 16),

                // Nombre
                _buildTextField(
                  _nombreController,
                  'Nombre',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),

                // Apellido
                _buildTextField(
                  _apellidoController,
                  'Apellido',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Sexo
                DropdownButtonFormField<String>(
                  value: _sexoSeleccionado,
                  items: const [
                    DropdownMenuItem(
                      value: 'Masculino',
                      child: Row(
                        children: [
                          Icon(Icons.male, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Masculino'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Femenino',
                      child: Row(
                        children: [
                          Icon(Icons.female, color: Colors.pink),
                          SizedBox(width: 8),
                          Text('Femenino'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sexoSeleccionado = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Sexo',
                    prefixIcon: const Icon(
                      Icons.transgender,
                      color: Colors.grey,
                    ),
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

                // Botón registrar
                ElevatedButton(
                  onPressed: _isLoading ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                          'Registrarse como Profesor',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.info, color: Colors.green, size: 24),
                      SizedBox(height: 8),
                      Text(
                        'Como profesor podrás:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Crear retos y actividades\n• Ver el progreso de estudiantes\n• Gestionar contenido educativo',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
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
    );
  }
}
