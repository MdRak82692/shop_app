import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data_table/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/search.dart';
import 'add_staff_salary_screen.dart';
import 'edit_staff_salary_screen.dart';

class StaffSalaryManagementScreen extends StatefulWidget {
  const StaffSalaryManagementScreen({super.key});

  @override
  StaffSalaryManagementScreenState createState() =>
      StaffSalaryManagementScreenState();
}

class StaffSalaryManagementScreenState
    extends State<StaffSalaryManagementScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 13),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value),
                ),
                TitleSection(
                  title: 'Staff Salary',
                  targetWidget: AddStaffSalaryScreen(),
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
                          collectionName: 'staffsalaryinformation',
                          columnNames: const [
                            'Salary ID',
                            'Staff Name ',
                            'Salary Amount',
                            'Payment Status'
                          ],
                          columnFieldMapping: const {
                            'Salary ID': 'id',
                            'Staff Name ': 'staffName',
                            'Salary Amount': 'salaryAmount',
                          },
                          targetWidget: (userId, userData) {
                            return EditStaffSalaryScreen(
                                salaryId: userId, staffData: userData);
                          },
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
