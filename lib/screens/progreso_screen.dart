import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class ProgresoScreen extends StatefulWidget {
  final String token;

  const ProgresoScreen({super.key, required this.token});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  List<Map<String, dynamic>> _progreso = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final progreso = await _db.getMiProgreso(widget.token);

      setState(() {
        _progreso = progreso;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar progreso: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarProgreso,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
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
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarProgreso,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_progreso.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No has completado ningún reto',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Comienza a resolver retos para ver tu progreso!',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarProgreso,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas generales
            _buildEstadisticasCard(),
            const SizedBox(height: 16),

            // Lista de retos completados
            const Text(
              'Retos Completados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _progreso.length,
              itemBuilder: (context, index) {
                final item = _progreso[index];
                return _buildProgresoCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    final totalRetos = _progreso.length;
    final totalPuntos = _progreso.fold<int>(
      0,
      (sum, item) => sum + (item['puntos_obtenidos'] as int? ?? 0),
    );

    // Contar retos por materia
    final Map<String, int> retosPorMateria = {};
    for (final item in _progreso) {
      final materia = item['materia'] ?? 'unknown';
      retosPorMateria[materia] = (retosPorMateria[materia] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Retos\nCompletados',
                    totalRetos.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Puntos\nTotales',
                    totalPuntos.toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Promedio\nPor Reto',
                    totalRetos > 0
                        ? (totalPuntos / totalRetos).toStringAsFixed(1)
                        : '0',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            if (retosPorMateria.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Retos por Materia:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: retosPorMateria.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMateriaColor(entry.key),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_getMateriaNombre(entry.key)}: ${entry.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgresoCard(Map<String, dynamic> item) {
    final titulo = item['titulo'] ?? 'Reto sin título';
    final puntosObtenidos = item['puntos_obtenidos'] ?? 0;
    final fechaCompletado = item['fecha_completado'] ?? '';
    final materia = item['materia'] ?? 'unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getMateriaColor(materia),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getMateriaIcon(materia), color: Colors.white, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _getMateriaNombre(materia) +
              (fechaCompletado.isNotEmpty ? ' • $fechaCompletado' : ''),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 14),
              const SizedBox(width: 2),
              Text(
                '+$puntosObtenidos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMateriaColor(String materia) {
    switch (materia) {
      case 'matematicas':
        return Colors.red;
      case 'comunicacion':
        return Colors.green;
      case 'personal_social':
        return Colors.orange;
      case 'ciencia_tecnologia':
        return Colors.purple;
      case 'ingles':
        return Colors.blue;
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

  String _getMateriaNombre(String materia) {
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
        return 'Materia desconocida';
    }
  }
}
