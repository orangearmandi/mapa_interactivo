import 'package:flutter/material.dart';

Future<String?> showAddMarkerDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Agregar Marcador',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Nombre del marcador'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Column(
              children: const [
                Icon(Icons.cancel, color: Colors.red),
                Text('Cancelar'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Column(
              children: const [
                Icon(Icons.check, color: Colors.green),
                Text('Agregar'),
              ],
            ),
          ),
        ],
      );
    },
  );
}
