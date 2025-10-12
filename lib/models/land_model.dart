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
    this.doseHistory = const [],
  });

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      landName: json['landName'] ?? '',
      location: json['location'] ?? '',
      currentCrop: json['currentCrop'] ?? '',
      areaInAcres: (json['areaInAcres'] ?? 0).toDouble(),
      doseHistory: List<String>.from(json['doseHistory'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'landName': landName,
      'location': location,
      'currentCrop': currentCrop,
      'areaInAcres': areaInAcres,
      'doseHistory': doseHistory,
    };
  }
}
