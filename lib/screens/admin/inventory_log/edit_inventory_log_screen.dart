import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/fetch_information.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'inventory_log_management_screen.dart';

class EditInventoryLogScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditInventoryLogScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditInventoryLogScreenState createState() => EditInventoryLogScreenState();
}

class EditInventoryLogScreenState extends State<EditInventoryLogScreen> {
  final firestore = FirebaseFirestore.instance;
  final quantityCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final subCategoryCtrl = TextEditingController();
  final productNameCtrl = TextEditingController();

  List<String> logType = [
    'Loss',
    'Return',
    'Adjustment',
    'Wastage',
    'Donation',
    'Defective',
    'Other'
  ];

  String? selectedLogType;
  FetchInformation? fetchInformation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> controllers = {
      'quantity': quantityCtrl,
      'category': categoryCtrl,
      'productName': productNameCtrl,
      'subCategory': subCategoryCtrl,
    };

    selectedLogType = widget.userData['logType'];

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'inventoryLog',
      fieldsToSubmit: [
        'quantity',
        'category',
        'productName',
        'logType',
        'subCategory'
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 11),
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
                            title: 'Update Product Price Detail'),
                        const SizedBox(height: 40),
                        InputField(
                          controller: categoryCtrl,
                          label: 'Category',
                          icon: Icons.category,
                          readOnly: true,
                        ),
                        InputField(
                          controller: subCategoryCtrl,
                          label: 'Sub Category',
                          icon: Icons.layers,
                          readOnly: true,
                        ),
                        InputField(
                          controller: productNameCtrl,
                          label: 'Product Name',
                          icon: Icons.label,
                          readOnly: true,
                        ),
                        DropDownButton(
                          label: 'Log Type',
                          items: logType,
                          selectedItem: selectedLogType,
                          onChanged: (value) {
                            setState(() {
                              selectedLogType = value;
                            });
                          },
                          icon: Icons.article,
                        ),
                        InputField(
                            controller: quantityCtrl,
                            label: "Qunatity",
                            icon: Icons.archive),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget:
                                  const InventoryLogManagementScreen(),
                              controllers: {
                                'quantity':
                                    double.tryParse(quantityCtrl.text) ?? 0.0,
                                'category': categoryCtrl,
                                'productName': productNameCtrl,
                                'logType': selectedLogType,
                                'subCategory': subCategoryCtrl
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'inventoryLog',
                              fieldsToSubmit: [
                                'quantity',
                                'category',
                                'productName',
                                'logType',
                                'subCategory'
                              ],
                              addTimestamp: false,
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
