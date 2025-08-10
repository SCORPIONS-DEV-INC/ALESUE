import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class EditarRetoScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> reto;

  const EditarRetoScreen({super.key, required this.token, required this.reto});

  @override
  State<EditarRetoScreen> createState() => _EditarRetoScreenState();
}

class _EditarRetoScreenState extends State<EditarRetoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _puntosController = TextEditingController();

  String? _materiaSeleccionada;
  String? _nivelSeleccionado;
  bool _isLoading = false;
  String? _error;
  final AluxeDatabase _db = AluxeDatabase.instance();

  final List<Map<String, String>> _materias = [
    {'value': 'matematicas', 'label': 'Matemáticas'},
    {'value': 'comunicacion', 'label': 'Comunicación'},
    {'value': 'personal_social', 'label': 'Personal Social'},
    {'value': 'ciencia_tecnologia', 'label': 'Ciencia y Tecnología'},
    {'value': 'ingles', 'label': 'Inglés'},
  ];

  final List<Map<String, String>> _niveles = [
    {'value': 'facil', 'label': 'Fácil'},
    {'value': 'medio', 'label': 'Medio'},
    {'value': 'dificil', 'label': 'Difícil'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosReto();
  }

  void _cargarDatosReto() {
    _tituloController.text = widget.reto['titulo'] ?? '';
    _descripcionController.text = widget.reto['descripcion'] ?? '';
    _puntosController.text = widget.reto['puntos']?.toString() ?? '10';
    _materiaSeleccionada = widget.reto['materia'];
    _nivelSeleccionado = widget.reto['nivel'];
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _puntosController.dispose();
    super.dispose();
  }

  Future<void> _actualizarReto() async {
    if (!_formKey.currentState!.validate()) return;

    if (_materiaSeleccionada == null || _nivelSeleccionado == null) {
      setState(() {
        _error = 'Por favor completa todos los campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _db.actualizarReto(
        token: widget.token,
        retoId: widget.reto['id'],
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? 'Sin descripción'
            : _descripcionController.text.trim(),
        puntos: int.parse(_puntosController.text.trim()),
        nivel: _nivelSeleccionado!,
        materia: _materiaSeleccionada!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Error al actualizar el reto';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Editar Reto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _actualizarReto,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            _buildInputField(
              controller: _tituloController,
              label: 'Título del reto',
              hint: 'Ingresa el título del reto',
              icon: Icons.title,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Descripción
            _buildInputField(
              controller: _descripcionController,
              label: 'Descripción (Opcional)',
              hint: 'Describe el reto para los estudiantes',
              icon: Icons.description,
              maxLines: 3,
              // Sin validador - descripción opcional
            ),

            const SizedBox(height: 16),

            // Puntos
            _buildInputField(
              controller: _puntosController,
              label: 'Puntos',
              hint: 'Puntos que otorga el reto',
              icon: Icons.star,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Los puntos son obligatorios';
                }
                final puntos = int.tryParse(value!);
                if (puntos == null || puntos <= 0) {
                  return 'Ingresa un número válido mayor a 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Materia
            _buildDropdownField(
              label: 'Materia',
              value: _materiaSeleccionada,
              items: _materias,
              hint: 'Selecciona una materia',
              icon: Icons.book,
              onChanged: (value) {
                setState(() {
                  _materiaSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Nivel
            _buildDropdownField(
              label: 'Nivel de dificultad',
              value: _nivelSeleccionado,
              items: _niveles,
              hint: 'Selecciona el nivel',
              icon: Icons.speed,
              onChanged: (value) {
                setState(() {
                  _nivelSeleccionado = value;
                });
              },
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botón actualizar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _actualizarReto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
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
                        'Actualizar Reto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.blue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
