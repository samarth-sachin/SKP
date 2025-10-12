class WeatherModel {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final int rainChance;
  final String icon;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.icon,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      rainChance: json['clouds']['all'] ?? 0,
      icon: json['weather'][0]['icon'] ?? '01d',
      cityName: json['name'] ?? '',
    );
  }
}
