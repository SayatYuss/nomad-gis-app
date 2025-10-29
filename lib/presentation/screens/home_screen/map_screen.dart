import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit_lite/mapkit.dart';
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  
  MapWindow? _mapWindow;
  
  @override
  Widget build(BuildContext context) {
    return  YandexMap(onMapCreated: (mapWindow) => _mapWindow = mapWindow);
  }
}

