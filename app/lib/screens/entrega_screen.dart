import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/paquete.dart';
import '../services/api_service.dart';

class EntregaScreen extends StatefulWidget {
  final Paquete paquete;
  const EntregaScreen({super.key, required this.paquete});
  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  XFile? _pickedFile;
  Position? _posicion;
  bool _loading = false;

  Future<void> _tomarFoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 60);
    if (picked != null) setState(() => _pickedFile = picked);
  }

  Future<void> _obtenerGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa el servicio de ubicacion')),
        );
      }
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permiso GPS denegado permanentemente')),
        );
      }
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
    setState(() => _posicion = pos);
  }

  Future<void> _entregar() async {
    if (_pickedFile == null || _posicion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma foto y obten GPS primero')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final bytes = await _pickedFile!.readAsBytes();
      final b64 = base64Encode(bytes);
      await ApiService.entregarPaquete(
        widget.paquete.id,
        b64,
        _posicion!.latitude,
        _posicion!.longitude,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paquete entregado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildFotoPreview() {
    if (_pickedFile == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_camera, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Sin foto de evidencia'),
            ],
          ),
        ),
      );
    }
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_pickedFile!.path, height: 220, fit: BoxFit.cover),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            Image.file(File(_pickedFile!.path), height: 220, fit: BoxFit.cover),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entregar ${widget.paquete.codigo}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.paquete.direccionDestino,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFotoPreview(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label:
                  Text(_pickedFile != null ? 'Retomar Foto' : 'Tomar Foto'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _obtenerGPS,
              icon: Icon(
                _posicion != null ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: _posicion != null ? Colors.green : null,
              ),
              label: Text(_posicion != null
                  ? 'GPS: ${_posicion!.latitude.toStringAsFixed(4)}, ${_posicion!.longitude.toStringAsFixed(4)}'
                  : 'Obtener Ubicacion GPS'),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    _pickedFile != null
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _pickedFile != null ? Colors.green : Colors.grey),
                const SizedBox(width: 4),
                const Text('Foto'),
                const SizedBox(width: 20),
                Icon(
                    _posicion != null ? Icons.check_circle : Icons.cancel,
                    color: _posicion != null ? Colors.green : Colors.grey),
                const SizedBox(width: 4),
                const Text('GPS'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    (_loading || _pickedFile == null || _posicion == null)
                        ? null
                        : _entregar,
                icon: const Icon(Icons.check_circle),
                label: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Paquete Entregado',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
