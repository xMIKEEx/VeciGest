class Unit {
  final String id;
  final String nombre;
  final String codigo;
  final String comunidadId;
  final String? usuarioAsignado;
  final String estado; // 'libre' o 'ocupada'

  Unit({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.comunidadId,
    this.usuarioAsignado,
    required this.estado,
  });

  factory Unit.fromMap(String id, Map<String, dynamic> map) {
    return Unit(
      id: id,
      nombre: map['nombre'] ?? '',
      codigo: map['codigo'] ?? '',
      comunidadId: map['comunidadId'] ?? '',
      usuarioAsignado: map['usuarioAsignado'],
      estado: map['estado'] ?? 'libre',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'comunidadId': comunidadId,
      'usuarioAsignado': usuarioAsignado,
      'estado': estado,
    };
  }
}
