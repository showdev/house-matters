import 'dart:math';

import 'package:house_matters/models/climate_data.dart';

// utils.dart

ClimateData generateClimateDataEntry(double temp, double humidityValue) {
  final now = DateTime.now();
  final random = Random();

  // Adjust temperature with bias towards 19-24 range
  temp += (temp < 19)
      ? random.nextDouble() * 4 - 1 // Increase if below 19
      : (temp > 24)
          ? random.nextDouble() * 4 - 3 // Decrease if above 24
          : random.nextDouble() * 2 - 1; // Small change if within range

  // Adjust humidity with bias towards 0.35-0.45 range
  humidityValue += (humidityValue < 0.35)
      ? random.nextDouble() * 0.02 - 0.005 // Increase if below 0.35
      : (humidityValue > 0.45)
          ? random.nextDouble() * 0.02 - 0.015 // Decrease if above 0.45
          : random.nextDouble() * 0.01 - 0.005; // Small change if within range

  // Clamp to ensure values stay within the absolute limits
  temp = temp.clamp(15, 30);
  humidityValue = humidityValue.clamp(0.2, 0.6);

  return ClimateData(
    temperature: temp,
    humidity: humidityValue,
    timestamp: now.millisecondsSinceEpoch,
  );
}
