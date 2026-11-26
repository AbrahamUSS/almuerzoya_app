import 'dart:convert';

import '../models/almuerzo.dart';
import '../models/resumen_dia.dart';
import 'api_client.dart';

class AlmuerzoService {
  final ApiClient _api;

  AlmuerzoService(this._api);

  Future<List<Almuerzo>> listar() async {
    final respuesta = await _api.get('/almuerzos');
    final datos = jsonDecode(respuesta.body) as List<dynamic>;
    return datos
        .map((item) => Almuerzo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Almuerzo> crear(Almuerzo almuerzo) async {
    final respuesta = await _api.post('/almuerzos', cuerpo: almuerzo.toJson());
    return Almuerzo.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  Future<Almuerzo> actualizar(int id, Almuerzo almuerzo) async {
    final respuesta =
        await _api.put('/almuerzos/$id', cuerpo: almuerzo.toJson());
    return Almuerzo.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  Future<void> eliminar(int id) async {
    await _api.delete('/almuerzos/$id');
  }

  Future<ResumenDia> resumenDelDia() async {
    final respuesta = await _api.get('/almuerzos/resumen');
    return ResumenDia.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }
}
