import 'package:almuerzoya_app/models/almuerzo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Almuerzo.fromJson lee la respuesta de la API', () {
    final almuerzo = Almuerzo.fromJson({
      'id': 7,
      'cliente': 'Carlos Pérez',
      'plato': 'Arroz con pato',
      'cantidad': 2,
      'precio': 25.50,
      'total': 51.00,
      'fechaPedido': '2026-11-26',
      'entregado': false,
    });

    expect(almuerzo.id, 7);
    expect(almuerzo.cantidad, 2);
    expect(almuerzo.total, 51.0);
    expect(almuerzo.totalFormateado, 'S/ 51.00');
    expect(almuerzo.entregado, isFalse);
  });

  test('Almuerzo.toJson envía solo los campos que acepta la API', () {
    final json = const Almuerzo(
      cliente: 'Ana',
      plato: 'Seco de cabrito',
      cantidad: 1,
      precio: 30,
    ).toJson();

    expect(json.keys,
        unorderedEquals(['cliente', 'plato', 'cantidad', 'precio', 'entregado']));
    expect(json['entregado'], isFalse);
  });
}
