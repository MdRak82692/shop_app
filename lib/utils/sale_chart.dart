import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_other_part.dart';
import 'loading_display.dart';
import 'text.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getChartData(
    String collection, String timeField, String valueField, String groupBy,
    {String? selectedMonth, String? selectedYear}) async {
  QuerySnapshot snapshot = await firestore.collection(collection).get();
  List<Map<String, dynamic>> chartData = [];

  int filterYear =
      selectedYear != null ? int.parse(selectedYear) : DateTime.now().year;
  int filterMonth = selectedMonth != null
      ? months.indexOf(selectedMonth) + 1
      : DateTime.now().month;

  for (var doc in snapshot.docs) {
    DateTime time = (doc[timeField] as Timestamp).toDate();
    double value = (doc[valueField] as num?)?.toDouble() ?? 0.0;

    if (value.isNaN || !value.isFinite) {
      continue;
    }

    String groupKey = "";
    bool isValidData = false;

    if (groupBy == 'day' &&
        time.year == filterYear &&
        time.month == filterMonth) {
      groupKey = time.day.toString();
      isValidData = true;
    } else if (groupBy == 'month' && time.year == filterYear) {
      groupKey = getMonthName(time.month);
      isValidData = true;
    } else if (groupBy == 'year') {
      groupKey = time.year.toString();
      isValidData = true;
    }

    if (isValidData) {
      var existingEntry = chartData.firstWhere(
          (entry) => entry['date'] == groupKey,
          orElse: () => {'date': groupKey, 'value': 0.0});

      if (existingEntry['value'] == 0.0) {
        chartData.add({'date': groupKey, 'value': value});
      } else {
        existingEntry['value'] += value;
      }
    }
  }

  return chartData.isNotEmpty ? chartData : [];
}

Widget buildBarChart(BuildContext context, String collection, String timeField,
    String valueField, String groupBy,
    {String? selectedMonth, String? selectedYear}) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getChartData(collection, timeField, valueField, groupBy,
        selectedMonth: selectedMonth, selectedYear: selectedYear),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: buildLoadingOverlay());
      } else if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Error: ${snapshot.error}',
                style: style(18, color: Colors.red),
              ),
            ],
          ),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'No data available',
                style: style(18, color: Colors.red),
              ),
            ],
          ),
        );
      } else {
        List<BarChartGroupData> barChartData =
            generateBarChartData(snapshot.data!, groupBy);

        double maxValue = barChartData.fold<double>(0, (prev, element) {
          double currentValue = element.barRods.first.toY;
          return currentValue > prev ? currentValue : prev;
        });

        double xAxisMax = (maxValue / 2000).ceil() * 2000;

        List<String> yAxisLabels = [];
        for (double i = 0; i <= xAxisMax; i += 2000) {
          yAxisLabels.add(i.toInt().toString());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            int index = ((value - 0) / 2000).toInt();
                            if (index >= 0 && index < yAxisLabels.length) {
                              return Text(
                                yAxisLabels[index],
                                style: style(14, color: Colors.black),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (groupBy == 'month') {
                              return Text(getMonthName(value.toInt()),
                                  style: style(14, color: Colors.blue));
                            } else if (groupBy == 'year') {
                              return Text(value.toInt().toString(),
                                  style: style(14, color: Colors.green));
                            } else {
                              return Text(value.toInt().toString(),
                                  style: style(14, color: Colors.red));
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: barChartData,
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % 2000 == 0,
                    ),
                    maxY: xAxisMax,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    },
  );
}

List<BarChartGroupData> generateBarChartData(
    List<Map<String, dynamic>> data, String groupBy) {
  List<BarChartGroupData> barChartData = [];
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  if (groupBy == 'day') {
    int daysInMonth = getDaysInMonth(currentMonth, currentYear);
    for (int i = 1; i <= daysInMonth; i++) {
      double value = data
          .firstWhere(
            (element) => element['date'] == i.toString(),
            orElse: () => {'value': 0.0},
          )['value']
          .toDouble();

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: value.isFinite ? value : 0.0, color: Colors.blue)
          ],
        ),
      );
    }
  } else if (groupBy == 'month') {
    for (int i = 1; i <= 12; i++) {
      double value = data
          .firstWhere(
            (element) => getMonthName(i) == element['date'],
            orElse: () => {'value': 0.0},
          )['value']
          .toDouble();

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: value.isFinite ? value : 0.0, color: Colors.green)
          ],
        ),
      );
    }
  } else if (groupBy == 'year') {
    for (var entry in data) {
      int year = int.tryParse(entry['date']) ?? 0;
      double value = (entry['value'] as num?)?.toDouble() ?? 0.0;

      barChartData.add(
        BarChartGroupData(
          x: year,
          barRods: [
            BarChartRodData(
                toY: value.isFinite ? value : 0.0, color: Colors.red)
          ],
        ),
      );
    }
  }

  return barChartData;
}
