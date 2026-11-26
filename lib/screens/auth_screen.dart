import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/api_client.dart';
import '../services/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  int _modo = 0; // 0 = login, 1 = registro
  bool _cargando = false;
  bool _verPassword = false;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);

    try {
      if (_modo == 1) {
        await AppServices.auth.registrar(
          nombre: _nombre.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await AppServices.auth.iniciarSesion(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/almuerzos');
    } on ApiException catch (error) {
      _mostrarError(error.message);
    } catch (error) {
      _mostrarError('Error inesperado: $error');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formulario,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lunch_dining, size: 64, color: Colors.deepOrange),
                        const SizedBox(height: 8),
                        Text('AlmuerzoYa', style: tema.textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Gestiona los pedidos de almuerzo de tus clientes',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('Ingresar'), icon: Icon(Icons.login)),
                            ButtonSegment(value: 1, label: Text('Registrarse'), icon: Icon(Icons.person_add)),
                          ],
                          selected: {_modo},
                          onSelectionChanged: (seleccion) =>
                              setState(() => _modo = seleccion.first),
                        ),
                        const SizedBox(height: 24),
                        if (_modo == 1)
                          TextFormField(
                            controller: _nombre,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del encargado',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Ingresa tu nombre';
                              }
                              if (valor.trim().length > 100) {
                                return 'Máximo 100 caracteres';
                              }
                              return null;
                            },
                          ),
                        if (_modo == 1) const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            final patron = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!patron.hasMatch(valor.trim())) {
                              return 'Correo no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: !_verPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_verPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _verPassword = !_verPassword),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            if (_modo == 1 && valor.length < 6) {
                              return 'Debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _enviar(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _cargando ? null : _enviar,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_modo == 1 ? 'Crear cuenta e ingresar' : 'Iniciar sesión'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'API: ${ApiConfig.baseUrl}',
                          style: tema.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
