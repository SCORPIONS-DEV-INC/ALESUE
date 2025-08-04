import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class RankingScreen extends StatefulWidget {
  final String token;

  const RankingScreen({super.key, required this.token});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  List<Map<String, dynamic>> _ranking = [];
  bool _isLoading = true;
  String? _error;
  String? _materiaSeleccionada;
  String? _gradoSeleccionado;

  final List<Map<String, String>> _materias = [
    {'value': '', 'label': 'Todas las materias'},
    {'value': 'matematicas', 'label': 'Matemáticas'},
    {'value': 'comunicacion', 'label': 'Comunicación'},
    {'value': 'personal_social', 'label': 'Personal Social'},
    {'value': 'ciencia_tecnologia', 'label': 'Ciencia y Tecnología'},
    {'value': 'ingles', 'label': 'Inglés'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarRanking();
  }

  Future<void> _cargarRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ranking = await _db.getRanking(
        materia: _materiaSeleccionada?.isEmpty == true
            ? null
            : _materiaSeleccionada,
        grado: _gradoSeleccionado?.isEmpty == true ? null : _gradoSeleccionado,
        token: widget.token,
      );
      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el ranking: $e';
        _isLoading = false;
      });
    }
  }

  Color _getRankingColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber; // Oro
      case 2:
        return Colors.grey; // Plata
      case 3:
        return Colors.brown; // Bronce
      default:
        return Colors.blue;
    }
  }

  IconData _getRankingIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events; // Trofeo
      case 2:
        return Icons.military_tech; // Medalla
      case 3:
        return Icons.workspace_premium; // Premio
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Estudiantes'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRanking,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _materiaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por materia',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _materias.map((materia) {
                          return DropdownMenuItem<String>(
                            value: materia['value'],
                            child: Text(materia['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _materiaSeleccionada = value;
                          });
                          _cargarRanking();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por grado',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: 'Ej: 6°A',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _gradoSeleccionado = value.isEmpty ? null : value;
                          });
                        },
                        onFieldSubmitted: (value) {
                          _cargarRanking();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenido del ranking
          Expanded(child: _buildBody()),
        ],
      ),
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
              onPressed: _cargarRanking,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_ranking.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes en el ranking',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarRanking,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final estudiante = _ranking[index];
          final position = index + 1;
          return _buildRankingCard(estudiante, position);
        },
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> estudiante, int position) {
    final rankingColor = _getRankingColor(position);
    final rankingIcon = _getRankingIcon(position);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: position <= 3 ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: position <= 3
            ? BorderSide(color: rankingColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Posición y ícono
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: rankingColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: rankingColor, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    rankingIcon,
                    color: rankingColor,
                    size: position <= 3 ? 20 : 16,
                  ),
                  if (position > 3)
                    Text(
                      '$position',
                      style: TextStyle(
                        color: rankingColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Información del estudiante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${estudiante['nombre']} ${estudiante['apellido']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${estudiante['grado']} - ${estudiante['seccion']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Puntos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: rankingColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rankingColor),
              ),
              child: Column(
                children: [
                  Text(
                    '${estudiante['puntos_totales'] ?? 0}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rankingColor,
                    ),
                  ),
                  Text(
                    'puntos',
                    style: TextStyle(fontSize: 10, color: rankingColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
