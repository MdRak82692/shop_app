import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/drop_down_button.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import 'product_price_management_screen.dart';

class AddProductPriceScreen extends StatefulWidget {
  const AddProductPriceScreen({super.key});

  @override
  AddProductPriceScreenState createState() => AddProductPriceScreenState();
}

class AddProductPriceScreenState extends State<AddProductPriceScreen> {
  final firestore = FirebaseFirestore.instance;
  final priceCtrl = TextEditingController();
  String? selectedPriceType;
  FetchInformation? fetchInformation;
  bool isLoading = false;
  List<String> availablePriceTypesForSelectedProduct = [
    'Buying Price',
    'Selling Price'
  ];

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
                              fetchInformation!.fetchProductName(
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

                              List<String> availablePriceTypes =
                                  await fetchInformation!
                                      .getAvailablePriceTypes(newValue!);
                              setState(() {
                                selectedPriceType = null;
                                availablePriceTypesForSelectedProduct =
                                    availablePriceTypes;
                              });
                            },
                          ),
                        if (fetchInformation!.selectedProductName != null)
                          DropDownButton(
                            label: 'Price Type',
                            items: availablePriceTypesForSelectedProduct,
                            selectedItem: selectedPriceType,
                            onChanged: (value) {
                              setState(() {
                                selectedPriceType = value;
                              });
                            },
                            icon: Icons.shopping_cart,
                          ),
                        InputField(
                            controller: priceCtrl,
                            label: "Product Price",
                            icon: Icons.attach_money),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await addInformation(
                              context: context,
                              targetWidget:
                                  const ProductPriceManagementScreen(),
                              controllers: {
                                'priceType': selectedPriceType,
                                'productName':
                                    fetchInformation!.selectedProductName,
                                'productPrice':
                                    double.tryParse(priceCtrl.text) ?? 0.00,
                                'category': fetchInformation!.selectedCategory,
                                'subCategory':
                                    fetchInformation!.selectedSubCategory,
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'productPrice',
                              fieldsToSubmit: [
                                'productPrice',
                                'category',
                                'productName',
                                'priceType',
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
