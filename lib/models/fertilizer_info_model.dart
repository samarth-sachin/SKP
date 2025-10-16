class FertilizerInfo {
  final String id;
  final String nameEnglish;
  final String nameMarathi;
  final String company;
  final String category; // Micronutrient, Enzyme, Bio-stimulant, etc.
  final String purpose;
  final String purposeMarathi;
  final List<String> benefits;
  final List<String> benefitsMarathi;
  final String dosage;
  final String dosageMarathi;
  final String applicationMethod;
  final String applicationMethodMarathi;
  final String timing;
  final String timingMarathi;
  final List<String> suitableFor; // Crops
  final String composition;
  final String imageUrl;

  FertilizerInfo({
    required this.id,
    required this.nameEnglish,
    required this.nameMarathi,
    required this.company,
    required this.category,
    required this.purpose,
    required this.purposeMarathi,
    required this.benefits,
    required this.benefitsMarathi,
    required this.dosage,
    required this.dosageMarathi,
    required this.applicationMethod,
    required this.applicationMethodMarathi,
    required this.timing,
    required this.timingMarathi,
    required this.suitableFor,
    required this.composition,
    this.imageUrl = '',
  });
}
