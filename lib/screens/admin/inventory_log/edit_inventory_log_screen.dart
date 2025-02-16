import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../fetch_information/fetch_information.dart';
import '../../../firestore/load_informaion.dart';
import '../../../fetch_information/quantity_fetch_information.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/text.dart';
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

  QuantityFetchInformation? quantityFetchInformation;
  FetchInformation? fetchInformation;

  final quantityCtrl = TextEditingController();
  final productNameCtrl = TextEditingController();

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchInformation =
        FetchInformation(firestore: firestore, setState: setState);

    Map<String, dynamic> controllers = {
      'quantity': quantityCtrl..text = widget.userData['quantity'].toString(),
      'productName': productNameCtrl
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
        'productName',
        'logType',
      ],
    );

    quantityFetchInformation =
        QuantityFetchInformation(firestore: firestore, setState: setState);

    fetchAvailableQuantity(widget.userData['productName']);
  }

  void fetchAvailableQuantity(String productName) async {
    double availableQty =
        await quantityFetchInformation!.fetchAvailableQuantity(productName);

    setState(() {
      availableQuantity = availableQty;
    });
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
                          title: 'Update Inventory Log Detail',
                          targetWidget: () =>
                              const InventoryLogManagementScreen(),
                        ),
                        const SizedBox(height: 40),
                        InputField(
                          controller: productNameCtrl
                            ..text = widget.userData['productName'],
                          label: "Product Name",
                          icon: Icons.label,
                          readOnly: true,
                        ),
                        InputField(
                          controller: quantityCtrl,
                          label: "Quantity",
                          icon: Icons.archive,
                          onChanged: (value) {
                            setState(() {
                              quantity = double.tryParse(value) ?? 1.0;
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
                                  await updateInformation(
                                    userId: widget.userId,
                                    context: context,
                                    targetWidget:
                                        const InventoryLogManagementScreen(),
                                    controllers: {
                                      'logType': selectedLogType,
                                      'productName':
                                          widget.userData['productName'],
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
