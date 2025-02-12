import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import 'other_cost_management_screen.dart';

class AddOtherCostScreen extends StatefulWidget {
  const AddOtherCostScreen({super.key});

  @override
  AddOtherCostScreentate createState() => AddOtherCostScreentate();
}

class AddOtherCostScreentate extends State<AddOtherCostScreen> {
  final firestore = FirebaseFirestore.instance;
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  bool isLoading = false;

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
                        const AddEditTitleSection(
                            title: 'Add Other Cost Information'),
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
                            await addInformation(
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
