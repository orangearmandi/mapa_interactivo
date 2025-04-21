import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/boxes.dart';
import '../../data/models/marker_model.dart';

final markersProvider = StateNotifierProvider<MarkersNotifier, List<CustomMarker>>((ref) {
  return MarkersNotifier();
});

class MarkersNotifier extends StateNotifier<List<CustomMarker>> {
  MarkersNotifier() : super([]) {
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final box = await Hive.openBox<CustomMarker>(BoxesConstants.marketlistBox);
    state = box.values.toList();
  }

  Future<void> addMarker(CustomMarker marker) async {
    final box = await Hive.openBox<CustomMarker>(BoxesConstants.marketlistBox);
    await box.add(marker);
    state = [...state, marker];
  }

  Future<void> removeMarker(String id) async {
    final box = await Hive.openBox<CustomMarker>(BoxesConstants.marketlistBox);
    final markerToDelete = box.values.firstWhere((m) => m.id == id);
    await markerToDelete.delete();
    state = state.where((marker) => marker.id != id).toList();
  }

  Future<void> updateMarker(CustomMarker updatedMarker) async {
    final box = await Hive.openBox<CustomMarker>(BoxesConstants.marketlistBox);
    final index = state.indexWhere((m) => m.id == updatedMarker.id);
    if (index != -1) {
      await box.putAt(index, updatedMarker);
      state = [
        ...state.sublist(0, index),
        updatedMarker,
        ...state.sublist(index + 1)
      ];
    }
  }
}