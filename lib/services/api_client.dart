import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException()
      : super(401, 'Tu sesión venció. Inicia sesión nuevamente.');
}

/// Cliente HTTP que adjunta el JWT a cada petición protegida.
/// Si la API responde 401, borra el token y avisa a la app para volver al login.
class ApiClient {
  final http.Client _cliente = http.Client();
  final TokenStorage _almacenamiento;
  final void Function() _alNoAutorizado;

  ApiClient(this._almacenamiento, this._alNoAutorizado);

  Future<http.Response> get(String ruta) => _enviar('GET', ruta);
  Future<http.Response> post(String ruta, {Object? cuerpo, bool requiereToken = true}) =>
      _enviar('POST', ruta, cuerpo: cuerpo, requiereToken: requiereToken);
  Future<http.Response> put(String ruta, {Object? cuerpo}) =>
      _enviar('PUT', ruta, cuerpo: cuerpo);
  Future<http.Response> delete(String ruta) => _enviar('DELETE', ruta);

  Future<http.Response> _enviar(
    String metodo,
    String ruta, {
    Object? cuerpo,
    bool requiereToken = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$ruta');
    final token = requiereToken ? await _almacenamiento.leerToken() : null;
    final cabeceras = <String, String>{
      'Accept': 'application/json',
      if (cuerpo != null) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    late final http.Response respuesta;
    try {
      final peticion = http.Request(metodo, uri)..headers.addAll(cabeceras);
      if (cuerpo != null) peticion.body = jsonEncode(cuerpo);
      respuesta = await http.Response.fromStream(await _cliente.send(peticion));
    } on http.ClientException catch (error) {
      throw ApiException(
        0,
        'No se pudo conectar con la API: $error. Revisa la URL base y tu conexión.',
      );
    }

    if (respuesta.statusCode == 401) {
      if (requiereToken) {
        await _almacenamiento.borrar();
        _alNoAutorizado();
        throw const UnauthorizedException();
      }
      throw ApiException(401, _mensaje(respuesta.body));
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return respuesta;
    }
    throw ApiException(respuesta.statusCode, _mensaje(respuesta.body));
  }

  String _mensaje(String cuerpo) {
    try {
      final datos = jsonDecode(cuerpo);
      if (datos is Map) {
        final mensaje = datos['mensaje'] ?? datos['error'] ?? datos['message'];
        if (mensaje != null) return mensaje.toString();
        final detalles = datos['detalles'];
        if (detalles is Map && detalles.isNotEmpty) {
          return 'Datos inválidos: ${detalles.entries.first.key} (${detalles.entries.first.value}).';
        }
      }
      return cuerpo;
    } catch (_) {
      return cuerpo.isEmpty ? 'Error desconocido en la API' : cuerpo;
    }
  }
}
