import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_investment_screen.dart';
import '../../../utils/search.dart';
import 'add_investment_screen.dart';

class InvestmentManagementScreen extends StatefulWidget {
  const InvestmentManagementScreen({super.key});

  @override
  InvestmentManagementScreenState createState() =>
      InvestmentManagementScreenState();
}

class InvestmentManagementScreenState
    extends State<InvestmentManagementScreen> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value),
                ),
                const TitleSection(
                  title: 'Investment',
                  targetWidget: AddInvestmentScreen(),
                  addIcon: true,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DynamicDataTable(
                          searchQuery: searchQuery,
                          collectionName: 'investment',
                          columnNames: const [
                            'Investment ID',
                            'Inverstor Name',
                            'Amount',
                            'Time'
                          ],
                          columnFieldMapping: const {
                            'Investment ID': 'id',
                            'Inverstor Name': 'inverstorName',
                            'Amount': 'sale',
                            'Time': 'time',
                          },
                          targetWidget: (userId, userData) {
                            return EditInvestmentScreen(
                                userId: userId, userData: userData);
                          },
                          fieldName: 'time',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
