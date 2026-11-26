import 'package:flutter/material.dart';

import '../models/almuerzo.dart';
import '../services/api_client.dart';
import '../services/services.dart';

class AlmuerzoFormScreen extends StatefulWidget {
  final Almuerzo? almuerzo;

  const AlmuerzoFormScreen({super.key, this.almuerzo});

  @override
  State<AlmuerzoFormScreen> createState() => _AlmuerzoFormScreenState();
}

class _AlmuerzoFormScreenState extends State<AlmuerzoFormScreen> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _cliente;
  late final TextEditingController _plato;
  late final TextEditingController _cantidad;
  late final TextEditingController _precio;

  late bool _entregado;
  bool _guardando = false;

  bool get _esEdicion => widget.almuerzo != null;

  @override
  void initState() {
    super.initState();
    final actual = widget.almuerzo;
    _cliente = TextEditingController(text: actual?.cliente ?? '');
    _plato = TextEditingController(text: actual?.plato ?? '');
    _cantidad =
        TextEditingController(text: actual == null ? '1' : '${actual.cantidad}');
    _precio = TextEditingController(
        text: actual == null ? '' : actual.precio.toStringAsFixed(2));
    _entregado = actual?.entregado ?? false;
  }

  @override
  void dispose() {
    _cliente.dispose();
    _plato.dispose();
    _cantidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _guardando = true);

    final pedido = Almuerzo(
      id: widget.almuerzo?.id,
      cliente: _cliente.text.trim(),
      plato: _plato.text.trim(),
      cantidad: int.parse(_cantidad.text.trim()),
      precio: double.parse(_precio.text.trim()),
      entregado: _entregado,
    );

    try {
      if (_esEdicion) {
        await AppServices.almuerzos.actualizar(pedido.id!, pedido);
      } else {
        await AppServices.almuerzos.crear(pedido);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _mostrarError(error.message);
    } catch (error) {
      _mostrarError('Error inesperado: $error');
    } finally {
      if (mounted) setState(() => _guardando = false);
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
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar pedido' : 'Nuevo pedido')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _cliente,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el nombre del cliente';
                    }
                    if (valor.trim().length > 100) return 'Máximo 100 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plato,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Plato (ej. Arroz con pato)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant_menu),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el plato';
                    }
                    if (valor.trim().length > 100) return 'Máximo 100 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cantidad,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          final numero = int.tryParse(valor?.trim() ?? '');
                          if (numero == null || numero <= 0) {
                            return 'Debe ser un entero mayor a 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _precio,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Precio unitario (S/)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          final numero = double.tryParse(valor?.trim() ?? '');
                          if (numero == null || numero <= 0) {
                            return 'Debe ser mayor a 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Ya fue entregado'),
                  value: _entregado,
                  onChanged: (valor) => setState(() => _entregado = valor),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_esEdicion ? 'Guardar cambios' : 'Registrar pedido'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
