import 'package:flutter/material.dart';

Future<String?> showAddMarkerDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Agregar Marcador'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nombre del marcador'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}