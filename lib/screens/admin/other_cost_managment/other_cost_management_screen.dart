import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_other_cost_screen.dart';
import '../../../utils/search.dart';
import 'add_other_cost_screen.dart';

class OtherCostManagementScreen extends StatefulWidget {
  const OtherCostManagementScreen({super.key});

  @override
  OtherCostManagementScreennState createState() =>
      OtherCostManagementScreennState();
}

class OtherCostManagementScreennState extends State<OtherCostManagementScreen> {
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
          const BuildSidebar(selectedIndex: 3),
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
                  title: 'Other Cost',
                  targetWidget: AddOtherCostScreen(),
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
                          collectionName: 'otherCost',
                          columnNames: const [
                            'Other Cost ID',
                            'Recipient Name',
                            'Amount',
                            'Time'
                          ],
                          columnFieldMapping: const {
                            'Other Cost ID': 'id',
                            'Recipient Name': 'recipientName',
                            'Amount': 'cost',
                            'Time': 'time',
                          },
                          targetWidget: (userId, userData) {
                            return EditOtherCostScreen(
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
