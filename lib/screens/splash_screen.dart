import 'package:flutter/material.dart';

import '../services/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decidirRuta();
  }

  Future<void> _decidirRuta() async {
    // Pequeña pausa para evitar un parpadeo mientras se lee el almacenamiento seguro.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final activa = await AppServices.auth.haySesionActiva();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(activa ? '/almuerzos' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lunch_dining, size: 72, color: Colors.deepOrange),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AlmuerzoYa', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
