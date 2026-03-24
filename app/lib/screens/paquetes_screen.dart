import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/paquete.dart';
import 'entrega_screen.dart';
import 'mapa_screen.dart';
import 'login_screen.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key});
  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  late Future<List<Paquete>> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futuro = ApiService.getPaquetes().then(
      (list) => list.map((j) => Paquete.fromJson(j)).toList(),
    );
    setState(() {});
  }

  void _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Paquete>>(
        future: _futuro,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final paquetes = snap.data!;
          if (paquetes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Sin entregas pendientes',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: paquetes.length,
            itemBuilder: (ctx, i) {
              final p = paquetes[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory_2),
                  ),
                  title: Text(p.codigo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.direccionDestino),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        tooltip: 'Ver en mapa',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MapaScreen(paquete: p)),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.camera_alt, color: Colors.orange),
                        tooltip: 'Entregar',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EntregaScreen(paquete: p)),
                          );
                          _cargar();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
