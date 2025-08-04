import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';
import 'package:flutter/material.dart';

class RegistroEstudianteScreen extends StatefulWidget {
  const RegistroEstudianteScreen({super.key});

  @override
  State<RegistroEstudianteScreen> createState() =>
      _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _edadController = TextEditingController();
  final _gradoController = TextEditingController();
  final _seccionController = TextEditingController();
  String? _sexoSeleccionado;
  bool _mostrarPassword = false;
  final AluxeDatabase _db = AluxeDatabase.instance();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _edadController.dispose();
    _gradoController.dispose();
    _seccionController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final password = _passwordController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final dni = _dniController.text.trim();
    final edadStr = _edadController.text.trim();
    final grado = _gradoController.text.trim();
    final seccion = _seccionController.text.trim();
    final sexo = _sexoSeleccionado ?? '';
    final email = _emailController.text.trim();

    // Validaciones
    if (password.isEmpty ||
        nombre.isEmpty ||
        apellido.isEmpty ||
        dni.isEmpty ||
        edadStr.isEmpty ||
        grado.isEmpty ||
        seccion.isEmpty ||
        sexo.isEmpty ||
        email.isEmpty) {
      setState(() {
        _error = 'Todos los campos son obligatorios';
      });
      return;
    }

    if (dni.length != 8 || !dni.isNumericOnly) {
      setState(() {
        _error = 'El DNI debe tener 8 dígitos';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Email inválido';
      });
      return;
    }

    int edad;
    try {
      edad = int.parse(edadStr);
      if (edad < 12 || edad > 100) {
        setState(() {
          _error = 'Edad debe estar entre 12 y 100';
        });
        return;
      }
    } on FormatException {
      setState(() {
        _error = 'Edad inválida';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Llamar a la nueva API de registro usando DNI como username
      await _db.registerUsuario(
        username: dni, // DNI como username
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rol: "estudiante",
        dni: dni,
        edad: edad,
        grado: grado,
        seccion: seccion,
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
    _emailController.clear();
    _passwordController.clear();
    _nombreController.clear();
    _apellidoController.clear();
    _dniController.clear();
    _edadController.clear();
    _gradoController.clear();
    _seccionController.clear();
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
                const Text(
                  'Registro de Estudiante',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Email
                _buildTextField(
                  _emailController,
                  'Email',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: !_mostrarPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
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

                // DNI
                _buildTextField(
                  _dniController,
                  'DNI (8 dígitos)',
                  keyboardType: TextInputType.number,
                  icon: Icons.badge,
                  maxLength: 8,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
                const SizedBox(height: 16),

                // Edad
                _buildTextField(
                  _edadController,
                  'Edad',
                  keyboardType: TextInputType.number,
                  icon: Icons.cake,
                ),
                const SizedBox(height: 16),

                // Grado
                _buildTextField(
                  _gradoController,
                  'Grado (ej: 6° de primaria)',
                  icon: Icons.school,
                ),
                const SizedBox(height: 16),

                // Sección
                _buildTextField(
                  _seccionController,
                  'Sección (ej: A)',
                  icon: Icons.class_,
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
                    backgroundColor: Colors.blue,
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
                          'Registrarse como Estudiante',
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
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
        counterText: '',
      ),
    );
  }
}

extension on String {
  bool get isNumericOnly => RegExp(r'^[0-9]+$').hasMatch(this);
}
