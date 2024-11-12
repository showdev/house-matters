import 'package:flutter/material.dart';
import 'package:house_matters/pages/home/home_page.dart';
import 'package:house_matters/providers/sensor_data_provider.dart'; // Import your provider
import 'package:provider/provider.dart'; // Import the provider package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Add the ChangeNotifierProvider
      create: (context) =>
          SensorDataProvider(), // Create your provider instance
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'House Matters',
        theme: ThemeData(
            fontFamily: "Poppins",
            sliderTheme: const SliderThemeData(
              trackShape: RectangularSliderTrackShape(),
              trackHeight: 2.5,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 15.0),
            )),
        home: const HomePage(),
      ),
    );
  }
}
