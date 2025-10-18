class LandModel {
  final String id;
  final String farmerId;
  final String landName;
  final String location;
  final String currentCrop;
  final double areaInAcres;
  final List<String> doseHistory;

  LandModel({
    required this.id,
    required this.farmerId,
    required this.landName,
    required this.location,
    required this.currentCrop,
    required this.areaInAcres,
    required this.doseHistory,
  });

  // Add copyWith method
  LandModel copyWith({
    String? id,
    String? farmerId,
    String? landName,
    String? location,
    String? currentCrop,
    double? areaInAcres,
    List<String>? doseHistory,
  }) {
    return LandModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      landName: landName ?? this.landName,
      location: location ?? this.location,
      currentCrop: currentCrop ?? this.currentCrop,
      areaInAcres: areaInAcres ?? this.areaInAcres,
      doseHistory: doseHistory ?? this.doseHistory,
    );
  }
}