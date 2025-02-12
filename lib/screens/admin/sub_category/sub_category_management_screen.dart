import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_sub_category_screen.dart';
import '../../../utils/search.dart';
import 'add_sub_category_screen.dart';

class SubCategoryManagementScreen extends StatefulWidget {
  const SubCategoryManagementScreen({super.key});

  @override
  SubCategoryManagementScreenState createState() =>
      SubCategoryManagementScreenState();
}

class SubCategoryManagementScreenState
    extends State<SubCategoryManagementScreen> {
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
          const BuildSidebar(selectedIndex: 5),
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
                  title: 'Sub-Category',
                  targetWidget: AddSubCategoryScreen(),
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
                          collectionName: 'subCategory',
                          columnNames: const [
                            'Sub Category ID',
                            'Sub Category Name',
                          ],
                          columnFieldMapping: const {
                            'Sub Category ID': 'id',
                            'Sub Category Name': 'subCategory',
                          },
                          targetWidget: (userId, userData) {
                            return EditSubCategoryScreen(
                                userId: userId, userData: userData);
                          },
                          fieldName: 'category',
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
