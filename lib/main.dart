import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'data/models/marker_model.dart';
import 'presentation/screens/interactive_map.dart';

void main() async {
  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar el adaptador de marcadores
  Hive.registerAdapter(CustomMarkerAdapter());

  // Envolver la aplicación con ProviderScope
  runApp(
    // Añadir ProviderScope aquí
    ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,brightness: Brightness.light
      ),
      home: const InteractiveMapScreen(),
    );
  }
}