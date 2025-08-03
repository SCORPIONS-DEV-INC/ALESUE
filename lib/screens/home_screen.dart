import 'package:flutter/material.dart';
import '../../backend/models/estudiante.dart';

class HomeScreen extends StatelessWidget {
  // ✅ Recibe los datos del login (no un objeto Estudiante)
  final Map<String, dynamic>? userData;
  final Estudiante? estudiante;

  const HomeScreen({super.key, this.userData, this.estudiante});

  @override
  Widget build(BuildContext context) {
    // Si se pasa un estudiante, mostrar datos del estudiante
    if (estudiante != null) {
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
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                'Bienvenido, ${estudiante!.nombre} ${estudiante!.apellido}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Edad: ${estudiante!.edad}'),
              Text('DNI: ${estudiante!.dni}'),
              Text('Correo: ${estudiante!.correo}'),
            ],
          ),
        ),
      );
    }

    // Si se pasa userData, mostrar datos del usuario
    if (userData != null && userData!.isNotEmpty) {
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
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                'Bienvenido, ${userData!['nombre']} ${userData!['apellido']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Edad', userData!['edad'].toString()),
              _buildInfoRow('DNI', userData!['dni']),
              _buildInfoRow('Grado', userData!['grado']),
              _buildInfoRow('Sección', userData!['seccion']),
              _buildInfoRow('Sexo', userData!['sexo']),
              if (userData!['correo'] != null)
                _buildInfoRow('Correo', userData!['correo']),
            ],
          ),
        ),
      );
    }

    // Si no hay datos, mostrar error
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
