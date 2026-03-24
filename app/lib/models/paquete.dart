class Paquete {
  final int id;
  final String codigo;
  final String direccionDestino;
  final double? latitudDestino;
  final double? longitudDestino;
  final String estado;

  Paquete({
    required this.id,
    required this.codigo,
    required this.direccionDestino,
    this.latitudDestino,
    this.longitudDestino,
    required this.estado,
  });

  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json['id'],
      codigo: json['codigo'],
      direccionDestino: json['direccion_destino'],
      latitudDestino: json['latitud_destino']?.toDouble(),
      longitudDestino: json['longitud_destino']?.toDouble(),
      estado: json['estado'],
    );
  }
}
