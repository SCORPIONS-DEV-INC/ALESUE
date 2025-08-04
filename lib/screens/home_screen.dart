import 'package:flutter/material.dart';

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

          // Puntos por materia
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puntos por Materia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildPuntosMateria(
                    'Matemáticas',
                    userInfo['puntos_matematicas'] ?? 0,
                    Colors.red,
                  ),
                  _buildPuntosMateria(
                    'Comunicación',
                    userInfo['puntos_comunicacion'] ?? 0,
                    Colors.green,
                  ),
                  _buildPuntosMateria(
                    'Personal Social',
                    userInfo['puntos_personal_social'] ?? 0,
                    Colors.orange,
                  ),
                  _buildPuntosMateria(
                    'Ciencia y Tecnología',
                    userInfo['puntos_ciencia_tecnologia'] ?? 0,
                    Colors.purple,
                  ),
                  _buildPuntosMateria(
                    'Inglés',
                    userInfo['puntos_ingles'] ?? 0,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Opciones del estudiante
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Matemáticas',
                  Icons.calculate,
                  Colors.red,
                  () => _navigateToMateria(context, token, 'matematicas'),
                ),
                _buildMenuCard(
                  context,
                  'Comunicación',
                  Icons.chat,
                  Colors.green,
                  () => _navigateToMateria(context, token, 'comunicacion'),
                ),
                _buildMenuCard(
                  context,
                  'Personal Social',
                  Icons.people,
                  Colors.orange,
                  () => _navigateToMateria(context, token, 'personal_social'),
                ),
                _buildMenuCard(
                  context,
                  'Ciencia y Tecnología',
                  Icons.science,
                  Colors.purple,
                  () =>
                      _navigateToMateria(context, token, 'ciencia_tecnologia'),
                ),
                _buildMenuCard(
                  context,
                  'Inglés',
                  Icons.language,
                  Colors.blue,
                  () => _navigateToMateria(context, token, 'ingles'),
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

  Widget _buildPuntosMateria(String materia, int puntos, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(materia),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$puntos pts',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
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

  // Métodos de navegación (se implementarán las pantallas más adelante)
  void _navigateToCreateStudent(BuildContext context, String token) {
    // TODO: Implementar pantalla de crear estudiante
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Crear Estudiante - En desarrollo'),
      ),
    );
  }

  void _navigateToCreateReto(BuildContext context, String token) {
    // TODO: Implementar pantalla de crear reto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función: Crear Reto - En desarrollo')),
    );
  }

  void _navigateToRanking(BuildContext context, String token) {
    // TODO: Implementar pantalla de ranking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función: Ver Ranking - En desarrollo')),
    );
  }

  void _navigateToMisRetos(BuildContext context, String token) {
    // TODO: Implementar pantalla de mis retos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función: Mis Retos - En desarrollo')),
    );
  }

  void _navigateToMateria(BuildContext context, String token, String materia) {
    // TODO: Implementar pantalla de retos por materia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Función: $materia - En desarrollo')),
    );
  }

  void _navigateToProgreso(BuildContext context, String token) {
    // TODO: Implementar pantalla de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función: Mi Progreso - En desarrollo')),
    );
  }
}
