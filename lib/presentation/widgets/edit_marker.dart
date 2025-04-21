import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marker_model.dart';
import '../providers/markers_provider.dart';

class EditMarkerDialog extends ConsumerStatefulWidget {
  final CustomMarker marker;

  const EditMarkerDialog({Key? key, required this.marker}) : super(key: key);

  @override
  _EditMarkerDialogState createState() => _EditMarkerDialogState();
}

class _EditMarkerDialogState extends ConsumerState<EditMarkerDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador con el nombre actual del marcador
    _nameController = TextEditingController(text: widget.marker.name);
  }

  @override
  void dispose() {
    // Liberar recursos del controlador
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Marcador'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nombre del Marcador',
          hintText: 'Ingresa un nuevo nombre',
        ),
        onTap: () => _nameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _nameController.text.length
        ),
      ),
      actions: [
        // Botón de cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        // Botón de guardar cambios
        ElevatedButton(
          onPressed: () {
            // Validar que el nombre no esté vacío
            if (_nameController.text.trim().isNotEmpty) {
              // Crear un nuevo marcador con el nombre actualizado
              final updatedMarker = CustomMarker(
                id: widget.marker.id,
                name: _nameController.text.trim(),
                latitude: widget.marker.latitude,
                longitude: widget.marker.longitude,
              );

              // Actualizar el marcador usando el provider
              ref.read(markersProvider.notifier).updateMarker(updatedMarker);

              // Cerrar el diálogo
              Navigator.of(context).pop();

              // Mostrar una notificación de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marcador "${updatedMarker.name}" actualizado'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Función auxiliar para mostrar el diálogo de edición
void showEditMarkerDialog(BuildContext context, CustomMarker marker) {
  showDialog(
    context: context,
    builder: (context) => EditMarkerDialog(marker: marker),
  );
}