class ResumenDia {
  final DateTime fecha;
  final int cantidadAlmuerzos;
  final double montoTotal;

  const ResumenDia({
    required this.fecha,
    required this.cantidadAlmuerzos,
    required this.montoTotal,
  });

  factory ResumenDia.fromJson(Map<String, dynamic> json) {
    return ResumenDia(
      fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
      cantidadAlmuerzos: (json['cantidadAlmuerzos'] as num?)?.toInt() ?? 0,
      montoTotal: (json['montoTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
