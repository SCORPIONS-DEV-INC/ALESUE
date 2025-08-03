import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';
import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _correoController = TextEditingController();
  final _edadController = TextEditingController();
  final _gradoController = TextEditingController();
  final _seccionController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _sexoSeleccionado;
  bool _mostrarPassword = false;
  final AluxeDatabase _db = AluxeDatabase.instance();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _correoController.dispose();
    _edadController.dispose();
    _gradoController.dispose();
    _seccionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final dni = _dniController.text.trim();
    final correo = _correoController.text.trim();
    final edadStr = _edadController.text.trim();
    final grado = _gradoController.text.trim();
    final seccion = _seccionController.text.trim();
    final password = _passwordController.text.trim();
    final sexo = _sexoSeleccionado ?? '';
    // Validaciones
    if (nombre.isEmpty ||
        apellido.isEmpty ||
        dni.isEmpty ||
        edadStr.isEmpty ||
        grado.isEmpty ||
        seccion.isEmpty ||
        sexo.isEmpty ||
        password.isEmpty) {
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

    if (correo.isNotEmpty && !correo.contains('@')) {
      setState(() {
        _error = 'Correo inválido';
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
    // ID del colegio o tenant (puedes cambiarlo)
    const String tenantId = 'colegio_san_martin';

    try {
      // Llama a la API del backend para registrar usuario (puedes adaptar los campos según tu backend)
      final exito = await _db.registerUser(
        username: nombre,
        password: password,
        role: 'estudiante',
      );

      if (exito) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Registro exitoso')));
        _limpiarCampos();
        Navigator.pop(context);
      } else {
        setState(() {
          _error =
              'Error al registrar. Intenta con otro usuario o revisa los datos.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al registrar: $e';
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
    _nombreController.clear();
    _apellidoController.clear();
    _dniController.clear();
    _correoController.clear();
    _edadController.clear();
    _gradoController.clear();
    _seccionController.clear();
    _passwordController.clear();
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
                const SizedBox(height: 40),
                const Text(
                  'Aluxe App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Registro de Estudiante',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Nombre
                _buildTextField(
                  _nombreController,
                  'Nombre',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _apellidoController,
                  'Apellido',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
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
                _buildTextField(
                  _correoController,
                  'Correo electrónico (opcional)',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _edadController,
                  'Edad',
                  keyboardType: TextInputType.number,
                  icon: Icons.cake,
                ),
                const SizedBox(height: 16),
                // Campo grado oculto, valor fijo
                Builder(
                  builder: (context) {
                    _gradoController.text = '6° de primaria';
                    return const SizedBox.shrink();
                  },
                ),
                // ...existing code...
                _buildTextField(
                  _seccionController,
                  'Sección (ej: A)',
                  icon: Icons.class_,
                ),
                const SizedBox(height: 16),
                // Campo contraseña con mostrar/ocultar
                TextField(
                  controller: _passwordController,
                  obscureText: !_mostrarPassword,
                  keyboardType: TextInputType.visiblePassword,
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
                // Campo sexo como dropdown mejorado
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _registrar,
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
                          'Registrarse',
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
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
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

Widget _buildTextField(
  TextEditingController controller,
  String hintText, {
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

extension on String {
  bool get isNumericOnly => RegExp(r'^[0-9]+$').hasMatch(this);
}
