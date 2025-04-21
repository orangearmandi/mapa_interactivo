import 'package:flutter/material.dart';
import '../../data/models/marker_model.dart';

class CustomMarkerIcon extends StatelessWidget {
  final CustomMarker marker;
  final VoidCallback? onTap;

  const CustomMarkerIcon({
    Key? key,
    required this.marker,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
          Positioned(
            top: 40,
            left: -20,
            right: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Text(
                marker.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}