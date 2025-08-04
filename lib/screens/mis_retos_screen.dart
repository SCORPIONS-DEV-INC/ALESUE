import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class MisRetosScreen extends StatefulWidget {
  final String token;

  const MisRetosScreen({super.key, required this.token});

  @override
  State<MisRetosScreen> createState() => _MisRetosScreenState();
}

class _MisRetosScreenState extends State<MisRetosScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  List<Map<String, dynamic>> _retos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMisRetos();
  }

  Future<void> _cargarMisRetos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final retos = await _db.getMisRetos(widget.token);
      setState(() {
        _retos = retos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los retos: $e';
        _isLoading = false;
      });
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

  String _getMateriaLabel(String materia) {
    switch (materia) {
      case 'matematicas':
        return 'Matemáticas';
      case 'comunicacion':
        return 'Comunicación';
      case 'personal_social':
        return 'Personal Social';
      case 'ciencia_tecnologia':
        return 'Ciencia y Tecnología';
      case 'ingles':
        return 'Inglés';
      default:
        return materia;
    }
  }

  String _getNivelLabel(String nivel) {
    switch (nivel) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Medio';
      case 'dificil':
        return 'Difícil';
      default:
        return nivel;
    }
  }

  Color _getNivelColor(String nivel) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Retos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMisRetos,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarMisRetos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_retos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No has creado retos aún',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer reto desde el panel principal',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMisRetos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _retos.length,
        itemBuilder: (context, index) {
          final reto = _retos[index];
          return _buildRetoCard(reto);
        },
      ),
    );
  }

  Widget _buildRetoCard(Map<String, dynamic> reto) {
    final materia = reto['materia'] ?? '';
    final nivel = reto['nivel'] ?? '';
    final materiaColor = _getMateriaColor(materia);
    final nivelColor = _getNivelColor(nivel);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con materia y nivel
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: materiaColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMateriaIcon(materia),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getMateriaLabel(materia),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: nivelColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getNivelLabel(nivel),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.orange[700], size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${reto['puntos'] ?? 0} pts',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Título
            Text(
              reto['titulo'] ?? 'Sin título',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Descripción
            Text(
              reto['descripcion'] ?? 'Sin descripción',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Footer con fecha y acciones
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${reto['created_at']?.toString().split('T')[0] ?? 'N/A'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implementar ver detalles del reto
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ver detalles - En desarrollo'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver detalles'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
