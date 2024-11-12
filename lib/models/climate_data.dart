class ClimateData {
  final int? id; // Add an optional ID for database purposes
  final double temperature;
  final double humidity;
  final int timestamp;

  ClimateData({
    this.id,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  // Convert a map from the database to a ClimateSensorData object
  factory ClimateData.fromMap(Map<String, dynamic> map) {
    return ClimateData(
      id: map['_id'],
      temperature: map['temperature'],
      humidity: map['humidity'],
      timestamp: map['timestamp'],
    );
  }

  // Convert a ClimateSensorData object to a map for the database
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp,
    };
  }
}
