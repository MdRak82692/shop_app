import '../../../../components/button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/slider_bar.dart';
import 'staff_salary_management_screen.dart';

class AddStaffSalaryScreen extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AddStaffSalaryScreen({super.key});

  @override
  State<AddStaffSalaryScreen> createState() => _AddStaffSalaryScreenState();
}

class _AddStaffSalaryScreenState extends State<AddStaffSalaryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController salaryCtrl = TextEditingController();

  String? selectedStaff;

  List<Map<String, dynamic>> staffList = [];
  List<String> excludedStaffNames = [];
  bool isLoading = false;
  FetchInformation? fetchInformation;

  @override
  void initState() {
    super.initState();
    fetchInformation = FetchInformation(
      firestore: firestore,
      setState: setState,
    );

    fetchInformation!.fetchStaffData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: Colors.black.withAlpha(50),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AddEditTitleSection(
                            title: 'Add Staff Salary Details'),
                        const SizedBox(height: 40),
                        DropDownButton(
                          label: 'Staff Name',
                          items: fetchInformation!.staffList
                              .map((staff) => staff['name'] as String)
                              .toList(),
                          selectedItem: selectedStaff,
                          icon: Icons.person,
                          onChanged: (value) {
                            setState(() {
                              selectedStaff = value;
                            });
                          },
                        ),
                        InputField(
                          controller: salaryCtrl,
                          label: 'Salary',
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          onPressed: () async {
                            String staffName = selectedStaff ?? '';
                            double salaryAmount =
                                double.tryParse(salaryCtrl.text) ?? 0.0;

                            await addInformation(
                              context: context,
                              targetWidget: const StaffSalaryManagementScreen(),
                              controllers: {
                                'staffName': staffName,
                                'salaryAmount': salaryAmount,
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'staffsalaryinformation',
                              fieldsToSubmit: ['staffName', 'salaryAmount'],
                              addTimestamp: false,
                            );
                          },
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
