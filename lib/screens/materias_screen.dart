import 'package:flutter/material.dart';
import 'retos_materia_screen.dart';
import 'ranking_personal_screen.dart';
import 'estadisticas_screen.dart';

class MateriasScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> userInfo;

  const MateriasScreen({
    super.key,
    required this.token,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de bienvenida
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 50, color: Colors.blue[700]),
                    const SizedBox(height: 10),
                    Text(
                      '¡Hola ${userInfo['nombre']}!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      'Elige una materia para comenzar',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total: ${userInfo['puntos_totales'] ?? 0} pts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acceso rápido
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToRanking(context),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('Mi Ranking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToEstadisticas(context),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Estadísticas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Título de materias
            Text(
              'Materias Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 16),

            // Grid de materias
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMateriaCard(
                    context,
                    'Matemáticas',
                    Icons.calculate,
                    Colors.red,
                    'matematicas',
                    userInfo['puntos_matematicas'] ?? 0,
                  ),
                  _buildMateriaCard(
                    context,
                    'Comunicación',
                    Icons.chat,
                    Colors.green,
                    'comunicacion',
                    userInfo['puntos_comunicacion'] ?? 0,
                  ),
                  _buildMateriaCard(
                    context,
                    'Personal Social',
                    Icons.people,
                    Colors.orange,
                    'personal_social',
                    userInfo['puntos_personal_social'] ?? 0,
                  ),
                  _buildMateriaCard(
                    context,
                    'Ciencia y Tecnología',
                    Icons.science,
                    Colors.purple,
                    'ciencia_tecnologia',
                    userInfo['puntos_ciencia_tecnologia'] ?? 0,
                  ),
                  _buildMateriaCard(
                    context,
                    'Inglés',
                    Icons.language,
                    Colors.blue,
                    'ingles',
                    userInfo['puntos_ingles'] ?? 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMateria(
    BuildContext context,
    String materia,
    String materiaNombre,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RetosMateriaScreen(
          token: token,
          materia: materia,
          materiaNombre: materiaNombre,
        ),
      ),
    );
  }

  void _navigateToRanking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RankingPersonalScreen(token: token, userInfo: userInfo),
      ),
    );
  }

  void _navigateToEstadisticas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EstadisticasScreen(token: token, userInfo: userInfo),
      ),
    );
  }

  Widget _buildMateriaCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String materia,
    int puntos,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToMateria(context, materia, title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$puntos pts',
                  style: const TextStyle(
                    fontSize: 12,
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
}
