import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'text.dart';
import 'chart_other_part.dart';
import 'loading_display.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getChartData(String groupBy,
    {String? selectedMonth, String? selectedYear}) async {
  List<Map<String, dynamic>> chartData = [];

  int filterYear =
      selectedYear != null ? int.parse(selectedYear) : DateTime.now().year;
  int filterMonth = selectedMonth != null
      ? months.indexOf(selectedMonth) + 1
      : DateTime.now().month;

  var orderSnapshot = await firestore.collection("sales").get();
  var investmentSnapshot = await firestore.collection("investment").get();
  var otherCostSnapshot = await firestore.collection("otherCost").get();
  var productSnapshot = await firestore.collection("products").get();
  var salarySnapshot = await firestore.collection("staffsalary").get();

  void processData(QuerySnapshot snapshot, String timeField, String valueField,
      bool isNegative) {
    for (var doc in snapshot.docs) {
      DateTime time = (doc[timeField] as Timestamp).toDate();
      double value = (doc[valueField] as num?)?.toDouble() ?? 0.0;

      if (isNegative) value = -value;

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
  }

  processData(investmentSnapshot, "time", "sale", false);
  processData(orderSnapshot, "time", "sale", false);
  processData(otherCostSnapshot, "time", "cost", true);
  processData(productSnapshot, "time", "cost", true);
  processData(salarySnapshot, "time", "salary", true);

  if (groupBy == 'day') {
    chartData = chartData
        .where((entry) =>
            entry['date'] != null &&
            int.tryParse(entry['date']) != null &&
            int.parse(entry['date']) >= 1 &&
            int.parse(entry['date']) <= 31)
        .toList();
  } else if (groupBy == 'month') {
    chartData = chartData
        .where(
            (entry) => entry['date'] != null && months.contains(entry['date']))
        .toList();
  } else if (groupBy == 'year') {
    chartData = chartData
        .where((entry) =>
            entry['date'] != null &&
            int.tryParse(entry['date']) != null &&
            int.parse(entry['date']) == filterYear)
        .toList();
  }

  return chartData.isNotEmpty ? chartData : [];
}

Widget buildBarChart(BuildContext context, String groupBy,
    {String? selectedMonth, String? selectedYear}) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getChartData(groupBy,
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
        double maxValue = snapshot.data!.isNotEmpty
            ? snapshot.data!
                .map((e) => e['value'] as double)
                .reduce((a, b) => a > b ? a : b)
            : 0.0;

        double minValue = snapshot.data!.isNotEmpty
            ? snapshot.data!
                .map((e) => e['value'] as double)
                .reduce((a, b) => a < b ? a : b)
            : 0.0;

        double xAxisMin =
            minValue < 0 ? (minValue / 2000).floor() * 2000 - 2000 : 0.0;

        double xAxisMax = (maxValue / 2000).ceil() * 2000 + 2000;

        if (xAxisMin >= xAxisMax) {
          xAxisMin = xAxisMax - 2000;
        }

        List<BarChartGroupData> barChartData =
            generateBarChartData(snapshot.data!, groupBy, xAxisMax, xAxisMin);

        List<String> yAxisLabels = [];
        for (double i = xAxisMin; i <= xAxisMax; i += 2000) {
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
                          reservedSize: 70,
                          getTitlesWidget: (value, meta) {
                            int index = ((value - xAxisMin) / 2000).toInt();
                            if (index >= 0 && index < yAxisLabels.length) {
                              return Text(
                                yAxisLabels[index],
                                style: style(14, color: Colors.black54),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            if (groupBy == 'month') {
                              return Text(
                                getMonthName(value.toInt()),
                                style: style(14, color: Colors.blueAccent),
                              );
                            } else if (groupBy == 'year') {
                              return Text(
                                value.toInt().toString(),
                                style: style(14, color: Colors.greenAccent),
                              );
                            } else {
                              return Text(
                                value.toInt().toString(),
                                style: style(14, color: Colors.redAccent),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                    barGroups: barChartData,
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % 2000 == 0,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: Colors.black12,
                        strokeWidth: 1,
                      ),
                    ),
                    maxY: xAxisMax,
                    minY: xAxisMin,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}',
                            style(12, color: Colors.white),
                          );
                        },
                      ),
                    ),
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

List<BarChartGroupData> generateBarChartData(List<Map<String, dynamic>> data,
    String groupBy, dynamic xAxisMax, dynamic xAxisMin) {
  List<BarChartGroupData> barChartData = [];
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  if (groupBy == 'day') {
    int daysInMonth = getDaysInMonth(currentMonth, currentYear);
    for (int i = 1; i <= daysInMonth; i++) {
      double value = data
          .firstWhere(
            (element) => element['date'] == i.toString(),
            orElse: () => {'value': 0},
          )['value']
          .toDouble();

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.isFinite ? value : 0.0,
              borderRadius: BorderRadius.circular(4),
              width: 16,
              color: value >= 0 ? Colors.greenAccent : Colors.redAccent,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: xAxisMax,
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
  } else if (groupBy == 'month') {
    for (int i = 1; i <= 12; i++) {
      double value = data
          .firstWhere(
            (element) => element['date'] == getMonthName(i),
            orElse: () => {'value': 0},
          )['value']
          .toDouble();

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.isFinite ? value : 0.0,
              borderRadius: BorderRadius.circular(4),
              width: 16,
              color: value >= 0 ? Colors.greenAccent : Colors.redAccent,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: xAxisMax,
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
  } else if (groupBy == 'year') {
    for (int i = currentYear; i <= currentYear; i++) {
      double value = data
          .firstWhere(
            (element) => element['date'] == i.toString(),
            orElse: () => {'value': 0},
          )['value']
          .toDouble();

      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.isFinite ? value : 0.0,
              borderRadius: BorderRadius.circular(4),
              width: 16,
              color: value >= 0 ? Colors.greenAccent : Colors.redAccent,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: xAxisMax,
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
  }
  return barChartData;
}
