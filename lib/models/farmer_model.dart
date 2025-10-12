class FarmerModel {
  final String id;
  final String name;
  final String village;
  final String phoneNumber;
  final String? alternatePhone;
  final DateTime registrationDate;
  final List<String> landIds;

  FarmerModel({
    required this.id,
    required this.name,
    required this.village,
    required this.phoneNumber,
    this.alternatePhone,
    required this.registrationDate,
    this.landIds = const [],
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      village: json['village'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      alternatePhone: json['alternatePhone'],
      registrationDate: DateTime.parse(json['registrationDate']),
      landIds: List<String>.from(json['landIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'village': village,
      'phoneNumber': phoneNumber,
      'alternatePhone': alternatePhone,
      'registrationDate': registrationDate.toIso8601String(),
      'landIds': landIds,
    };
  }
}
