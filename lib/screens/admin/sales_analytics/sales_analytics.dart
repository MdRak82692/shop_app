import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/sale_title.dart';
import '../../../utils/sale_chart.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/title_section.dart';

class SalesAnalytics extends StatefulWidget {
  const SalesAnalytics({super.key});

  @override
  SalesAnalyticsState createState() => SalesAnalyticsState();
}

class SalesAnalyticsState extends State<SalesAnalytics> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 15),
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
                const TitleSection(title: 'Sale Analytics', addIcon: false),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        const SaleTitle(title: 'Investment'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1100,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Investment Vs Day",
                                    "investment",
                                    "time",
                                    "sale",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Investment Vs Month",
                                    "investment",
                                    "time",
                                    "sale",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Investment vs Year",
                                    "investment",
                                    "time",
                                    "sale",
                                    "year",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Other Cost'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1100,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Other Cost Vs Day",
                                    "otherCost",
                                    "time",
                                    "cost",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Other Cost Vs Month",
                                    "otherCost",
                                    "time",
                                    "cost",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Other Cost Vs Year",
                                    "otherCost",
                                    "time",
                                    "cost",
                                    "year",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Product Cost'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1100,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Product Cost vs Day",
                                    "products",
                                    "time",
                                    "cost",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Product Cost vs Month",
                                    "products",
                                    "time",
                                    "cost",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Product Cost vs Year",
                                    "products",
                                    "time",
                                    "cost",
                                    "year",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Products Sale'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1100,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Product Sales Vs Day",
                                    "sales",
                                    "time",
                                    "sale",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Product Sales Vs Month",
                                    "sales",
                                    "time",
                                    "sale",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Product Sales vs Year",
                                    "sales",
                                    "time",
                                    "sale",
                                    "year",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Staff Salary'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1100,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Staff Salary Vs Day",
                                    "staffsalary",
                                    "time",
                                    "salary",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Staff Salary Vs Month",
                                    "staffsalary",
                                    "time",
                                    "salary",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Staff Salary vs Year",
                                    "staffsalary",
                                    "time",
                                    "salary",
                                    "year",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
