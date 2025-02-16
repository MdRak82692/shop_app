import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'staff_salary_management_screen.dart';

class EditStaffSalaryScreen extends StatefulWidget {
  final String salaryId;
  final Map<String, dynamic> staffData;

  const EditStaffSalaryScreen(
      {super.key, required this.salaryId, required this.staffData});

  @override
  EditStaffSalaryScreenState createState() => EditStaffSalaryScreenState();
}

class EditStaffSalaryScreenState extends State<EditStaffSalaryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController staffNameCtrl = TextEditingController();
  final TextEditingController salaryCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'staffName': staffNameCtrl,
      'salaryAmount': salaryCtrl,
    };

    loadInformation(
      id: widget.salaryId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'staffsalaryinformation',
      fieldsToSubmit: ['staffName', 'salaryAmount'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 13),
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
                          AddEditTitleSection(
                            title: 'Edit Staff Salary Details',
                            targetWidget: () =>
                                const StaffSalaryManagementScreen(),
                          ),
                          const SizedBox(height: 30),
                          InputField(
                            controller: staffNameCtrl,
                            label: 'Staff Name',
                            icon: Icons.person,
                            readOnly: true,
                          ),
                          InputField(
                            controller: salaryCtrl,
                            label: 'Salary',
                            icon: Icons.attach_money,
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            onPressed: () async {
                              String staffName = staffNameCtrl.text;
                              double salaryAmount =
                                  double.tryParse(salaryCtrl.text) ?? 0.0;

                              await updateInformation(
                                context: context,
                                targetWidget:
                                    const StaffSalaryManagementScreen(),
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
                                userId: widget.salaryId,
                              );
                            },
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
