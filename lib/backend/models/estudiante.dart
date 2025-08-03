class Estudiante {
  final int? id;
  final String dni;
  final String nombre;
  final String apellido;
  final int edad;
  final String grado;
  final String seccion;
  final String sexo;
  final String correo;
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
    required this.correo,
    this.tenantId = 'default',
  });

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      dni: map['dni'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      edad: map['edad'],
      grado: map['grado'],
      seccion: map['seccion'],
      sexo: map['sexo'],
      correo: map['correo'] ?? '',
      tenantId: map['tenant_id'] ?? 'default',
    );
  }

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
      'correo': correo,
      'tenant_id': tenantId,
    };
  }

  @override
  String toString() {
    return 'Estudiante(id: $id, dni: $dni, nombre: $nombre, apellido: $apellido, edad: $edad, grado: $grado, seccion: $seccion, sexo: $sexo, correo: $correo, tenantId: $tenantId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Estudiante &&
          runtimeType == other.runtimeType &&
          dni == other.dni;

  @override
  int get hashCode => dni.hashCode;
}
