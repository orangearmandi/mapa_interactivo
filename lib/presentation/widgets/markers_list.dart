import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marker_model.dart';
import '../providers/markers_provider.dart';
import 'delete_marker.dart';
import 'edit_marker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';

void showMarkersListBottomSheet({
  required BuildContext context,
  required Function(CustomMarker) onMarkerSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => MarkersListView(
      onMarkerSelected: (marker) {
        onMarkerSelected(marker);
        Navigator.pop(context);
      },
    ),
  );
}

Future<void> saveKmlFileWeb(String kmlContent) async {
  final bytes = utf8.encode(kmlContent);
  final blob = html.Blob([bytes], 'application/vnd.google-earth.kml+xml');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'marcadores.kml')
    ..click();

  html.Url.revokeObjectUrl(url);
}

Future<void> saveKmlFile(String kmlContent) async {
  if (kIsWeb) {
    await saveKmlFileWeb(kmlContent);
  } else {
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final path = '${downloadsDir.path}/marcadores.kml';
    final file = File(path);
    await file.writeAsString(kmlContent);
    print('KML guardado en: $path');
  }
}

String generateKmlFromCustomMarkers(List<CustomMarker> markers) {
  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<kml xmlns="http://www.opengis.net/kml/2.2">');
  buffer.writeln('<Document>');

  for (var marker in markers) {
    buffer.writeln('<Placemark>');
    buffer.writeln('<name>${marker.name}</name>');
    buffer.writeln('<Point>');
    buffer.writeln(
        '<coordinates>${marker.longitude},${marker.latitude},0</coordinates>');
    buffer.writeln('</Point>');
    buffer.writeln('</Placemark>');
  }

  buffer.writeln('</Document>');
  buffer.writeln('</kml>');

  return buffer.toString();
}

class MarkersListView extends ConsumerWidget {
  final Function(CustomMarker) onMarkerSelected;

  const MarkersListView({
    Key? key,
    required this.onMarkerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = ref.watch(markersProvider);
    return Container(
      width: double.infinity * 0.2,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Marcadores Guardados',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () async {
                  try {
                    final kmlContent = generateKmlFromCustomMarkers(markers);
                    await saveKmlFile(kmlContent);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archivo KML generado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'KML',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help),
                color: Colors.green,
                onPressed: () => {ShowHelp(context)},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: markers.length,
              itemBuilder: (context, index) {
                final marker = markers[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(marker.name),
                  subtitle: Text(
                    'Lat: ${marker.latitude.toStringAsFixed(4)}, '
                    'Lng: ${marker.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () {
                          showEditMarkerDialog(context, marker);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          showDeleteMarkerDialog(context, marker);
                        },
                      ),
                    ],
                  ),
                  onTap: () => onMarkerSelected(marker),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> ShowHelp(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AlertDialog(
            title: const Text('Ayuda',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            content: const Text(
                'Para agregar un marcador, mantén presionado el mapa 2 segundos. '),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Column(
                  children: const [
                    Icon(Icons.cancel, color: Colors.red),
                    Text('Cerrar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
