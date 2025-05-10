import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/map_constants.dart';
import '../widgets/custom_marker_icon.dart';
import '../widgets/marker_dialog.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/markers_list.dart';
import '../../data/models/marker_model.dart';
import '../providers/markers_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/gestures.dart';

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InteractiveMapScreen> createState() =>
      _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  final MapController _mapController = MapController();
  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = [];
    // Escuchar cambios en los marcadores
    ref.listenManual(markersProvider, (previous, next) {
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final customMarkers = ref.read(markersProvider);
    setState(() {
      _markers = _buildMarkers(customMarkers);
    });
  }

  List<Marker> _buildMarkers(List<CustomMarker> customMarkers) {
    return customMarkers
        .map((marker) => Marker(
              point: LatLng(marker.latitude, marker.longitude),
              width: 40,
              height: 40,
              child: CustomMarkerIcon(
                marker: marker,
                onTap: () => _handleMarkerTap(marker),
              ),
            ))
        .toList();
  }

  @override
  void _handleMarkerTap(CustomMarker marker) {
    _mapController.move(
        LatLng(marker.latitude, marker.longitude), MapConstants.defaultZoom);
  }

  Future<void> _handleLongPress(
      TapPosition tapPosition, LatLng position) async {
    try {
      final name = await showAddMarkerDialog(context);
      if (name != null && name.isNotEmpty) {
        final marker = CustomMarker(
          id: const Uuid().v4(),
          name: name,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await ref.read(markersProvider.notifier).addMarker(marker);
        _updateMarkers();
      }
    } catch (e) {
      _showError('Error al agregar marcador');
    }
  }

  void _showMarkersList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MarkersListView(
        onMarkerSelected: (marker) {
          _handleMarkerTap(marker);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(markersProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMap(markers),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: MapSearchBar(
              onLocationSelected: (lat, lng) {
                _mapController.move(LatLng(lat, lng), 15.0);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _showMarkersList,
        tooltip: 'Lista de Marcadores',
        materialTapTargetSize: MaterialTapTargetSize.padded,
        child: const Icon(
          size: 30,
          Icons.list,
          color: Colors.blue,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Image.asset('assets/logo.png'),
      ),
      centerTitle: true,
      title: const Text('Mapa Interactivo',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildMap(List<CustomMarker> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: MapConstants.initialPosition,
        initialZoom: MapConstants.defaultZoom,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
        onLongPress: _handleLongPress,
      ),
      children: [
        _buildTileLayer(),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: MapConstants.mapboxUrlTemplate,
      userAgentPackageName: MapConstants.userAgentPackageName,
      additionalOptions: const {
        'accessToken': MapConstants.mapboxAccessToken,
        'id': MapConstants.mapboxStyleId,
      },
    );
  }
}
