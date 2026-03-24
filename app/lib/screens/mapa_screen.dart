import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/paquete.dart';

class MapaScreen extends StatelessWidget {
  final Paquete paquete;
  const MapaScreen({super.key, required this.paquete});

  @override
  Widget build(BuildContext context) {
    final destino = LatLng(
      paquete.latitudDestino ?? 20.5888,
      paquete.longitudDestino ?? -100.3899,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Mapa - ${paquete.codigo}')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: destino, zoom: 16),
        markers: {
          Marker(
            markerId: MarkerId(paquete.codigo),
            position: destino,
            infoWindow: InfoWindow(
              title: paquete.codigo,
              snippet: paquete.direccionDestino,
            ),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
