class Almuerzo {
  final int? id;
  final String cliente;
  final String plato;
  final int cantidad;
  final double precio;
  final double total;
  final DateTime? fechaPedido;
  final bool entregado;

  const Almuerzo({
    this.id,
    required this.cliente,
    required this.plato,
    required this.cantidad,
    required this.precio,
    this.total = 0,
    this.fechaPedido,
    this.entregado = false,
  });

  factory Almuerzo.fromJson(Map<String, dynamic> json) {
    return Almuerzo(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      cliente: json['cliente'] as String? ?? '',
      plato: json['plato'] as String? ?? '',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      fechaPedido: json['fechaPedido'] == null
          ? null
          : DateTime.tryParse(json['fechaPedido'] as String),
      entregado: json['entregado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'cliente': cliente,
        'plato': plato,
        'cantidad': cantidad,
        'precio': precio,
        'entregado': entregado,
      };

  Almuerzo copiaCon({bool? entregado}) => Almuerzo(
        id: id,
        cliente: cliente,
        plato: plato,
        cantidad: cantidad,
        precio: precio,
        total: total,
        fechaPedido: fechaPedido,
        entregado: entregado ?? this.entregado,
      );

  String get totalFormateado => 'S/ ${total.toStringAsFixed(2)}';
}
