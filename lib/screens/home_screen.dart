import 'package:flutter/material.dart';
import '../../backend/models/estudiante.dart';

class HomeScreen extends StatelessWidget {
  final Estudiante? estudiante; // ← Ahora es nullable

  const HomeScreen({super.key, required this.estudiante});

  @override
  Widget build(BuildContext context) {
    // Asegúrate de manejar el caso null
    if (estudiante == null) {
      return Scaffold(
        body: Center(
          child: Text('Error: No se encontró información del estudiante'),
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
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(
              'Bienvenido, ${estudiante!.nombre} ${estudiante!.apellido}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
}
