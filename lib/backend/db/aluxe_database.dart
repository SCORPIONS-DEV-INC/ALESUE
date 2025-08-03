// database/aluxe_database.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AluxeDatabase {
  static final AluxeDatabase _instance = AluxeDatabase._init();
  static Database? _database;

  AluxeDatabase._init();

  factory AluxeDatabase.instance() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aluxe.db');
    // Cambia la versión a 2 para activar la migración
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registro (
        dni TEXT NOT NULL PRIMARY KEY,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        correo TEXT,
        tenant_id TEXT NOT NULL DEFAULT 'default'
      )
    ''');

    await db.execute('''
      CREATE TABLE login (
        dni TEXT NOT NULL PRIMARY KEY,
        usuario TEXT NOT NULL,
        contraseña TEXT NOT NULL,
        tenant_id TEXT NOT NULL DEFAULT 'default',
        FOREIGN KEY (dni) REFERENCES registro(dni) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE estudiante (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dni TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        edad INTEGER NOT NULL,
        grado TEXT NOT NULL,
        seccion TEXT NOT NULL,
        sexo TEXT NOT NULL,
        correo TEXT,
        tenant_id TEXT NOT NULL DEFAULT 'default',
        FOREIGN KEY (dni) REFERENCES registro(dni) ON DELETE CASCADE
      )
    ''');
  }

  // Migración de la base de datos (v1 -> v2)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Añadir columna 'correo' si no existe en 'estudiante'
      await db.execute('''
        ALTER TABLE estudiante ADD COLUMN correo TEXT;
      ''');
    }
  }

  // --- Operaciones ---

  // Registro
  Future<int> insertRegistro(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('registro', data);
  }

  // Login
  Future<int> insertLogin(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('login', data);
  }

  // Estudiante
  Future<int> insertEstudiante(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('estudiante', data);
  }

  // Autenticación
  Future<Map<String, dynamic>?> login(String usuario, String dni) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT e.nombre, e.apellido, e.dni, e.edad, e.grado, e.seccion, e.sexo, r.correo
      FROM estudiante e
      INNER JOIN login l ON e.dni = l.dni
      INNER JOIN registro r ON e.dni = r.dni
      WHERE l.usuario = ? AND l.contraseña = ?
    ''',
      [usuario, dni],
    );

    return maps.isEmpty ? null : maps.first;
  }

  Future getAllEstudiantes(String s) async {}
}
