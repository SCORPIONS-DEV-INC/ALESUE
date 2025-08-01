class Estudiante {
  final int? id;
  final String nombre;
  final String apellido;
  final int edad;
  final String dni;
  final String correo;
  final int? puesto; // Posición del estudiante (1-30)
  final double? calificacion; // Calificación del estudiante

  Estudiante({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.dni,
    required this.correo,
    this.puesto,
    this.calificacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'dni': dni,
      'correo': correo,
      'puesto': puesto,
      'calificacion': calificacion,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      edad: map['edad'],
      dni: map['dni'],
      correo: map['correo'],
      puesto: map['puesto'],
      calificacion: map['calificacion'],
    );
  }
}
