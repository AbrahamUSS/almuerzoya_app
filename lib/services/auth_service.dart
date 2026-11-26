import 'dart:convert';

import '../models/auth_response.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  final ApiClient _api;
  final TokenStorage _almacenamiento;

  AuthService(this._api, this._almacenamiento);

  Future<AuthResponse> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.post(
      '/auth/register',
      cuerpo: {'nombre': nombre, 'email': email, 'password': password},
      requiereToken: false,
    );
    return _procesar(respuesta.body);
  }

  Future<AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.post(
      '/auth/login',
      cuerpo: {'email': email, 'password': password},
      requiereToken: false,
    );
    return _procesar(respuesta.body);
  }

  Future<void> cerrarSesion() => _almacenamiento.borrar();

  /// Sesión persistente: hay token guardado y todavía no venció.
  Future<bool> haySesionActiva() async {
    final token = await _almacenamiento.leerToken();
    if (token == null || token.isEmpty) return false;
    final expira = await _almacenamiento.leerExpiracion();
    if (expira != null && expira.isBefore(DateTime.now())) {
      await _almacenamiento.borrar();
      return false;
    }
    return true;
  }

  Future<AuthResponse> _procesar(String cuerpo) async {
    final datos = jsonDecode(cuerpo) as Map<String, dynamic>;
    final respuesta = AuthResponse.fromJson(datos);
    await _almacenamiento.guardarToken(
      respuesta.token,
      expiraEn: respuesta.expiraEn,
      nombre: respuesta.nombre,
    );
    return respuesta;
  }
}
