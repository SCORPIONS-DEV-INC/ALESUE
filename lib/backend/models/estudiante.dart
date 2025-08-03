// models/estudiante.dart

class Estudiante {
  final int? id;
  final String dni;
  final String nombre;
  final String apellido;
  final int edad;
  final String grado;
  final String seccion;
  final String sexo;
  final String tenantId;

  Estudiante({
    this.id,
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.grado,
    required this.seccion,
    required this.sexo,
    this.tenantId = 'default',
  });

  // Convertir a Map para insertar en DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'grado': grado,
      'seccion': seccion,
      'sexo': sexo,
      'tenant_id': tenantId,
    };
  }

  // Crear desde Map (de la DB)
  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'] as int?,
      dni: map['dni'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      edad: map['edad'] as int,
      grado: map['grado'] as String,
      seccion: map['seccion'] as String,
      sexo: map['sexo'] as String,
      tenantId: map['tenant_id'] as String,
    );
  }

  // ✅ Permite comparar dos estudiantes por dni
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Estudiante && other.dni == dni;
  }

  @override
  int get hashCode => dni.hashCode;

  // ✅ Facilita depuración
  @override
  String toString() {
    return 'Estudiante(id: $id, dni: $dni, nombre: $nombre, apellido: $apellido, edad: $edad, grado: $grado, seccion: $seccion, sexo: $sexo, tenantId: $tenantId)';
  }
}
