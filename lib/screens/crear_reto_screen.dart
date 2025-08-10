import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class CrearRetoScreen extends StatefulWidget {
  final String token;

  const CrearRetoScreen({super.key, required this.token});

  @override
  State<CrearRetoScreen> createState() => _CrearRetoScreenState();
}

class _CrearRetoScreenState extends State<CrearRetoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _puntosController = TextEditingController();

  String? _materiaSeleccionada;
  String? _nivelSeleccionado;
  bool _isLoading = false;
  String? _error;
  final AluxeDatabase _db = AluxeDatabase.instance();

  int _currentStep = 0; // 0: info básica, 1: configuración, 2: revisión
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _materias = [
    {'value': 'matematicas', 'label': 'Matemáticas', 'emoji': '📐'},
    {'value': 'comunicacion', 'label': 'Comunicación', 'emoji': '📚'},
    {'value': 'personal_social', 'label': 'Personal Social', 'emoji': '🏛️'},
    {
      'value': 'ciencia_tecnologia',
      'label': 'Ciencia y Tecnología',
      'emoji': '🔬',
    },
    {'value': 'ingles', 'label': 'Inglés', 'emoji': '🌎'},
  ];

  final List<Map<String, String>> _niveles = [
    {'value': 'facil', 'label': 'Fácil', 'emoji': '😊', 'color': '4CAF50'},
    {'value': 'medio', 'label': 'Medio', 'emoji': '😐', 'color': 'FF9800'},
    {'value': 'dificil', 'label': 'Difícil', 'emoji': '😤', 'color': 'F44336'},
  ];

  @override
  void initState() {
    super.initState();
    _puntosController.text = '10'; // Valor por defecto
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _puntosController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _crearReto() async {
    if (_formKey.currentState?.validate() != true) {
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
        descripcion: _descripcionController.text.trim().isEmpty
            ? 'Sin descripción'
            : _descripcionController.text.trim(),
        puntos: int.parse(_puntosController.text.trim()),
        nivel: _nivelSeleccionado!,
        materia: _materiaSeleccionada!,
        tenantId: "default",
      );

      if (resultado != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('¡Reto creado exitosamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Error al crear el reto';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
        });
      }
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
        return const Color(0xFF2196F3);
      case 'comunicacion':
        return const Color(0xFF4CAF50);
      case 'personal_social':
        return const Color(0xFFFF9800);
      case 'ciencia_tecnologia':
        return const Color(0xFF9C27B0);
      case 'ingles':
        return const Color(0xFFE91E63);
      default:
        return Colors.grey;
    }
  }

  Color _getNivelColor(String nivel) {
    switch (nivel) {
      case 'facil':
        return const Color(0xFF4CAF50);
      case 'medio':
        return const Color(0xFFFF9800);
      case 'dificil':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        // Descripción es opcional ahora
        return _tituloController.text.isNotEmpty &&
            _puntosController.text.isNotEmpty;
      case 1:
        return _materiaSeleccionada != null && _nivelSeleccionado != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Crear Nuevo Reto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? const Color(0xFF6366F1)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildCurrentStep()),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_currentStep == 2
                          ? _crearReto
                          : (_canProceedToNext() ? _nextStep : null)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : Text(
                        _currentStep == 2 ? 'Crear Reto' : 'Siguiente',
                        style: const TextStyle(
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildInfoStep();
      case 1:
        return _buildConfigStep();
      case 2:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proporciona los detalles principales de tu reto',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            _buildInputField(
              controller: _tituloController,
              label: 'Título del Reto',
              hint: 'Ej: Suma de fracciones con denominadores diferentes',
              icon: Icons.title,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El título es obligatorio';
                }
                if (value!.length < 5) {
                  return 'El título debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            _buildInputField(
              controller: _descripcionController,
              label: 'Descripción (Opcional)',
              hint:
                  'Describe qué deben hacer los estudiantes para completar este reto...',
              icon: Icons.description,
              maxLines: 4,
              // Sin validador - descripción opcional
            ),

            const SizedBox(height: 24),

            _buildInputField(
              controller: _puntosController,
              label: 'Puntos a Otorgar',
              hint: 'Cantidad de puntos por completar el reto',
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
          ],
        ),
      ),
    );
  }

  Widget _buildConfigStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona la materia y nivel de dificultad',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          const Text(
            'Materia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _materias.map((materia) {
              final isSelected = _materiaSeleccionada == materia['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _materiaSeleccionada = materia['value'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getMateriaColor(materia['value']!)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? _getMateriaColor(materia['value']!)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _getMateriaColor(
                                materia['value']!,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        materia['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        materia['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          const Text(
            'Nivel de Dificultad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: _niveles.map((nivel) {
              final isSelected = _nivelSeleccionado == nivel['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _nivelSeleccionado = nivel['value'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getNivelColor(nivel['value']!)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? _getNivelColor(nivel['value']!)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _getNivelColor(
                                nivel['value']!,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(
                        nivel['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          nivel['label']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revisión Final',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa todos los detalles antes de crear el reto',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem('Título', _tituloController.text, Icons.title),
                const Divider(height: 32),
                _buildReviewItem(
                  'Descripción',
                  _descripcionController.text.isEmpty
                      ? 'Sin descripción'
                      : _descripcionController.text,
                  Icons.description,
                ),
                const Divider(height: 32),
                _buildReviewItem(
                  'Materia',
                  _materias.firstWhere(
                    (m) => m['value'] == _materiaSeleccionada,
                  )['label']!,
                  Icons.book,
                  color: _getMateriaColor(_materiaSeleccionada!),
                ),
                const Divider(height: 32),
                _buildReviewItem(
                  'Nivel',
                  _niveles.firstWhere(
                    (n) => n['value'] == _nivelSeleccionado,
                  )['label']!,
                  Icons.speed,
                  color: _getNivelColor(_nivelSeleccionado!),
                ),
                const Divider(height: 32),
                _buildReviewItem(
                  'Puntos',
                  '${_puntosController.text} puntos',
                  Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 20),
                  const SizedBox(width: 12),
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

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF0284C7)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Una vez creado, los estudiantes podrán ver y completar este reto.',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
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
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }
}
