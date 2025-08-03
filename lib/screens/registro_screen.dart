<<<<<<< HEAD
// screens/registro_screen.dart
import 'package:aluxe/backend/db/aluxe_database.dart';
import 'package:flutter/material.dart';
=======
import 'package:flutter/material.dart';
import '../../backend/models/estudiante.dart';
import '../../backend/db/database:helper.dart';
>>>>>>> origin/main

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
<<<<<<< HEAD
  final _dniController = TextEditingController();
  final _correoController = TextEditingController();
  final _edadController = TextEditingController();
  final _gradoController = TextEditingController();
  final _seccionController = TextEditingController();
  final _sexoController = TextEditingController();

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
    _sexoController.dispose();
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
    final sexo = _sexoController.text.trim();
=======
  final _edadController = TextEditingController();
  final _dniController = TextEditingController();
  final _correoController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance();
  bool _isLoading = false;
  String? _error;

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final edadStr = _edadController.text;
    final dni = _dniController.text;
    final correo = _correoController.text.trim();
>>>>>>> origin/main

    // Validaciones
    if (nombre.isEmpty ||
        apellido.isEmpty ||
<<<<<<< HEAD
        dni.isEmpty ||
        edadStr.isEmpty ||
        grado.isEmpty ||
        seccion.isEmpty ||
        sexo.isEmpty) {
=======
        edadStr.isEmpty ||
        dni.isEmpty ||
        correo.isEmpty) {
>>>>>>> origin/main
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

<<<<<<< HEAD
    if (correo.isNotEmpty && !correo.contains('@')) {
=======
    if (!correo.contains('@')) {
>>>>>>> origin/main
      setState(() {
        _error = 'Correo inválido';
      });
      return;
    }

    int edad;
    try {
      edad = int.parse(edadStr);
<<<<<<< HEAD
      if (edad < 5 || edad > 20) {
        setState(() {
          _error = 'Edad debe estar entre 5 y 20 años';
=======
      if (edad < 12 || edad > 100) {
        setState(() {
          _error = 'Edad debe estar entre 12 y 100';
>>>>>>> origin/main
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

<<<<<<< HEAD
    // ID del colegio o tenant (puedes cambiarlo)
    const String tenantId = 'colegio_san_martin';

    try {
      // 1. Insertar en registro
      await _db.insertRegistro({
        'dni': dni,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'tenant_id': tenantId,
      });

      // 2. Insertar en login (usuario = nombre, contraseña = dni)
      await _db.insertLogin({
        'dni': dni,
        'usuario': nombre,
        'contraseña': dni,
        'tenant_id': tenantId,
      });

      // 3. Insertar en estudiante (clona nombre/apellido, añade detalles)
      await _db.insertEstudiante({
        'dni': dni,
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'grado': grado,
        'seccion': seccion,
        'sexo': sexo,
        'tenant_id': tenantId,
      });

      // ✅ Éxito
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Registro exitoso')));
      _limpiarCampos();
      Navigator.pop(context);
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al registrar';
      });
      print('❌ Error en registro: $e');
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
    _sexoController.clear();
=======
    final nuevo = Estudiante(
      nombre: nombre,
      apellido: apellido,
      edad: edad,
      dni: dni,
      correo: correo,
      puesto: null, // Se asignará posteriormente
      calificacion: null, // Se asignará posteriormente
    );

    final id = await _dbHelper.insertEstudiante(nuevo);
    if (id == -1) {
      setState(() {
        _error = 'DNI o correo ya registrado';
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      Navigator.pop(context); // Volver al login
    }

    setState(() {
      _isLoading = false;
    });
>>>>>>> origin/main
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
=======
>>>>>>> origin/main
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
<<<<<<< HEAD
                const SizedBox(height: 20),
=======
                const SizedBox(height: 40),
>>>>>>> origin/main
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
                  'Registro de Estudiante',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
<<<<<<< HEAD
                const SizedBox(height: 30),

                // Nombre
                _buildTextField(_nombreController, 'Nombre'),
                _buildTextField(_apellidoController, 'Apellido'),
                _buildTextField(
                  _dniController,
                  'DNI (8 dígitos)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _correoController,
                  'Correo electrónico (opcional)',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  _edadController,
                  'Edad',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(_gradoController, 'Grado (ej: 3° Secundaria)'),
                _buildTextField(_seccionController, 'Sección (ej: A)'),
                _buildTextField(_sexoController, 'Sexo (Masculino/Femenino)'),

                const SizedBox(height: 24),

=======
                const SizedBox(height: 40),
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    hintText: 'Nombre',
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
                TextField(
                  controller: _apellidoController,
                  decoration: InputDecoration(
                    hintText: 'Apellido',
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
                TextField(
                  controller: _edadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Edad',
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
                TextField(
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'DNI (8 dígitos)',
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
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
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
>>>>>>> origin/main
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
<<<<<<< HEAD

                const SizedBox(height: 16),

=======
                const SizedBox(height: 24),
>>>>>>> origin/main
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
<<<<<<< HEAD

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// Extensión para verificar si un String es solo numérico
=======
}

>>>>>>> origin/main
extension on String {
  bool get isNumericOnly => RegExp(r'^[0-9]+$').hasMatch(this);
}
