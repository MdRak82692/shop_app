import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/chart_other_part.dart';
import '../../../utils/profit_chart.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/title_section.dart';
import '../../../utils/text.dart';

class Profit extends StatefulWidget {
  const Profit({super.key});

  @override
  ProfitState createState() => ProfitState();
}

class ProfitState extends State<Profit> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  String? selectedChartType;
  String? selectedTrendChart;
  String? selectedMonth;
  String? selectedYear;

  final List<String> chartTypes = [
    'Profit',
  ];

  final List<String> trendCharts = ['Day', 'Month', 'Year'];

  List<String> years = List.generate(
      21, (index) => (DateTime.now().year - 10 + index).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 16),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
                const TitleSection(title: 'Profit Analytics', addIcon: false),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdownSection(),
                          const SizedBox(height: 20),
                          if (selectedChartType != null &&
                              selectedTrendChart != null &&
                              (selectedTrendChart == 'Year' ||
                                  (selectedTrendChart == 'Month' &&
                                      selectedYear != null) ||
                                  (selectedTrendChart == 'Day' &&
                                      selectedMonth != null &&
                                      selectedYear != null)))
                            buildChartSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Chart Type',
          style: style(16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedChartType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          hint: Text("Select Chart Type",
              style: style(16, color: Colors.black54)),
          onChanged: (value) {
            setState(() {
              selectedChartType = value;
              selectedTrendChart = null;
              selectedMonth = null;
              selectedYear = null;
            });
          },
          items: chartTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: style(16, color: Colors.black87)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (selectedChartType != null) ...[
          Text(
            'Select Trend Chart',
            style: style(16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedTrendChart,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            hint: Text("Select Trend Chart",
                style: style(16, color: Colors.black54)),
            onChanged: (value) {
              setState(() {
                selectedTrendChart = value;
                selectedMonth = null;
                selectedYear = null;
              });
            },
            items: trendCharts.map((trend) {
              return DropdownMenuItem(
                value: trend,
                child: Text(trend, style: style(16, color: Colors.black87)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (selectedTrendChart == 'Month') ...[
            Text(
              'Select Year',
              style: style(16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              hint:
                  Text("Select Year", style: style(16, color: Colors.black54)),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year, style: style(16, color: Colors.black87)),
                );
              }).toList(),
            ),
          ],
          if (selectedTrendChart == 'Day') ...[
            Text(
              'Select Month',
              style: style(16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              hint:
                  Text("Select Month", style: style(16, color: Colors.black54)),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
              items: months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(month, style: style(16, color: Colors.black87)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (selectedMonth != null) ...[
              Text(
                'Select Year',
                style: style(16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                hint: Text("Select Year",
                    style: style(16, color: Colors.black54)),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year, style: style(16, color: Colors.black87)),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ],
    );
  }

  Widget buildChartSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                "$selectedChartType vs $selectedTrendChart",
                style: style(
                  20,
                  color: Colors.black87.withAlpha(180),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 400,
                width: 1100,
                child: buildBarChart(
                  context,
                  selectedTrendChart!.toLowerCase(),
                  selectedMonth: selectedMonth,
                  selectedYear: selectedYear,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
