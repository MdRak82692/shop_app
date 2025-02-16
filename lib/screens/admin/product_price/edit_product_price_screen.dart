import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'product_price_management_screen.dart';

class EditProductPriceScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditProductPriceScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditProductPriceScreenState createState() => EditProductPriceScreenState();
}

class EditProductPriceScreenState extends State<EditProductPriceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final productNameCtrl = TextEditingController();
  final priceTypeCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'productPrice': priceCtrl,
      'productName': productNameCtrl,
      'priceType': priceTypeCtrl
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'productPrice',
      fieldsToSubmit: ['productPrice', 'productName', 'priceType'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 7),
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
                          title: 'Update Product Price Detail',
                          targetWidget: () =>
                              const ProductPriceManagementScreen(),
                        ),
                        const SizedBox(height: 40),
                        InputField(
                          controller: productNameCtrl,
                          label: 'Product Name',
                          icon: Icons.label,
                          readOnly: true,
                        ),
                        InputField(
                          controller: priceTypeCtrl,
                          label: 'Price Type',
                          icon: Icons.shopping_cart,
                          readOnly: true,
                        ),
                        InputField(
                            controller: priceCtrl,
                            label: "Product Price",
                            icon: Icons.attach_money),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget:
                                  const ProductPriceManagementScreen(),
                              controllers: {
                                'priceType': priceTypeCtrl.text,
                                'productName': productNameCtrl.text,
                                'productPrice':
                                    double.tryParse(priceCtrl.text) ?? 0.00,
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'productPrice',
                              fieldsToSubmit: [
                                'productPrice',
                                'productName',
                                'priceType',
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
