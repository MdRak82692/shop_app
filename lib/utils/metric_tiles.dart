import 'package:flutter/material.dart';
import 'text.dart';

List<Widget> buildMetricTiles(Map<String, double> metrics) {
  final metricDetails = [
    {
      'title': 'Total Users',
      'value': metrics['totalUsers'] ?? 0.0,
      'color': Colors.blueAccent,
      'icon': Icons.people
    },
    {
      'title': 'Total Staff',
      'value': metrics['totalStaff'] ?? 0.0,
      'color': Colors.green,
      'icon': Icons.work
    },
    {
      'title': 'Today\'s Investment',
      'value': metrics['dailyInvestment'] ?? 0.0,
      'color': Colors.orange,
      'icon': Icons.trending_up
    },
    {
      'title': 'Today\'s Other Cost',
      'value': metrics['dailyOtherCost'] ?? 0.0,
      'color': Colors.red,
      'icon': Icons.money_off
    },
    {
      'title': 'Today\'s Product Cost',
      'value': metrics['dailyCost'] ?? 0.0,
      'color': Colors.purple,
      'icon': Icons.shopping_cart
    },
    {
      'title': 'Today\'s Product Sale',
      'value': metrics['dailySale'] ?? 0.0,
      'color': Colors.teal,
      'icon': Icons.store
    },
    {
      'title': 'Today\'s Staff Salary',
      'value': metrics['dailyStaffSalary'] ?? 0.0,
      'color': Colors.indigo,
      'icon': Icons.account_balance_wallet
    },
    {
      'title': 'Today\'s Profit',
      'value': metrics['dailyProfit'] ?? 0.0,
      'color': Colors.lightGreen,
      'icon': Icons.show_chart
    },
    {
      'title': 'Total Investment',
      'value': metrics['totalInvestment'] ?? 0.0,
      'color': Colors.deepOrange,
      'icon': Icons.business
    },
    {
      'title': 'Total Other Cost',
      'value': metrics['totalOtherCost'] ?? 0.0,
      'color': Colors.pink,
      'icon': Icons.receipt
    },
    {
      'title': 'Total Product Cost',
      'value': metrics['totalCost'] ?? 0.0,
      'color': Colors.cyan,
      'icon': Icons.shopping_cart
    },
    {
      'title': 'Total Product Sale',
      'value': metrics['totalSale'] ?? 0.0,
      'color': Colors.amber,
      'icon': Icons.store
    },
    {
      'title': 'Total Staff Salary',
      'value': metrics['totalStaffSalary'] ?? 0.0,
      'color': Colors.deepPurple,
      'icon': Icons.account_balance_wallet
    },
    {
      'title': 'Total Profit',
      'value': metrics['totalProfit'] ?? 0.0,
      'color': Colors.lightBlue,
      'icon': Icons.equalizer
    },
  ];

  return metricDetails
      .map(
        (metric) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 200,
            minHeight: 150,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (metric['color'] as Color).withAlpha(204),
                (metric['color'] as Color).withAlpha(102),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(51),
                  radius: 24,
                  child: Icon(
                    metric['icon'] as IconData? ?? Icons.help_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Center(
                    child: Text(
                      metric['title'] as String,
                      textAlign: TextAlign.center,
                      style: style(16, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (metric['value'] as double).toStringAsFixed(2),
                  style: style(20, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      )
      .toList();
}
