import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const NomadGISApp());
}

class NomadGISApp extends StatelessWidget {
  const NomadGISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullscreenMap(),
    );
  }
}

class FullscreenMap extends StatelessWidget {
  const FullscreenMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(43.238949, 76.889709), // Алматы ❤️
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.nomad_gis',
          ),
        ],
      ),
    );
  }
}
