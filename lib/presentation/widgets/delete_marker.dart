import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marker_model.dart';
import '../providers/markers_provider.dart';

class DeleteMarkerDialog extends ConsumerWidget {
  final CustomMarker marker;

  const DeleteMarkerDialog({Key? key, required this.marker}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Eliminar Marcador'),
      content: Text('¿Estás seguro de que quieres eliminar el marcador "${marker.name}"?'),
      actions: [
        // Botón de cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        // Botón de confirmación de eliminación
        ElevatedButton(
          onPressed: () {
            // Eliminar el marcador usando el provider
            ref.read(markersProvider.notifier).removeMarker(marker.id);

            // Cerrar el diálogo
            Navigator.of(context).pop();

            // Mostrar una notificación de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Marcador "${marker.name}" eliminado'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}

// Función auxiliar para mostrar el diálogo de eliminación
void showDeleteMarkerDialog(BuildContext context, CustomMarker marker) {
  showDialog(
    context: context,
    builder: (context) => DeleteMarkerDialog(marker: marker),
  );
}