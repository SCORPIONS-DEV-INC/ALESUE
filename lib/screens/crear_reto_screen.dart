import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class CrearRetoScreen extends StatefulWidget {
  final String token;

  const CrearRetoScreen({super.key, required this.token});

  @override
  State<CrearRetoScreen> createState() => _CrearRetoScreenState();
}

class _CrearRetoScreenState extends State<CrearRetoScreen> {
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
    _puntosController.text = '10'; // Valor por defecto
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _puntosController.dispose();
    super.dispose();
  }

  Future<void> _crearReto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_materiaSeleccionada == null) {
      setState(() {
        _error = 'Por favor selecciona una materia';
      });
      return;
    }

    if (_nivelSeleccionado == null) {
      setState(() {
        _error = 'Por favor selecciona un nivel';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resultado = await _db.createReto(
        token: widget.token,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        puntos: int.parse(_puntosController.text.trim()),
        nivel: _nivelSeleccionado!,
        materia: _materiaSeleccionada!,
        tenantId: "default",
      );

      if (resultado != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retornar true para indicar éxito
        }
      } else {
        setState(() {
          _error = 'Error al crear el reto';
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

  Color _getMateriaColor(String materia) {
    switch (materia) {
      case 'matematicas':
        return Colors.blue;
      case 'comunicacion':
        return Colors.green;
      case 'personal_social':
        return Colors.orange;
      case 'ciencia_tecnologia':
        return Colors.purple;
      case 'ingles':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getMateriaIcon(String materia) {
    switch (materia) {
      case 'matematicas':
        return Icons.calculate;
      case 'comunicacion':
        return Icons.book;
      case 'personal_social':
        return Icons.people;
      case 'ciencia_tecnologia':
        return Icons.science;
      case 'ingles':
        return Icons.language;
      default:
        return Icons.subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reto'),
        backgroundColor: Colors.indigo,
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

              // Título del reto
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Reto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Ej: Multiplicación de fracciones',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (value.length < 5) {
                    return 'El título debe tener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Reto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Describe qué debe hacer el estudiante...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.length < 20) {
                    return 'La descripción debe tener al menos 20 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Materia
              DropdownButtonFormField<String>(
                value: _materiaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                items: _materias.map((materia) {
                  return DropdownMenuItem<String>(
                    value: materia['value'],
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getMateriaColor(materia['value']!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _getMateriaIcon(materia['value']!),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(materia['label']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _materiaSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'La materia es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nivel
              DropdownButtonFormField<String>(
                value: _nivelSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Nivel de Dificultad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: _niveles.map((nivel) {
                  Color color = Colors.grey;
                  IconData icon = Icons.help;

                  switch (nivel['value']) {
                    case 'facil':
                      color = Colors.green;
                      icon = Icons.sentiment_satisfied;
                      break;
                    case 'medio':
                      color = Colors.orange;
                      icon = Icons.sentiment_neutral;
                      break;
                    case 'dificil':
                      color = Colors.red;
                      icon = Icons.sentiment_very_dissatisfied;
                      break;
                  }

                  return DropdownMenuItem<String>(
                    value: nivel['value'],
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 8),
                        Text(nivel['label']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _nivelSeleccionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'El nivel es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Puntos
              TextFormField(
                controller: _puntosController,
                decoration: const InputDecoration(
                  labelText: 'Puntos por Completar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                  suffixText: 'pts',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Los puntos son obligatorios';
                  }
                  final puntos = int.tryParse(value);
                  if (puntos == null || puntos < 1 || puntos > 100) {
                    return 'Los puntos deben estar entre 1 y 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Vista previa del reto
              if (_materiaSeleccionada != null || _nivelSeleccionado != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vista Previa:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_materiaSeleccionada != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getMateriaColor(_materiaSeleccionada!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getMateriaIcon(_materiaSeleccionada!),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _materias.firstWhere(
                                      (m) => m['value'] == _materiaSeleccionada,
                                    )['label']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_nivelSeleccionado != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _nivelSeleccionado == 'facil'
                                      ? Colors.green
                                      : _nivelSeleccionado == 'medio'
                                      ? Colors.orange
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _niveles.firstWhere(
                                    (n) => n['value'] == _nivelSeleccionado,
                                  )['label']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Botón crear
              ElevatedButton(
                onPressed: _isLoading ? null : _crearReto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Reto',
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
