// screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // ✅ Recibe los datos del login (no un objeto Estudiante)
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData, required estudiante});

  @override
  Widget build(BuildContext context) {
    // Asegúrate de que los datos no sean nulos
    if (userData.isEmpty) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Perfil
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),

            // Nombre completo
            Text(
              'Bienvenido, ${userData['nombre']} ${userData['apellido']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Datos del estudiante
            _buildInfoRow('Edad', userData['edad'].toString()),
            _buildInfoRow('DNI', userData['dni']),
            _buildInfoRow('Grado', userData['grado']),
            _buildInfoRow('Sección', userData['seccion']),
            _buildInfoRow('Sexo', userData['sexo']),
            if (userData['correo'] != null)
              _buildInfoRow('Correo', userData['correo']),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para mostrar datos
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
