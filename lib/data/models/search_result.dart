class SearchResult {
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  SearchResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final coordinates = json['center'] as List;
    return SearchResult(
      name: json['text'] as String,
      address: json['place_name'] as String?,
      longitude: coordinates[0] as double,
      latitude: coordinates[1] as double,
    );
  }
}