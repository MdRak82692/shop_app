import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/summary_card.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

Future<Map<String, double>> getTotalsByDate(
    String collection, String field, String dateField,
    {bool filterCompleted = false}) async {
  Map<String, double> totals = {};

  Query collectionQuery = firestore.collection(collection);

  var snapshot = await collectionQuery.get();

  for (var doc in snapshot.docs) {
    final rawDate = (doc[dateField] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(rawDate);
    double value = parseDouble(doc[field]);

    totals[formattedDate] = (totals[formattedDate] ?? 0.0) + value;
  }

  return totals;
}

class SalesDataWidget extends StatelessWidget {
  const SalesDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        getTotalsByDate('investment', 'sale', 'time'),
        getTotalsByDate('otherCost', 'cost', 'time'),
        getTotalsByDate('products', 'cost', 'time'),
        getTotalsByDate('sales', 'sale', 'time'),
        getTotalsByDate('staffsalary', 'salary', 'time'),
      ]).then((results) {
        return {
          'investment': results[0],
          'otherCost': results[1],
          'productCost': results[2],
          'productSale': results[3],
          'staffSalary': results[4],
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;
        final investmentTotals =
            data['investment']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;
        final otherCostTotals =
            data['otherCost']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;
        final productCostTotals =
            data['productCost']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final productSaleTotals =
            data['productSale']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final staffSalaryTotals =
            data['staffSalary']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final profitTotals = investmentTotals +
            productSaleTotals -
            otherCostTotals -
            productCostTotals -
            staffSalaryTotals;

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SummaryCard(
                    title: 'Total Investment',
                    value: double.tryParse(investmentTotals.toString()) ?? 0.0),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Total Other Cost',
                  value: double.tryParse(otherCostTotals.toString()) ?? 0.0,
                ),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Total Product Cost',
                  value: double.tryParse(productCostTotals.toString()) ?? 0.0,
                ),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Total Product Sale',
                  value: double.tryParse(productSaleTotals.toString()) ?? 0.0,
                ),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Total Staff Salary',
                  value: double.tryParse(staffSalaryTotals.toString()) ?? 0.0,
                ),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Profit',
                  value: double.tryParse(profitTotals.toString()) ?? 0.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
