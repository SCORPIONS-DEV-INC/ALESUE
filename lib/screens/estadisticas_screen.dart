import 'package:flutter/material.dart';

class EstadisticasScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> userInfo;

  const EstadisticasScreen({
    super.key,
    required this.token,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen general
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 50, color: Colors.teal[700]),
                    const SizedBox(height: 10),
                    Text(
                      'Resumen General',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total: ${userInfo['puntos_totales'] ?? 0} pts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Puntos por materia en cards horizontales
            const Text(
              'Puntos por Materia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMateriaPointCard(
                    'Matemáticas',
                    userInfo['puntos_matematicas'] ?? 0,
                    Colors.red,
                    Icons.calculate,
                  ),
                  _buildMateriaPointCard(
                    'Comunicación',
                    userInfo['puntos_comunicacion'] ?? 0,
                    Colors.green,
                    Icons.chat,
                  ),
                  _buildMateriaPointCard(
                    'Personal Social',
                    userInfo['puntos_personal_social'] ?? 0,
                    Colors.orange,
                    Icons.people,
                  ),
                  _buildMateriaPointCard(
                    'Ciencia y Tecnología',
                    userInfo['puntos_ciencia_tecnologia'] ?? 0,
                    Colors.purple,
                    Icons.science,
                  ),
                  _buildMateriaPointCard(
                    'Inglés',
                    userInfo['puntos_ingles'] ?? 0,
                    Colors.blue,
                    Icons.language,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Análisis detallado
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Análisis Detallado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildAnalisisDetallado()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriaPointCard(
    String materia,
    int puntos,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                materia,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$puntos pts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalisisDetallado() {
    final materias = {
      'Matemáticas': {
        'puntos': userInfo['puntos_matematicas'] ?? 0,
        'color': Colors.red,
        'icon': Icons.calculate,
      },
      'Comunicación': {
        'puntos': userInfo['puntos_comunicacion'] ?? 0,
        'color': Colors.green,
        'icon': Icons.chat,
      },
      'Personal Social': {
        'puntos': userInfo['puntos_personal_social'] ?? 0,
        'color': Colors.orange,
        'icon': Icons.people,
      },
      'Ciencia y Tecnología': {
        'puntos': userInfo['puntos_ciencia_tecnologia'] ?? 0,
        'color': Colors.purple,
        'icon': Icons.science,
      },
      'Inglés': {
        'puntos': userInfo['puntos_ingles'] ?? 0,
        'color': Colors.blue,
        'icon': Icons.language,
      },
    };

    // Encontrar la materia más fuerte y más débil
    String materiaFuerte = '';
    String materiaDebil = '';
    int maxPuntos = -1;
    int minPuntos = 999999;

    materias.forEach((nombre, data) {
      final puntos = data['puntos'] as int;
      if (puntos > maxPuntos) {
        maxPuntos = puntos;
        materiaFuerte = nombre;
      }
      if (puntos < minPuntos) {
        minPuntos = puntos;
        materiaDebil = nombre;
      }
    });

    final totalPuntos = userInfo['puntos_totales'] ?? 0;
    final promedioPorMateria = totalPuntos > 0 ? (totalPuntos / 5).round() : 0;

    return ListView(
      children: [
        // Fortalezas y debilidades
        _buildAnalisisCard(
          'Tu materia más fuerte',
          materiaFuerte,
          '$maxPuntos puntos',
          materias[materiaFuerte]!['color'] as Color,
          materias[materiaFuerte]!['icon'] as IconData,
          Icons.trending_up,
        ),

        const SizedBox(height: 12),

        _buildAnalisisCard(
          'Materia a mejorar',
          materiaDebil,
          '$minPuntos puntos',
          materias[materiaDebil]!['color'] as Color,
          materias[materiaDebil]!['icon'] as IconData,
          Icons.trending_down,
        ),

        const SizedBox(height: 16),

        // Estadísticas generales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estadísticas Generales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('Promedio por materia:', '$promedioPorMateria pts'),
              _buildStatRow(
                'Diferencia max-min:',
                '${maxPuntos - minPuntos} pts',
              ),
              _buildStatRow(
                'Materias con 0 puntos:',
                _contarMateriasVacias(materias).toString(),
              ),
              _buildStatRow('Rango actual:', _getRangoFromPuntos(totalPuntos)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recomendaciones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Recomendaciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._getRecomendaciones(materias, totalPuntos),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalisisCard(
    String titulo,
    String materia,
    String puntos,
    Color color,
    IconData materiaIcon,
    IconData trendIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(materiaIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  materia,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  puntos,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Icon(trendIcon, color: color, size: 24),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  int _contarMateriasVacias(Map<String, Map<String, dynamic>> materias) {
    return materias.values.where((data) => (data['puntos'] as int) == 0).length;
  }

  List<Widget> _getRecomendaciones(
    Map<String, Map<String, dynamic>> materias,
    int totalPuntos,
  ) {
    List<String> recomendaciones = [];

    if (totalPuntos == 0) {
      recomendaciones.add('¡Comienza resolviendo tu primer reto!');
      recomendaciones.add('Te recomendamos empezar con retos fáciles');
    } else {
      final materiasVacias = _contarMateriasVacias(materias);
      if (materiasVacias > 0) {
        recomendaciones.add('Intenta resolver retos en todas las materias');
      }

      if (totalPuntos < 100) {
        recomendaciones.add('Practica diariamente para subir de rango');
      } else if (totalPuntos < 500) {
        recomendaciones.add('¡Vas bien! Intenta retos de nivel medio');
      } else {
        recomendaciones.add(
          '¡Excelente progreso! Desafíate con retos difíciles',
        );
      }
    }

    return recomendaciones
        .map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.arrow_right, color: Colors.blue[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  String _getRangoFromPuntos(int puntos) {
    if (puntos >= 1000) return 'Maestro';
    if (puntos >= 750) return 'Experto';
    if (puntos >= 500) return 'Avanzado';
    if (puntos >= 250) return 'Intermedio';
    if (puntos >= 100) return 'Principiante';
    return 'Novato';
  }
}
