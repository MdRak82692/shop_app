import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/exist_multiple_separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/search.dart';

class ExistingProductManagementScreen extends StatefulWidget {
  const ExistingProductManagementScreen({super.key});

  @override
  ExistingProductManagementScreenState createState() =>
      ExistingProductManagementScreenState();
}

class ExistingProductManagementScreenState
    extends State<ExistingProductManagementScreen> {
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
          const BuildSidebar(selectedIndex: 8),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value),
                ),
                const TitleSection(title: 'Existing Products', addIcon: false),
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
                          columnNames: const [
                            'Product ID',
                            'Product Name',
                            'Available Quantity'
                          ],
                          columnFieldMapping: const {
                            'Product ID': 'id',
                            'Product Name': 'productName',
                          },
                          groupByFields: const ['category', 'subCategory'],
                          collectionName: 'productList',
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
