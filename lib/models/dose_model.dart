class DoseModel {
  final String id;
  final String farmerId;
  final String landId;
  final int doseNumber;
  final DateTime applicationDate;
  final DateTime? nextDoseDate;
  final List<Fertilizer> fertilizers;
  final String paymentType;
  final double amount;
  final bool isPaid;
  final String? notes;

  DoseModel({
    required this.id,
    required this.farmerId,
    required this.landId,
    required this.doseNumber,
    required this.applicationDate,
    this.nextDoseDate,
    required this.fertilizers,
    required this.paymentType,
    required this.amount,
    this.isPaid = false,
    this.notes,
  });

  factory DoseModel.fromJson(Map<String, dynamic> json) {
    return DoseModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      landId: json['landId'] ?? '',
      doseNumber: json['doseNumber'] ?? 1,
      applicationDate: DateTime.parse(json['applicationDate']),
      nextDoseDate: json['nextDoseDate'] != null 
          ? DateTime.parse(json['nextDoseDate']) 
          : null,
      fertilizers: (json['fertilizers'] as List)
          .map((f) => Fertilizer.fromJson(f))
          .toList(),
      paymentType: json['paymentType'] ?? 'Cash',
      amount: (json['amount'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'landId': landId,
      'doseNumber': doseNumber,
      'applicationDate': applicationDate.toIso8601String(),
      'nextDoseDate': nextDoseDate?.toIso8601String(),
      'fertilizers': fertilizers.map((f) => f.toJson()).toList(),
      'paymentType': paymentType,
      'amount': amount,
      'isPaid': isPaid,
      'notes': notes,
    };
  }
}

class Fertilizer {
  final String name;
  final double quantity;
  final String unit;

  Fertilizer({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
