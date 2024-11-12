import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_matters/models/climate_data.dart';
import 'package:house_matters/utils/data_generator.dart';

class SensorDataProvider with ChangeNotifier {
  final _controller = StreamController<ClimateData>.broadcast();
  Stream<ClimateData> get climateDataStream => _controller.stream;

  Timer? _timer;

  SensorDataProvider() {
    _startGeneratingData();
  }

  void _startGeneratingData() {
    double temp = 23;
    double humidity = 0.4;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final climateData = generateClimateDataEntry(temp, humidity);
      _controller.add(climateData);
      notifyListeners(); // Notify listeners about new data
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the provider is disposed
    _controller.close();
    super.dispose();
  }
}
