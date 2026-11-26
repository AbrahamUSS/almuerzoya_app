/// URL base de la API.
///
/// Por defecto funciona con el emulador de Android (10.0.2.2 = localhost del PC).
/// Para un celular físico en la misma red, o para Render, compila con:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/api
///   flutter build apk --dart-define=API_BASE_URL=https://tu-servicio.onrender.com/api
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );
}
