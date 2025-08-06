import 'package:flutter/material.dart';
import 'crear_estudiante_screen.dart';
import 'crear_reto_screen.dart';
import 'mis_retos_screen.dart';
import 'ranking_screen.dart';
import 'progreso_screen.dart';
import 'materias_screen.dart';

class HomeScreen extends StatelessWidget {
  // Recibe los datos del login (incluye token y user_info)
  final Map<String, dynamic>? userData;

  const HomeScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData == null || userData!.isEmpty) {
      return _buildErrorScreen(context);
    }

    final userInfo = userData!['user_info'] as Map<String, dynamic>?;
    final token = userData!['access_token'] as String?;

    if (userInfo == null || token == null) {
      return _buildErrorScreen(context);
    }

    final rol = userInfo['rol'] as String?;
    final nombre = userInfo['nombre'] as String? ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, $nombre'),
        backgroundColor: rol == 'profesor' ? Colors.green : Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: rol == 'profesor'
          ? _buildProfesorView(context, userInfo, token)
          : _buildEstudianteView(context, userInfo, token),
    );
  }

  Widget _buildProfesorView(
    BuildContext context,
    Map<String, dynamic> userInfo,
    String token,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de bienvenida
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.person, size: 60, color: Colors.green[700]),
                  const SizedBox(height: 10),
                  Text(
                    'Panel del Profesor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    '${userInfo['nombre']} ${userInfo['apellido']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Opciones del profesor
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Crear Estudiante',
                  Icons.person_add,
                  Colors.blue,
                  () => _navigateToCreateStudent(context, token),
                ),
                _buildMenuCard(
                  context,
                  'Crear Reto',
                  Icons.assignment,
                  Colors.orange,
                  () => _navigateToCreateReto(context, token),
                ),
                _buildMenuCard(
                  context,
                  'Ver Ranking',
                  Icons.leaderboard,
                  Colors.purple,
                  () => _navigateToRanking(context, token),
                ),
                _buildMenuCard(
                  context,
                  'Mis Retos',
                  Icons.list_alt,
                  Colors.teal,
                  () => _navigateToMisRetos(context, token),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteView(
    BuildContext context,
    Map<String, dynamic> userInfo,
    String token,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de bienvenida con puntos
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.school, size: 60, color: Colors.blue[700]),
                  const SizedBox(height: 10),
                  Text(
                    'Panel del Estudiante',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '${userInfo['nombre']} ${userInfo['apellido']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Puntos Totales: ${userInfo['puntos_totales'] ?? 0}',
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

          const SizedBox(height: 20),

          // Información del estudiante
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('DNI:', userInfo['dni'] ?? 'No disponible'),
                  _buildInfoRow('Grado:', userInfo['grado'] ?? 'No disponible'),
                  _buildInfoRow(
                    'Sección:',
                    userInfo['seccion'] ?? 'No disponible',
                  ),
                  _buildInfoRow(
                    'Edad:',
                    '${userInfo['edad'] ?? 'No disponible'} años',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Opciones del estudiante (solo 2 opciones principales)
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Mis Materias',
                  Icons.book,
                  Colors.blue,
                  () => _navigateToMaterias(context, token, userInfo),
                ),
                _buildMenuCard(
                  context,
                  'Mi Progreso',
                  Icons.trending_up,
                  Colors.teal,
                  () => _navigateToProgreso(context, token),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 10),
            const Text(
              'Error: No se cargaron los datos',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de navegación
  void _navigateToCreateStudent(BuildContext context, String token) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEstudianteScreen(token: token),
      ),
    ).then((result) {
      if (result == true) {
        // Estudiante creado exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Estudiante creado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _navigateToCreateReto(BuildContext context, String token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearRetoScreen(token: token)),
    ).then((result) {
      if (result == true) {
        // Reto creado exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reto creado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _navigateToRanking(BuildContext context, String token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RankingScreen(token: token)),
    );
  }

  void _navigateToMisRetos(BuildContext context, String token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MisRetosScreen(token: token)),
    );
  }

  void _navigateToMaterias(
    BuildContext context,
    String token,
    Map<String, dynamic> userInfo,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateriasScreen(token: token, userInfo: userInfo),
      ),
    );
  }

  void _navigateToProgreso(BuildContext context, String token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProgresoScreen(token: token)),
    );
  }
}
