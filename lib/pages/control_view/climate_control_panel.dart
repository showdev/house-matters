import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:house_matters/pages/control_view/options_enum.dart';
import 'package:house_matters/pages/control_view/widgets/slider/slider_humidity.dart';
import 'package:house_matters/pages/control_view/widgets/slider/slider_widget.dart';
import 'package:house_matters/providers/sensor_data_provider.dart';
import 'package:house_matters/utils/slider_utils.dart';
import 'package:house_matters/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';
import 'package:house_matters/models/climate_data.dart';
import 'package:house_matters/providers/database_helper.dart';

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
  late List<ClimateData> dynamicChartData;
  List<ClimateData> climateDataList = [];
  List<ClimateData> staticChartData = [];
  late ChartSeriesController _tempSeriesController;
  late ChartSeriesController _humiditySeriesController;

  Options option = Options.cooling;
  bool isActive = true;
  bool showDynamic = true;
  int speed = 1;
  late double temp = 22.85;
  late double humidityValue = 0.45;
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
    _loadClimateData();
    dynamicChartData = [];
    // Replace timer with WebSocket connection
    final sensorDataProvider =
        Provider.of<SensorDataProvider>(context, listen: false);

    sensorDataProvider.climateDataStream.listen((data) {
      setState(() {
        temp = data.temperature;
        humidityValue = data.humidity;

        dynamicChartData.add(data);
        _tempSeriesController.updateDataSource(
          addedDataIndexes: <int>[dynamicChartData.length - 1],
        );
        _humiditySeriesController.updateDataSource(
          addedDataIndexes: <int>[dynamicChartData.length - 1],
        );

        if (dynamicChartData.length > 10) {
          dynamicChartData.removeAt(0);
          _humiditySeriesController.updateDataSource(
            removedDataIndexes: <int>[0],
          );
          _tempSeriesController.updateDataSource(
            removedDataIndexes: <int>[0],
          );
        }
      });
    });
  }

  Future<void> _loadClimateData() async {
    final dbHelper = DatabaseHelper.instance;
    final allRows = await dbHelper.queryAllRows();
    setState(() {
      climateDataList = allRows.map((row) => ClimateData.fromMap(row)).toList();
    });
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
    progressVal = normalize(temp, kMinDegree, kMaxDegree);
    return SliderWidget(
      progressVal: progressVal,
      color: activeColor[progressVal],
    );
  }

  Widget humidity() {
    return SliderHumidity(
      progressVal: humidityValue,
      color: humidityColor[humidityValue],
    );
  }

  Widget graph() {
    return Container(
      color: Colors.grey[200]?.withOpacity(0.8),
      child: SfCartesianChart(
          title: ChartTitle(text: 'Recent measurements'),
          primaryXAxis: CategoryAxis(
            visibleMinimum: 0,
            visibleMaximum: 9, // Show 10 data points (index 0 to 9)
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Enable horizontal panning
            zoomMode: ZoomMode.x, // Allow zooming only on the x-axis
          ),
          series: <LineSeries<ClimateData, String>>[
            LineSeries<ClimateData, String>(
                // Bind data source
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                legendItemText: 'humidity, %',
                dataSource: climateDataList,
                xValueMapper: (ClimateData data, _) =>
                    timestampToHHmm(data.timestamp),
                // DateTime.fromMillisecondsSinceEpoch(data.timestamp),
                yValueMapper: (ClimateData data, _) =>
                    (data.humidity * 100).toInt()),
            LineSeries<ClimateData, String>(
                // Bind data source
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
                legendItemText: 'temperature, °C',
                dataSource: climateDataList,
                xValueMapper: (ClimateData data, _) =>
                    timestampToHHmm(data.timestamp),
                // DateTime.fromMillisecondsSinceEpoch(data.timestamp),
                yValueMapper: (ClimateData data, _) =>
                    data.temperature.toInt()),
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
          series: <LineSeries<ClimateData, DateTime>>[
            LineSeries<ClimateData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _humiditySeriesController = controller;
              },
              dataSource: dynamicChartData,
              xValueMapper: (ClimateData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.timestamp),
              yValueMapper: (ClimateData data, _) => data.humidity * 100,
            ),
            LineSeries<ClimateData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _tempSeriesController = controller;
              },
              dataSource: dynamicChartData,
              xValueMapper: (ClimateData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.timestamp),
              yValueMapper: (ClimateData data, _) => data.temperature,
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

String timestampToHHmm(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String formattedTime = DateFormat('HH:mm').format(dateTime);
  return formattedTime;
}
