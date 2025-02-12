import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/sale_title.dart';
import '../../../utils/profit_chart.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/title_section.dart';

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
                    child: Column(
                      children: [
                        const SaleTitle(title: 'Profit'),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 1200,
                              width: 1100,
                              child: Column(
                                children: [
                                  buildBarChart(
                                    context,
                                    "Profit Vs Day",
                                    "day",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Profit Vs Month",
                                    "month",
                                  ),
                                  buildBarChart(
                                    context,
                                    "Profit vs Year",
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
