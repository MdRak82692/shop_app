import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'other_cost_management_screen.dart';

class EditOtherCostScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditOtherCostScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditOtherCostScreenState createState() => EditOtherCostScreenState();
}

class EditOtherCostScreenState extends State<EditOtherCostScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'recipientName': nameCtrl,
      'cost': amountCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'otherCost',
      fieldsToSubmit: ['recipientName', 'cost'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withAlpha(50),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddEditTitleSection(
                          title: 'Update Other Cost Information',
                          targetWidget: () => const OtherCostManagementScreen(),
                        ),
                        const SizedBox(height: 40),
                        InputField(
                            controller: nameCtrl,
                            label: "Recipient Name",
                            icon: Icons.person),
                        InputField(
                            controller: amountCtrl,
                            label: "Amount",
                            icon: Icons.attach_money),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget: const OtherCostManagementScreen(),
                              controllers: {
                                'recipientName': nameCtrl.text,
                                'cost':
                                    double.tryParse(amountCtrl.text) ?? 0.00,
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'otherCost',
                              fieldsToSubmit: ['recipientName', 'cost'],
                              addTimestamp: true,
                            );
                          },
                          isLoading: isLoading,
                        )
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
