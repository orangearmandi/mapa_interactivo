import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mapbox_service.dart';
import '../../data/models/search_result.dart';
import '../providers/markers_provider.dart';
import '../../data/models/marker_model.dart';
import 'package:uuid/uuid.dart';

final mapboxServiceProvider = Provider((ref) => MapboxService());

class MapSearchBar extends ConsumerStatefulWidget {
  final Function(double latitude, double longitude)? onLocationSelected;

  const MapSearchBar({
    Key? key,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ref.read(mapboxServiceProvider).searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _onLocationSelected(SearchResult result) {
    // Crear un nuevo marcador
    final marker = CustomMarker(
      id: const Uuid().v4(),
      name: result.name,
      latitude: result.latitude,
      longitude: result.longitude,
    );

    // Agregar el marcador y centrar
    ref.read(markersProvider.notifier).addMarker(marker);
    widget.onLocationSelected?.call(result.latitude, result.longitude);

    // Limpiar la búsqueda
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ubicación...',
              border: InputBorder.none,
              icon: const Icon(Icons.search),
              suffixIcon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  title: Text(result.name),
                  onTap: () => _onLocationSelected(result),
                );
              },
            ),
          ),
      ],
    );
  }
}