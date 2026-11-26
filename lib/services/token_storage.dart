import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT en almacenamiento seguro (Keychain / Keystore) y lee su vencimiento.
class TokenStorage {
  static const String _claveToken = 'jwt_token';
  static const String _claveExpira = 'jwt_expira';
  static const String _claveNombre = 'usuario_nombre';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> leerToken() => _storage.read(key: _claveToken);

  Future<DateTime?> leerExpiracion() async {
    final valor = await _storage.read(key: _claveExpira);
    if (valor == null) return null;
    final milisegundos = int.tryParse(valor);
    return milisegundos == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(milisegundos);
  }

  Future<String?> leerNombre() => _storage.read(key: _claveNombre);

  Future<void> guardarToken(String token, {DateTime? expiraEn, String? nombre}) async {
    await _storage.write(key: _claveToken, value: token);
    final expiracion = expiraEn ?? _leerExpiracionDelToken(token);
    if (expiracion != null) {
      await _storage.write(
        key: _claveExpira,
        value: expiracion.millisecondsSinceEpoch.toString(),
      );
    }
    if (nombre != null) {
      await _storage.write(key: _claveNombre, value: nombre);
    }
  }

  Future<void> borrar() async {
    await Future.wait([
      _storage.delete(key: _claveToken),
      _storage.delete(key: _claveExpira),
      _storage.delete(key: _claveNombre),
    ]);
  }

  /// Decodifica el claim `exp` del JWT sin verificar la firma (solo para avisar al usuario).
  DateTime? _leerExpiracionDelToken(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;
      var payload = partes[1].padRight((partes[1].length + 3) ~/ 4 * 4, '=');
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final exp = decoded['exp'];
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
