import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Recibe los datos del login (por ahora solo el token)
  final Map<String, dynamic>? userData;

  const HomeScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    // Si se pasa userData (por ahora solo token), mostrar mensaje básico
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
              const Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Token: ${userData!['token']}'),
              const SizedBox(height: 10),
              const Text('Conexión exitosa a la base de datos en Render.'),
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
}
