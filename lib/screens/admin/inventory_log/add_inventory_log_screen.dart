import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/drop_down_button.dart';
import '../../../fetch_information/product_name_fetch_information.dart';
import '../../../fetch_information/quantity_fetch_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/text.dart';
import 'inventory_log_management_screen.dart';
import '../../../components/product_autocomplete.dart';

class AddInventoryLogScreen extends StatefulWidget {
  const AddInventoryLogScreen({super.key});

  @override
  AddInventoryLogScreenState createState() => AddInventoryLogScreenState();
}

class AddInventoryLogScreenState extends State<AddInventoryLogScreen> {
  final firestore = FirebaseFirestore.instance;

  QuantityFetchInformation? quantityFetchInformation;

  final quantityCtrl = TextEditingController();

  double availableQuantity = 0.0;
  double quantity = 1.0;
  String stockStatus = '';
  bool isQuantityValid = true;

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
  ProductNameFetchInformation? fetchInformation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchInformation = ProductNameFetchInformation(
      firestore: firestore,
      setState: setState,
    );
    fetchInformation!.fetchProductName().then((_) {});

    quantityFetchInformation =
        QuantityFetchInformation(firestore: firestore, setState: setState);
    quantityFetchInformation!.fetchAvailableQuantities();
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
                        AddEditTitleSection(
                          title: 'Add Inventroy Log Detail',
                          targetWidget: () =>
                              const InventoryLogManagementScreen(),
                        ),
                        const SizedBox(height: 40),
                        ProductAutocomplete(
                          fetchInformation: fetchInformation!,
                          onSelected: (newValue) async {
                            setState(() {
                              fetchInformation!.selectedProductName = newValue;
                              stockStatus = '';
                            });

                            Map<String, double> availableQuantities =
                                await quantityFetchInformation!
                                    .fetchAvailableQuantities();
                            double availableQuantity =
                                availableQuantities[newValue] ?? 0.0;

                            setState(() {
                              this.availableQuantity = availableQuantity;

                              if (availableQuantity <= 0) {
                                stockStatus = 'Out of Stock';
                                isQuantityValid = false;
                              } else {
                                stockStatus = '';
                                isQuantityValid = true;
                              }
                            });
                          },
                          textEditingController: TextEditingController(),
                          focusNode: FocusNode(),
                          onFieldSubmitted: () {},
                        ),
                        InputField(
                          controller: quantityCtrl,
                          label: "Quantity",
                          icon: Icons.archive,
                          onChanged: (value) {
                            setState(() {
                              quantity = double.tryParse(value) ?? 1.0;
                              fetchInformation!.quantity = quantity;

                              if (quantity > availableQuantity) {
                                stockStatus = 'Over Stock';
                                isQuantityValid = false;
                              } else if (availableQuantity <= 0) {
                                stockStatus = 'Out of Stock';
                                isQuantityValid = false;
                              } else {
                                stockStatus = '';
                                isQuantityValid = true;
                              }
                            });
                          },
                        ),
                        Center(
                          child: Text(
                            stockStatus,
                            style: style(
                              16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
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
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: isQuantityValid
                              ? () async {
                                  await addInformation(
                                    context: context,
                                    targetWidget:
                                        const InventoryLogManagementScreen(),
                                    controllers: {
                                      'logType': selectedLogType,
                                      'productName': fetchInformation!
                                              .selectedProductName ??
                                          '',
                                      'quantity':
                                          double.tryParse(quantityCtrl.text) ??
                                              0.0,
                                    },
                                    firestore: firestore,
                                    isLoading: isLoading,
                                    setState: setState,
                                    collectionName: 'inventoryLog',
                                    fieldsToSubmit: [
                                      'quantity',
                                      'productName',
                                      'logType',
                                    ],
                                    addTimestamp: true,
                                  );
                                }
                              : null,
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
