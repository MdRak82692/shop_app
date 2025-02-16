import '../../../../components/button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'staff_management_screen.dart';

class EditStaffScreen extends StatefulWidget {
  final String staffId;
  final Map<String, dynamic> staffData;

  const EditStaffScreen(
      {super.key, required this.staffId, required this.staffData});

  @override
  EditStaffScreenState createState() => EditStaffScreenState();
}

class EditStaffScreenState extends State<EditStaffScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'staffName': firstNameCtrl,
      'mobileNumber': mobileCtrl,
      'address': addressCtrl,
    };

    loadInformation(
      id: widget.staffId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'staff',
      fieldsToSubmit: [
        'staffName',
        'mobileNumber',
        'address',
      ],
    );
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
                          AddEditTitleSection(
                            title: 'Update New Staff Information',
                            targetWidget: () => const StaffManagementScreen(),
                          ),
                          const SizedBox(height: 40),
                          InputField(
                            controller: firstNameCtrl,
                            label: "Staff First Name",
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
                              await updateInformation(
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
                                userId: widget.staffId,
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
