// main.dart

import 'dart:ui';

import 'package:aluxe/backend/db/aluxe_database.dart';

import 'package:aluxe/screens/loguin_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Para escritorio

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inicializar sqflite para escritorio
  if (!isMobile()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ Verificar conexión con la base de datos
  try {
    final db = await AluxeDatabase.instance().database;
    print('✅ Base de datos lista: ${db.path}');
  } catch (e) {
    print('❌ Error con la base de datos: $e');
  }

  runApp(const MyApp());
}

bool isMobile() {
  final platform = WidgetsBinding.instance.window.platform;
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}

extension on SingletonFlutterWindow {
  get platform => null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALUXE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: Image.asset(
                  'assets/logo.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Bienvenido Estudiante',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'DancingScript',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'INICIO',
                  style: TextStyle(
                    fontSize: 22,
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
