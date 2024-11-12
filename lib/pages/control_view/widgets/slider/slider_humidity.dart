import 'package:flutter/material.dart';
import 'package:house_matters/pages/control_view/widgets/slider/custom_arc.dart';
import 'package:house_matters/utils/slider_utils.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SliderHumidity extends StatelessWidget {
  final double progressVal;
  final Color color;
  final double minValue = 0;
  final double maxValue = 100;
  final double humidityAngleRange = 360;

  const SliderHumidity({
    Key? key,
    required this.progressVal,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Progress val: $progressVal');
    return SizedBox(
      width: kDiameter + 35,
      height: kDiameter + 35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: kDiameter + 35,
            height: kDiameter + 35,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Center(
            child: CustomArc(
              color: color,
              diameter: kDiameter,
              sweepAngle: progressVal,
              maxAngle: humidityAngleRange,
            ),
          ),
          Center(
            child: Container(
              width: kDiameter - 20,
              height: kDiameter - 20,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 15,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: SleekCircularSlider(
                min: minValue,
                max: 100,
                initialValue: progressVal * 100,
                appearance: CircularSliderAppearance(
                  spinnerMode: false,
                  startAngle: 180,
                  angleRange: humidityAngleRange,
                  size: kDiameter - 30,
                  customWidths: CustomSliderWidths(
                    trackWidth: 20,
                    shadowWidth: 0,
                    progressBarWidth: 01,
                    handlerSize: 5,
                  ),
                  infoProperties: InfoProperties(bottomLabelText: 'Humidity'),
                  customColors: CustomSliderColors(
                    hideShadow: true,
                    progressBarColor: Colors.transparent,
                    trackColor: Colors.transparent,
                    dotColor: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
