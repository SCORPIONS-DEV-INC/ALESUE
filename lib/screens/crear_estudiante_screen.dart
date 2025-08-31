import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class CrearEstudianteScreen extends StatefulWidget {
  final String token;

  const CrearEstudianteScreen({super.key, required this.token});

  @override
  State<CrearEstudianteScreen> createState() => _CrearEstudianteScreenState();
}

class _CrearEstudianteScreenState extends State<CrearEstudianteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();
  final _gradoController = TextEditingController();
  final _seccionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _sexoSeleccionado;
  bool _isLoading = false;
  String? _error;
  final AluxeDatabase _db = AluxeDatabase.instance();

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    _gradoController.dispose();
    _seccionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _crearEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_sexoSeleccionado == null) {
      setState(() {
        _error = 'Por favor selecciona el sexo del estudiante';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Si no se proporciona email, enviar null
      final email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();

      final resultado = await _db.createEstudianteByProfesor(
        token: widget.token,
        dni: _dniController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        edad: int.parse(_edadController.text.trim()),
        grado: _gradoController.text.trim(),
        seccion: _seccionController.text.trim(),
        sexo: _sexoSeleccionado!,
        email: email,
        password: _passwordController.text.trim(),
        tenantId: "default",
      );

      if (resultado != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estudiante creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retornar true para indicar éxito
        }
      } else {
        setState(() {
          _error = 'Error al crear el estudiante';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Estudiante'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // DNI
              TextFormField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El DNI es obligatorio';
                  }
                  if (value.length != 8) {
                    return 'El DNI debe tener 8 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Edad
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La edad es obligatoria';
                  }
                  final edad = int.tryParse(value);
                  if (edad == null || edad < 6 || edad > 18) {
                    return 'La edad debe estar entre 6 y 18 años';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grado
              TextFormField(
                controller: _gradoController,
                decoration: const InputDecoration(
                  labelText: 'Grado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El grado es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sección
              TextFormField(
                controller: _seccionController,
                decoration: const InputDecoration(
                  labelText: 'Sección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La sección es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sexo
              DropdownButtonFormField<String>(
                initialValue: _sexoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexoSeleccionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'El sexo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Ej: estudiante@colegio.edu.pe',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  // Email es opcional, solo validar si se proporciona
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.contains('@')) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón crear
              ElevatedButton(
                onPressed: _isLoading ? null : _crearEstudiante,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Estudiante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
