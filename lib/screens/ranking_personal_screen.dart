import 'package:flutter/material.dart';

class RankingPersonalScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> userInfo;

  const RankingPersonalScreen({
    super.key,
    required this.token,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ranking'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta principal del ranking
            Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.amber[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _buildRankingInfo(),
              ),
            ),

            const SizedBox(height: 20),

            // Historia de rangos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Escalera de Rangos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRangosEscalera(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Consejos para subir de rango
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Consejos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildConsejos(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingInfo() {
    final totalPuntos = userInfo['puntos_totales'] ?? 0;
    final String rango = _getRangoFromPuntos(totalPuntos);
    final Color rangoColor = _getRangoColor(rango);
    final int puntosParaSiguienteRango = _getPuntosParaSiguienteRango(
      totalPuntos,
    );
    final double progreso = _getProgresoRango(totalPuntos);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: rangoColor, shape: BoxShape.circle),
          child: Icon(_getRangoIcon(rango), color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          rango,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: rangoColor,
          ),
        ),
        Text(
          '${userInfo['nombre']} ${userInfo['apellido']}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalPuntos puntos totales',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso al siguiente rango',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${(progreso * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rangoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(rangoColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              puntosParaSiguienteRango > 0
                  ? 'Te faltan $puntosParaSiguienteRango puntos para el siguiente rango'
                  : '¡Has alcanzado el rango máximo!',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangosEscalera() {
    final rangos = [
      {'nombre': 'Maestro', 'puntos': 1000, 'color': Colors.purple},
      {'nombre': 'Experto', 'puntos': 750, 'color': Colors.amber[700]!},
      {'nombre': 'Avanzado', 'puntos': 500, 'color': Colors.blue},
      {'nombre': 'Intermedio', 'puntos': 250, 'color': Colors.green},
      {'nombre': 'Principiante', 'puntos': 100, 'color': Colors.orange},
      {'nombre': 'Novato', 'puntos': 0, 'color': Colors.grey},
    ];

    final puntosActuales = userInfo['puntos_totales'] ?? 0;

    return Column(
      children: rangos.map((rango) {
        final bool alcanzado = puntosActuales >= (rango['puntos'] as int);
        final bool actual =
            _getRangoFromPuntos(puntosActuales) == rango['nombre'];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alcanzado
                ? (rango['color'] as Color).withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: actual
                ? Border.all(color: rango['color'] as Color, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                _getRangoIcon(rango['nombre'] as String),
                color: alcanzado ? (rango['color'] as Color) : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rango['nombre'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: alcanzado
                            ? (rango['color'] as Color)
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      '${rango['puntos']} puntos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (alcanzado)
                Icon(Icons.check_circle, color: rango['color'] as Color)
              else
                Icon(Icons.lock, color: Colors.grey[400]),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsejos() {
    final totalPuntos = userInfo['puntos_totales'] ?? 0;
    final String rango = _getRangoFromPuntos(totalPuntos);

    List<String> consejos = [];

    if (rango == 'Novato') {
      consejos = [
        '• Completa retos fáciles para ganar confianza',
        '• Practica diariamente al menos 15 minutos',
        '• Comienza con matemáticas básicas',
      ];
    } else if (rango == 'Principiante') {
      consejos = [
        '• Intenta retos de nivel medio',
        '• Diversifica entre todas las materias',
        '• Establece una rutina de estudio',
      ];
    } else if (rango == 'Intermedio') {
      consejos = [
        '• Desafíate con retos difíciles',
        '• Compite con tus compañeros',
        '• Refuerza tus materias más débiles',
      ];
    } else {
      consejos = [
        '• Mantén tu nivel practicando regularmente',
        '• Ayuda a tus compañeros novatos',
        '• Explora retos avanzados',
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: consejos
          .map(
            (consejo) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                consejo,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          )
          .toList(),
    );
  }

  String _getRangoFromPuntos(int puntos) {
    if (puntos >= 1000) return 'Maestro';
    if (puntos >= 750) return 'Experto';
    if (puntos >= 500) return 'Avanzado';
    if (puntos >= 250) return 'Intermedio';
    if (puntos >= 100) return 'Principiante';
    return 'Novato';
  }

  Color _getRangoColor(String rango) {
    switch (rango) {
      case 'Maestro':
        return Colors.purple;
      case 'Experto':
        return Colors.amber[700]!;
      case 'Avanzado':
        return Colors.blue;
      case 'Intermedio':
        return Colors.green;
      case 'Principiante':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getRangoIcon(String rango) {
    switch (rango) {
      case 'Maestro':
        return Icons.emoji_events;
      case 'Experto':
        return Icons.star;
      case 'Avanzado':
        return Icons.trending_up;
      case 'Intermedio':
        return Icons.thumb_up;
      case 'Principiante':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  int _getPuntosParaSiguienteRango(int puntosActuales) {
    if (puntosActuales >= 1000) return 0;
    if (puntosActuales >= 750) return 1000 - puntosActuales;
    if (puntosActuales >= 500) return 750 - puntosActuales;
    if (puntosActuales >= 250) return 500 - puntosActuales;
    if (puntosActuales >= 100) return 250 - puntosActuales;
    return 100 - puntosActuales;
  }

  double _getProgresoRango(int puntosActuales) {
    if (puntosActuales >= 1000) return 1.0;
    if (puntosActuales >= 750) return (puntosActuales - 750) / 250;
    if (puntosActuales >= 500) return (puntosActuales - 500) / 250;
    if (puntosActuales >= 250) return (puntosActuales - 250) / 250;
    if (puntosActuales >= 100) return (puntosActuales - 100) / 150;
    return puntosActuales / 100;
  }
}
