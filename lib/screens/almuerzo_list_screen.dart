import 'package:flutter/material.dart';

import '../models/almuerzo.dart';
import '../models/resumen_dia.dart';
import '../services/api_client.dart';
import '../services/services.dart';

class AlmuerzoListScreen extends StatefulWidget {
  const AlmuerzoListScreen({super.key});

  @override
  State<AlmuerzoListScreen> createState() => _AlmuerzoListScreenState();
}

class _AlmuerzoListScreenState extends State<AlmuerzoListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController _busqueda = TextEditingController();

  late Future<List<Almuerzo>> _pedidos;
  late Future<ResumenDia> _resumen;
  DateTime? _expiraEn;
  String? _nombreUsuario;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _recargar();
    _leerDatosDelToken();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _pedidos = AppServices.almuerzos.listar();
      _resumen = AppServices.almuerzos.resumenDelDia();
    });
  }

  Future<void> _leerDatosDelToken() async {
    final expira = await AppServices.tokenStorage.leerExpiracion();
    final nombre = await AppServices.tokenStorage.leerNombre();
    if (!mounted) return;
    setState(() {
      _expiraEn = expira;
      _nombreUsuario = nombre;
    });
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

  Future<void> _marcarEntregado(Almuerzo pedido) async {
    try {
      await AppServices.almuerzos.actualizar(
        pedido.id!,
        pedido.copiaCon(entregado: !pedido.entregado),
      );
      _recargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pedido.entregado
                ? 'Pedido marcado como pendiente'
                : 'Pedido marcado como entregado'),
          ),
        );
      }
    } on ApiException catch (error) {
      _mostrarError(error.message);
    }
  }

  Future<void> _anular(Almuerzo pedido) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anular pedido'),
        content: Text('¿Anular el pedido de ${pedido.cliente}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await AppServices.almuerzos.eliminar(pedido.id!);
      _recargar();
    } on ApiException catch (error) {
      _mostrarError(error.message);
    }
  }

  Future<void> _editar(Almuerzo pedido) async {
    final cambios = await Navigator.pushNamed(
      context,
      '/almuerzo-form',
      arguments: pedido,
    );
    if (cambios == true && mounted) _recargar();
  }

  Future<void> _nuevo() async {
    final creado = await Navigator.pushNamed(context, '/almuerzo-form');
    if (creado == true && mounted) _recargar();
  }

  Future<void> _cerrarSesion() async {
    await AppServices.auth.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  bool _avisoDeExpiracion() {
    if (_expiraEn == null) return false;
    final restante = _expiraEn!.difference(DateTime.now()).inMinutes;
    return restante > 0 && restante <= 5;
  }

  Widget _lista(bool entregados) {
    return FutureBuilder<List<Almuerzo>>(
      future: _pedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No se pudieron cargar los pedidos: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final texto = _busqueda.text.trim().toLowerCase();
        final pedidos = snapshot.data?.where((pedido) {
          if (pedido.entregado != entregados) return false;
          if (texto.isEmpty) return true;
          return pedido.cliente.toLowerCase().contains(texto) ||
              pedido.plato.toLowerCase().contains(texto);
        }).toList() ?? <Almuerzo>[];

        if (pedidos.isEmpty) {
          return Center(
            child: Text(entregados
                ? 'Aún no hay pedidos entregados'
                : 'No hay pedidos pendientes'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
          itemCount: pedidos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, indice) {
            final pedido = pedidos[indice];
            final fecha = pedido.fechaPedido == null
                ? ''
                : pedido.fechaPedido!.toLocal().toString().substring(0, 10);
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${pedido.cantidad}')),
                title: Text(pedido.cliente),
                subtitle: Text(
                  '${pedido.plato}  •  ${pedido.totalFormateado}'
                  '${fecha.isEmpty ? '' : '  •  $fecha'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: entregados
                          ? 'Marcar como pendiente'
                          : 'Marcar como entregado',
                      icon: Icon(
                        entregados ? Icons.undo : Icons.check_circle_outline,
                        color: entregados ? Colors.green : null,
                      ),
                      onPressed: () => _marcarEntregado(pedido),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          _editar(pedido);
                        } else if (opcion == 'anular') {
                          _anular(pedido);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(value: 'anular', child: Text('Anular')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AlmuerzoYa'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Entregados'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_nombreUsuario != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Hola, ${_nombreUsuario!}',
                      style: tema.textTheme.titleMedium),
                ),
              ),
            if (_avisoDeExpiracion())
              Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Tu sesión vence pronto. Guarda tu trabajo o vuelve a ingresar.',
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: FutureBuilder<ResumenDia>(
                future: _resumen,
                builder: (context, snapshot) {
                  final resumen = snapshot.data;
                  return Card(
                    color: tema.colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.summarize),
                      title: Text(resumen == null
                          ? 'Resumen del día'
                          : 'Hoy: ${resumen.cantidadAlmuerzos} almuerzos'),
                      subtitle: Text(resumen == null
                          ? 'Cargando…'
                          : 'Total: S/ ${resumen.montoTotal.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _busqueda,
                decoration: const InputDecoration(
                  labelText: 'Buscar por cliente o plato',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_lista(false), _lista(true)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
