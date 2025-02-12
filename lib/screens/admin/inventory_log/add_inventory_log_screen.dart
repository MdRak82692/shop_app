import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/drop_down_button.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import 'inventory_log_management_screen.dart';

class AddInventoryLogScreen extends StatefulWidget {
  const AddInventoryLogScreen({super.key});

  @override
  AddInventoryLogScreenState createState() => AddInventoryLogScreenState();
}

class AddInventoryLogScreenState extends State<AddInventoryLogScreen> {
  final firestore = FirebaseFirestore.instance;
  final quantityCtrl = TextEditingController();
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
    fetchInformation = FetchInformation(
      firestore: firestore,
      setState: setState,
    );
    fetchInformation!.fetchCategories().then((_) {});
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
                            title: 'Add Product Price Detail'),
                        const SizedBox(height: 40),
                        DropDownButton(
                          label: 'Category',
                          items: fetchInformation!.categories,
                          selectedItem: fetchInformation!.selectedCategory,
                          icon: Icons.category,
                          onChanged: (newValue) async {
                            setState(() {
                              fetchInformation!.selectedCategory = newValue;
                              fetchInformation!.selectedSubCategory = null;
                              fetchInformation!.subCategories = [];
                            });

                            await fetchInformation!.fetchSubCategory(newValue!);
                          },
                        ),
                        if (fetchInformation!.selectedCategory != null)
                          DropDownButton(
                            label: 'Sub Category',
                            items: fetchInformation!.subCategories,
                            selectedItem: fetchInformation!.selectedSubCategory,
                            icon: Icons.layers,
                            onChanged: (newValue) {
                              setState(() {
                                fetchInformation!.selectedSubCategory =
                                    newValue;
                                fetchInformation!.selectedProductName = null;
                                fetchInformation!.productName = [];
                              });
                              fetchInformation!.fetchProductName1(
                                fetchInformation!.selectedCategory!,
                                newValue!,
                              );
                            },
                          ),
                        if (fetchInformation!.selectedSubCategory != null)
                          DropDownButton(
                            label: 'Product Name',
                            items: fetchInformation!.productName,
                            selectedItem: fetchInformation!.selectedProductName,
                            icon: Icons.label,
                            onChanged: (newValue) async {
                              setState(() {
                                fetchInformation!.selectedProductName =
                                    newValue;
                              });

                              setState(() {
                                selectedLogType = null;
                              });
                            },
                          ),
                        if (fetchInformation!.selectedProductName != null)
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
                            label: "Quantity",
                            icon: Icons.archive),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await addInformation(
                              context: context,
                              targetWidget:
                                  const InventoryLogManagementScreen(),
                              controllers: {
                                'logType': selectedLogType,
                                'productName':
                                    fetchInformation!.selectedProductName,
                                'quantity':
                                    double.tryParse(quantityCtrl.text) ?? 0.0,
                                'category': fetchInformation!.selectedCategory,
                                'subCategory':
                                    fetchInformation!.selectedSubCategory,
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
