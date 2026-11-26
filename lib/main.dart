import 'package:flutter/material.dart';

import 'models/almuerzo.dart';
import 'screens/almuerzo_form_screen.dart';
import 'screens/almuerzo_list_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlmuerzoYaApp());
}

class AlmuerzoYaApp extends StatelessWidget {
  const AlmuerzoYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlmuerzoYa',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppServices.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const AuthScreen(),
        '/almuerzos': (_) => const AlmuerzoListScreen(),
        '/almuerzo-form': (context) {
          final argumento = ModalRoute.of(context)?.settings.arguments;
          return AlmuerzoFormScreen(
            almuerzo: argumento is Almuerzo ? argumento : null,
          );
        },
      },
    );
  }
}
