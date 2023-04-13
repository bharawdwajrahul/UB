import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BarGraph extends StatefulWidget {
  BarGraph(this.averageElectricity,
      this.average,
      this.averageElectricityWeek,
      this.averageWeek,
      this.averageElectricityMonth,
      this.averageMonth);

   double averageElectricity;
   double average;
   double averageElectricityWeek;
   double averageWeek;
   double averageElectricityMonth;
   double averageMonth;
  @override
  State<StatefulWidget> createState() => BarGraphState();
}

class BarGraphState extends State<BarGraph> {

  late final double width = 10;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;
  double maxVal=0;
  @override
  void initState() {
    setState(() {
      List<double> value=[widget.averageElectricity,widget.average,widget.averageElectricityWeek,widget.averageWeek,
        widget.averageElectricityMonth,widget.averageMonth];
      value.remove(0.0);
      maxVal=(((value.reduce(max))/100).ceil()*100);
      print(maxVal);
    });
    super.initState();
    init();
  }

  Future<void> init() async {
    super.initState();
    final barGroup1 = makeGroupData(0, widget.averageElectricity,widget.average.toDouble());
    final barGroup2 = makeGroupData(1, widget.averageElectricityWeek,widget.averageWeek.toDouble());
    final barGroup3 = makeGroupData(2, widget.averageElectricityMonth,widget.averageMonth.toDouble());


    final items = [
      barGroup1,
      barGroup2,
      barGroup3,

    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return


      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(
                        0, 4), // changes position of shadow
                  ),
                ]),
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: BarChart(
              BarChartData(
                maxY: maxVal,
                barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.white,
                    ),
                    ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    margin: 20,
                    getTitles: (double value) {
                      switch (value.toInt()) {
                        case 0:
                          return 'Today';
                        case 1:
                          return 'week';
                        case 2:
                          return 'Month';
                        default:
                          return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: showingBarGroups,
              ),
            ),
          )
        ),
      );

  }

  BarChartGroupData makeGroupData(int x, double y1, double y2,) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [

      BarChartRodData(
        y: y1,
        colors: [Color(0xff845bef)],
        width: width,
      ),
      BarChartRodData(
        y: y2,
        colors: [Color(0xff13d38e)],
        width: width,
      ),

    ]);
  }
}
