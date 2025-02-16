import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/slider_bar.dart';
import 'staff_management_screen.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  AddStaffScreenState createState() => AddStaffScreenState();
}

class AddStaffScreenState extends State<AddStaffScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();

  bool isLoading = false;

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
                          AddEditTitleSection(
                            title: 'Add New Staff Information',
                            targetWidget: () => const StaffManagementScreen(),
                          ),
                          const SizedBox(height: 40),
                          InputField(
                            controller: firstNameCtrl,
                            label: "Staff Name",
                            icon: Icons.person,
                          ),
                          InputField(
                            controller: mobileCtrl,
                            label: "Contact Number",
                            icon: Icons.phone,
                          ),
                          InputField(
                            controller: addressCtrl,
                            label: "Staff Address",
                            icon: Icons.home,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: () async {
                              await addInformation(
                                context: context,
                                targetWidget: const StaffManagementScreen(),
                                controllers: {
                                  'staffName': firstNameCtrl.text,
                                  'mobileNumber': mobileCtrl.text,
                                  'address': addressCtrl.text,
                                },
                                name1: 'mobileNumber',
                                option1: 'mobileNumber',
                                firestore: firestore,
                                isLoading: isLoading,
                                setState: setState,
                                collectionName: 'staff',
                                fieldsToSubmit: [
                                  'staffName',
                                  'mobileNumber',
                                  'address',
                                ],
                                addTimestamp: false,
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
