import 'package:hive/hive.dart';
part 'marker_model.g.dart';

@HiveType(typeId: 0)
class CustomMarker extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  CustomMarker({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}