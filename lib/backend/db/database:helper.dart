import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/estudiante.dart';

class DatabaseHelper {
  // Paso 1: Asegurarnos de que solo haya una instancia (Singleton)
  static final DatabaseHelper _instance = DatabaseHelper._init();
  static Database? _database;

  // Constructor privado
  DatabaseHelper._init();

  // Getter público para acceder a la instancia
  factory DatabaseHelper.instance() => _instance;

  // Getter para la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sistema_estudiantil.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE estudiantes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            apellido TEXT NOT NULL,
            edad INTEGER NOT NULL,
            dni TEXT NOT NULL UNIQUE,
            correo TEXT NOT NULL UNIQUE,
            puesto INTEGER UNIQUE CHECK (puesto >= 1 AND puesto <= 30),
            calificacion REAL CHECK (calificacion >= 0 AND calificacion <= 20),
            tenant_id TEXT NOT NULL DEFAULT 'default'
          )
        ''');
      },
    );
  }

  // Registrar estudiante
  Future<int> insertEstudiante(Estudiante estudiante) async {
    final db = await database;
    try {
      return await db.insert('estudiantes', estudiante.toMap());
    } on DatabaseException {
      return -1; // DNI o correo duplicado
    }
  }

  // Login: busca por nombre/apellido y DNI
  Future<Estudiante?> login(String usuario, String dni) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'estudiantes',
      where: '(nombre = ? OR apellido = ?) AND dni = ?',
      whereArgs: [usuario, usuario, dni],
    );

    if (maps.isEmpty) return null;
    return Estudiante.fromMap(maps.first);
  }
}
