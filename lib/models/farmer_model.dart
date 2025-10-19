class FarmerModel {
  final String id;
  final String name;
  final String village;
  final String phoneNumber;
  final String? alternatePhone;
  final String aadhaarNumber;
  final DateTime registrationDate;
  final List<String> landIds;

  FarmerModel({
    required this.id,
    required this.name,
    required this.village,
    required this.phoneNumber,
    this.alternatePhone,
    required this.aadhaarNumber,
    required this.registrationDate,
    required this.landIds,
  });

  // Add copyWith method
  FarmerModel copyWith({
    String? id,
    String? name,
    String? village,
    String? phoneNumber,
    String? alternatePhone,
    String? aadhaarNumber,
    DateTime? registrationDate,
    List<String>? landIds,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      village: village ?? this.village,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      landIds: landIds ?? this.landIds,
    );
  }
}
