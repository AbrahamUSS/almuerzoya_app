import 'package:flutter/widgets.dart';

import 'almuerzo_service.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'token_storage.dart';

/// Instancias compartidas de la app (sin dependencias externas de DI).
class AppServices {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final TokenStorage tokenStorage = TokenStorage();
  static final ApiClient apiClient = ApiClient(tokenStorage, _irAlLogin);
  static final AuthService auth = AuthService(apiClient, tokenStorage);
  static final AlmuerzoService almuerzos = AlmuerzoService(apiClient);

  static void _irAlLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
