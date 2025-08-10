import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';
import 'crear_reto_screen.dart';
import 'editar_reto_screen.dart';

class GestionarRetosScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const GestionarRetosScreen({
    super.key,
    required this.token,
    required this.userData,
  });

  @override
  State<GestionarRetosScreen> createState() => _GestionarRetosScreenState();
}

class _GestionarRetosScreenState extends State<GestionarRetosScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  List<Map<String, dynamic>> _retos = [];
  bool _isLoading = true;
  String? _error;
  String _filtroMateria = 'todas';
  String _filtroNivel = 'todos';

  final List<Map<String, String>> _materias = [
    {'value': 'todas', 'label': 'Todas las materias'},
    {'value': 'matematicas', 'label': 'Matemáticas'},
    {'value': 'comunicacion', 'label': 'Comunicación'},
    {'value': 'personal_social', 'label': 'Personal Social'},
    {'value': 'ciencia_tecnologia', 'label': 'Ciencia y Tecnología'},
    {'value': 'ingles', 'label': 'Inglés'},
  ];

  final List<Map<String, String>> _niveles = [
    {'value': 'todos', 'label': 'Todos los niveles'},
    {'value': 'facil', 'label': 'Fácil'},
    {'value': 'medio', 'label': 'Medio'},
    {'value': 'dificil', 'label': 'Difícil'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarRetos();
  }

  Future<void> _cargarRetos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final retos = await _db.getMisRetos(widget.token);
      if (mounted) {
        setState(() {
          _retos = retos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar los retos: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _retosFiltrados {
    return _retos.where((reto) {
      bool materiaCoincide =
          _filtroMateria == 'todas' || reto['materia'] == _filtroMateria;
      bool nivelCoincide =
          _filtroNivel == 'todos' || reto['nivel'] == _filtroNivel;
      return materiaCoincide && nivelCoincide;
    }).toList();
  }

  Future<void> _eliminarReto(int retoId) async {
    final confirm = await _mostrarDialogoConfirmacion(
      '¿Eliminar reto?',
      '¿Estás seguro de que deseas eliminar este reto? Esta acción no se puede deshacer.',
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final success = await _db.eliminarReto(
          token: widget.token,
          retoId: retoId,
        );

        if (success && mounted) {
          await _cargarRetos();
          _mostrarSnackBar('Reto eliminado exitosamente', Colors.green);
        } else {
          _mostrarSnackBar('Error al eliminar el reto', Colors.red);
        }
      } catch (e) {
        _mostrarSnackBar('Error: $e', Colors.red);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getColorPorMateria(String materia) {
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

  Color _getColorPorNivel(String nivel) {
    switch (nivel) {
      case 'facil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoPorMateria(String materia) {
    switch (materia) {
      case 'matematicas':
        return Icons.calculate;
      case 'comunicacion':
        return Icons.chat;
      case 'personal_social':
        return Icons.people;
      case 'ciencia_tecnologia':
        return Icons.science;
      case 'ingles':
        return Icons.language;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mis Retos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarRetos),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearRetoScreen(token: widget.token),
                ),
              );
              if (result == true) {
                _cargarRetos();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _filtroMateria,
                        items: _materias,
                        hint: 'Filtrar por materia',
                        onChanged: (value) {
                          setState(() => _filtroMateria = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        value: _filtroNivel,
                        items: _niveles,
                        hint: 'Filtrar por nivel',
                        onChanged: (value) {
                          setState(() => _filtroNivel = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_retosFiltrados.length} retos encontrados',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de retos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarRetos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _retosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No tienes retos creados'),
                        const SizedBox(height: 8),
                        const Text(
                          'Crea tu primer reto para tus estudiantes',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CrearRetoScreen(token: widget.token),
                              ),
                            );
                            if (result == true) {
                              _cargarRetos();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Crear Reto'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _retosFiltrados.length,
                    itemBuilder: (context, index) {
                      final reto = _retosFiltrados[index];
                      return _buildRetoCard(reto);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<Map<String, String>> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRetoCard(Map<String, dynamic> reto) {
    final materiaColor = _getColorPorMateria(reto['materia'] ?? '');
    final nivelColor = _getColorPorNivel(reto['nivel'] ?? '');
    final materiaIcon = _getIconoPorMateria(reto['materia'] ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del reto
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: materiaColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(materiaIcon, color: materiaColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reto['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reto['materia']
                                ?.toString()
                                .replaceAll('_', ' ')
                                .toUpperCase() ??
                            '',
                        style: TextStyle(
                          fontSize: 12,
                          color: materiaColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'editar':
                        // TODO: Implementar edición
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarRetoScreen(
                              token: widget.token,
                              reto: reto,
                            ),
                          ),
                        ).then((result) {
                          if (result == true) _cargarRetos();
                        });
                        break;
                      case 'eliminar':
                        _eliminarReto(reto['id'] as int);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Descripción
            if (reto['descripcion'] != null &&
                reto['descripcion'].toString().isNotEmpty)
              Text(
                reto['descripcion'],
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Información adicional
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.star,
                  label: '${reto['puntos'] ?? 0} pts',
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.speed,
                  label: reto['nivel']?.toString().toUpperCase() ?? 'MEDIO',
                  color: nivelColor,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.quiz,
                  label: '${reto['preguntas_count'] ?? 0} preguntas',
                  color: Colors.blue,
                ),
              ],
            ),

            if (reto['created_at'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Creado: ${_formatearFecha(reto['created_at'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return fecha;
    }
  }
}
