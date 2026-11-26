# AlmuerzoYa — App Flutter

App móvil (Flutter 3.47 / Dart 3 / Material 3) que consume la API REST de
`almuerzoservice` enviando el token JWT en cada petición protegida.

## Requisitos

- Flutter stable con Dart 3 (verificado con Flutter 3.47.7, Dart 3.13.5).
- La API ejecutándose en local o en Render.
- Paquetes: `http` y `flutter_secure_storage` (ya en `pubspec.yaml`).
- En esta PC, JDK 21: `$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'`.

## URL base de la API

`lib/config/api_config.dart` define:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/api',
);
```

| Escenario | Valor de `API_BASE_URL` |
|---|---|
| Emulador de Android | `http://10.0.2.2:8080/api` (valor por defecto) |
| Celular físico en la misma Wi-Fi | `http://192.168.1.10:8080/api` (IP de tu PC) |
| Render (producción) | `https://almuerzoservice-valx.onrender.com/api` |

Ejemplos:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
flutter build apk --release --dart-define=API_BASE_URL=https://almuerzoservice-valx.onrender.com/api
```

Para el celular físico, la PC y el teléfono deben estar en la misma red y MySQL debe
aceptar conexiones desde la IP de la red (revisar firewall de Windows).

## Ejecutar

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

Pruebas unitarias:

```powershell
flutter test
```

> Nota: si `flutter analyze` falla con `FormatException` del Analysis Server, es un
> problema conocido al analizar rutas con espacios o tildes. Trabaja desde una ruta
> sin acentos (por ejemplo un junction a esta carpeta) o desde el IDE.

## Funcionalidades

**Obligatorias**

- Registro e inicio de sesión con mensajes de error claros (snackbars).
- Token guardado en `flutter_secure_storage`; al reabrir la app se entra directo a la lista
  si el token existe y no venció (`SplashScreen` → `AuthService.haySesionActiva`).
- Lista de pedidos con cliente, plato, cantidad, total y estado, en pestañas.
- Formulario de registro/edición con validaciones de cliente, plato, cantidad y precio.
- Marcar como entregado (o volver a pendiente) y anular con confirmación.
- Cerrar sesión; si la API responde 401, `ApiClient` borra el token y vuelve al login.

**Complementarias implementadas (4)**

- Resumen del día mostrado en una tarjeta (`GET /almuerzos/resumen`).
- Pestañas **Pendientes / Entregados**.
- Aviso de expiración cuando faltan ≤ 5 minutos para que venza el token.
- Búsqueda por nombre del cliente o del plato.

## Estructura

```
lib/
├── config/api_config.dart         URL base (--dart-define)
├── models/                        Almuerzo, AuthResponse, ResumenDia
├── services/
│   ├── token_storage.dart         JWT seguro + claim exp
│   ├── api_client.dart            cabecera Bearer y manejo del 401
│   ├── auth_service.dart          login, registro, sesión persistente
│   ├── almuerzo_service.dart      CRUD y resumen
│   └── services.dart              instancias compartidas + navigatorKey
├── screens/
│   ├── splash_screen.dart         decide login / lista
│   ├── auth_screen.dart           login y registro
│   ├── almuerzo_list_screen.dart  lista, filtros, búsqueda, resumen
│   └── almuerzo_form_screen.dart  formulario
└── main.dart                      MaterialApp y rutas
```

## Flujo del token

1. `POST /auth/login` o `/auth/register` devuelve el JWT.
2. `AuthService` lo guarda con `TokenStorage` (Keystore/Keychain) junto a su `exp`.
3. `ApiClient` lee el token y envía `Authorization: Bearer <token>` en cada petición.
4. Ante un 401: borra el token, navega a `/login` con `pushNamedAndRemoveUntil`
   (no queda pantalla anterior accesible con "atrás").

## Instalar en el celular y subir a Git

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://almuerzoservice-valx.onrender.com/api
flutter install   # con el celular conectado por USB y depuración activada

git init
git add .
git commit -m "App AlmuerzoYa con autenticación JWT y CRUD de pedidos"
git remote add origin https://github.com/TU_USUARIO/almuerzoya_app.git
git push -u origin main
```

> En esta entrega el APK release ya está generado en `../app-release.apk` (raíz de la
> práctica) y en `build/app/outputs/flutter-apk/app-release.apk`, apuntando a
> `https://almuerzoservice-valx.onrender.com/api`. La URL quedó verificada dentro de
> `libapp.so` para arm64-v8a, armeabi-v7a y x86_64.

> En Windows, compilar para **escritorio** requiere activar el Modo desarrollador.
> Para Android no es necesario. Si la ruta del proyecto tiene tildes, compila desde una
> copia en ruta ASCII y copia el APK de vuelta (el AOT snapshotter de Flutter no maneja
> bien la ruta con acentos).
