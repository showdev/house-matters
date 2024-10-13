import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:house_matters/pages/control_view/options_enum.dart';
import 'package:house_matters/pages/control_view/widgets/slider/slider_humidity.dart';
import 'package:house_matters/pages/control_view/widgets/slider/slider_widget.dart';
import 'package:house_matters/utils/slider_utils.dart';
import 'package:house_matters/widgets/custom_appbar.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';

class ClimateControlePanePage extends StatefulWidget {
  final String tag;
  final Color color;

  const ClimateControlePanePage(
      {Key? key, required this.tag, required this.color})
      : super(key: key);
  @override
  _ClimateControlePanePageState createState() =>
      _ClimateControlePanePageState();
}

class _ClimateControlePanePageState extends State<ClimateControlePanePage>
    with TickerProviderStateMixin {
  late List<ClimateSensorData> dynamicChartData;
  late ChartSeriesController _tempSeriesController;
  late ChartSeriesController _humiditySeriesController;

  List<ClimateSensorData> staticChartData = generateClimateData();

  Options option = Options.cooling;
  bool isActive = true;
  bool showDynamic = false;
  int speed = 1;
  double temp = 22.85;
  double humidityValue = 0.45;
  double progressVal = 0.49;
  Timer? _timer;

  var activeColor = Rainbow(spectrum: [
    const Color(0xFF33C0BA),
    const Color(0xFF1086D4),
    const Color(0xFF6D04E2),
    const Color(0xFFC421A0),
    const Color(0xFFE4262F)
  ], rangeStart: 0.0, rangeEnd: 1.0);

  var humidityColor = Rainbow(spectrum: [
    const Color(0xFF33C0BA),
    const Color(0xFF1086D4),
    const Color.fromARGB(255, 16, 84, 212),
    const Color.fromARGB(255, 16, 68, 212),
    const Color.fromARGB(255, 4, 8, 226),
  ], rangeStart: 0.0, rangeEnd: 1.0);

  @override
  void initState() {
    super.initState();
    dynamicChartData = <ClimateSensorData>[
      ClimateSensorData(
          DateTime.now().millisecondsSinceEpoch, temp, humidityValue),
    ];

    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   if (!showDynamic) return;
    //   setState(() {
    //     dynamicChartData.add(ClimateSensorData(
    //         DateTime.now().millisecondsSinceEpoch, temp, humidityValue));
    //     _tempSeriesController.updateDataSource(
    //       addedDataIndexes: <int>[dynamicChartData.length - 1],
    //     );
    //     // Remove older data points to keep only the last 10 minutes
    //     if (dynamicChartData.length > 10) {
    //       dynamicChartData.removeAt(0);
    //       _tempSeriesController.updateDataSource(
    //         removedDataIndexes: <int>[0],
    //       );
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white,
                activeColor[progressVal].withOpacity(0.5),
                activeColor[progressVal]
              ]),
        ),
        child: AnimatedBackground(
          behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
            baseColor: const Color(0xFFFFFFFF),
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.3,
            spawnMinSpeed: 1 * 60.0,
            spawnMaxSpeed: 1 * 120,
            spawnMinRadius: 2.0,
            spawnMaxRadius: 5.0,
            particleCount: ((humidityValue - 0.2) / 0.45 * 200 + 50).toInt(),
          )),
          vsync: this,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Column(
                children: [
                  CustomAppBar(title: widget.tag),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text('Room: Living Room'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            temperature(),
                            humidity(),
                          ],
                        ),
                        dynamicGraphToggle(context),
                        showDynamic ? buildDynamicChart() : graph()
                      ]))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget temperature() {
    return SliderWidget(
      progressVal: progressVal,
      color: activeColor[progressVal],
      onChange: (value) {
        setState(() {
          temp = value;
          progressVal = normalize(value, kMinDegree, kMaxDegree);

          if (!showDynamic) return;
          dynamicChartData.add(ClimateSensorData(
              DateTime.now().millisecondsSinceEpoch, value, humidityValue));
          _tempSeriesController.updateDataSource(
            addedDataIndexes: <int>[dynamicChartData.length - 1],
          );
        });
      },
    );
  }

  Widget humidity() {
    return SliderHumidity(
      progressVal: humidityValue,
      color: humidityColor[humidityValue],
      onChange: (value) {
        setState(() {
          humidityValue = value / 100;
          if (!showDynamic) return;
          dynamicChartData.add(ClimateSensorData(
              DateTime.now().millisecondsSinceEpoch, temp, value));
          _humiditySeriesController.updateDataSource(
            addedDataIndexes: <int>[dynamicChartData.length - 1],
          );
        });
      },
    );
  }

  Widget graph() {
    return Container(
      color: Colors.grey[200]?.withOpacity(0.8),
      child: SfCartesianChart(
          title: ChartTitle(text: 'Recent measurements'),
          primaryXAxis: CategoryAxis(
            // maximumLabels: 5,
            visibleMinimum: 0, // Index of the first data point to show
            visibleMaximum: 5,
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          series: <LineSeries<ClimateSensorData, String>>[
            LineSeries<ClimateSensorData, String>(
                // Bind data source
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                legendItemText: 'humidity, %',
                dataSource: staticChartData,
                xValueMapper: (ClimateSensorData data, _) =>
                    timestampToHHmm(data.timestamp),
                // DateTime.fromMillisecondsSinceEpoch(data.timestamp),
                yValueMapper: (ClimateSensorData data, _) =>
                    (data.humidity * 100).toInt()),
            LineSeries<ClimateSensorData, String>(
                // Bind data source
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                legendItemText: 'temperature, °C',
                dataSource: staticChartData,
                xValueMapper: (ClimateSensorData data, _) =>
                    timestampToHHmm(data.timestamp),
                // DateTime.fromMillisecondsSinceEpoch(data.timestamp),
                yValueMapper: (ClimateSensorData data, _) => data.temp.toInt()),
          ]),
    );
  }

  Widget dynamicGraphToggle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the toggle
      children: [
        const Text('Show Realtime Data'), // Label

        Transform.scale(
          alignment: Alignment.center,
          scaleY: 0.8,
          scaleX: 0.85,
          child: CupertinoSwitch(
            onChanged: (value) {
              setState(() {
                showDynamic = value;
              });
            },
            value: showDynamic,
            activeColor:
                showDynamic ? Colors.white.withOpacity(0.4) : Colors.black,
            trackColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildDynamicChart() {
    return Container(
        color: Colors.grey[200]?.withOpacity(0.8),
        child: SfCartesianChart(
          series: <LineSeries<ClimateSensorData, DateTime>>[
            LineSeries<ClimateSensorData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _humiditySeriesController = controller;
              },
              dataSource: dynamicChartData,
              xValueMapper: (ClimateSensorData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.timestamp),
              yValueMapper: (ClimateSensorData data, _) => data.humidity,
            ),
            LineSeries<ClimateSensorData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _tempSeriesController = controller;
              },
              dataSource: dynamicChartData,
              xValueMapper: (ClimateSensorData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.timestamp),
              yValueMapper: (ClimateSensorData data, _) => data.temp,
            ),
          ],
          primaryXAxis: DateTimeAxis(
            majorGridLines: const MajorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
          ),
        ));
  }
}

class ClimateSensorData {
  ClimateSensorData(
    this.timestamp,
    this.temp,
    this.humidity,
  );
  final double temp;
  final double humidity;
  final int timestamp;
}

List<ClimateSensorData> generateClimateData() {
  List<ClimateSensorData> data = [];
  DateTime now = DateTime.now();
  Random random = Random();

  double temp = 20;
  double humidity = 0.4;

  for (int i = 0; i <= 10; i++) {
    DateTime time = now.add(Duration(minutes: i));
    int timestamp = time.millisecondsSinceEpoch;

    temp += random.nextDouble() * 10 - 5; // Can vary by +/- 5 degrees

    // Vary humidity with a trend and some noise
    humidity += (random.nextDouble() - 0.3) *
        0.1; // General upward trend with variation

    // Keep values within reasonable ranges
    temp = temp.clamp(16, 30);
    humidity = humidity.clamp(0.2, 0.6);

    data.add(ClimateSensorData(timestamp, temp, humidity));
  }

  return data;
}

String timestampToHHmm(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String formattedTime = DateFormat('HH:mm').format(dateTime);
  return formattedTime;
}
