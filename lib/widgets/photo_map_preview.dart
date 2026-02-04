import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';


class PhotoMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;

  const PhotoMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return SizedBox(
      height: 200, // Výška mapy v paneli
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15.0, // Dostatočný zoom na detail miesta
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Statická mapa
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.bakalarka',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}