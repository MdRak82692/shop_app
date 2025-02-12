import '../../../firestore/fetch_information.dart';
import '../../../firestore/update_information.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../components/drop_down_button.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/text.dart';
import 'purchase_products.dart';

class EditPurchaseProducts extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const EditPurchaseProducts(
      {super.key, required this.orderId, required this.orderData});

  @override
  EditPurchaseProductsState createState() => EditPurchaseProductsState();
}

class EditPurchaseProductsState extends State<EditPurchaseProducts> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FetchInformation? fetchInformation;
  final quantityCtrl = TextEditingController();
  final pricePerProductCtrl = TextEditingController();
  final productPriceCtrl = TextEditingController();
  final totalPriceCtrl = TextEditingController();
  final discountCtrl = TextEditingController();

  double totalPrice = 0.0;
  double discount = 0.0;
  double pricePerProduct = 0.0;
  double quantity = 1.0;
  double productPrice = 0.0;

  String? selectedSubCategory;
  String? selectedCategory;
  String? selectedProductName;

  List<Map<String, dynamic>> items = [];
  Map<String, double> priceMap = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchInformation =
        FetchInformation(firestore: firestore, setState: setState);

    totalPrice = widget.orderData['cost'] ?? 0.0;
    totalPriceCtrl.text = totalPrice.toStringAsFixed(2);
    discount = 0.0;
    pricePerProduct = 0.0;
    quantity = 1.0;
    productPrice = 0.0;
    items = List<Map<String, dynamic>>.from(widget.orderData['items'] ?? []);
    fetchInformation!.fetchCategories().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 9),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AddEditTitleSection(
                          title: 'Update Purchase Product Details'),
                      const SizedBox(height: 30),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              DropDownButton(
                                label: 'Category',
                                items: fetchInformation!.categories,
                                selectedItem:
                                    fetchInformation!.selectedCategory,
                                icon: Icons.category,
                                onChanged: (newValue) async {
                                  setState(() {
                                    fetchInformation!.selectedCategory =
                                        newValue;
                                    fetchInformation!.selectedSubCategory =
                                        null;
                                    fetchInformation!.subCategories = [];
                                  });

                                  await fetchInformation!
                                      .fetchSubCategory(newValue!);
                                },
                              ),
                              if (fetchInformation!.selectedCategory != null)
                                DropDownButton(
                                  label: 'Sub Category',
                                  items: fetchInformation!.subCategories,
                                  selectedItem:
                                      fetchInformation!.selectedSubCategory,
                                  icon: Icons.layers,
                                  onChanged: (newValue) {
                                    setState(() {
                                      fetchInformation!.selectedSubCategory =
                                          newValue;
                                      fetchInformation!.selectedProductName =
                                          null;
                                      fetchInformation!.productName = [];
                                    });
                                    fetchInformation!.fetchPurchaseProductName(
                                      fetchInformation!.selectedCategory!,
                                      newValue!,
                                    );
                                  },
                                ),
                              if (fetchInformation!.selectedSubCategory != null)
                                DropDownButton(
                                  label: 'Product Name',
                                  items: fetchInformation!.productName,
                                  selectedItem:
                                      fetchInformation!.selectedProductName,
                                  icon: Icons.label,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      fetchInformation!.selectedProductName =
                                          newValue;
                                    });

                                    await fetchInformation!
                                        .fetchProductPrice(newValue!);

                                    setState(() {
                                      pricePerProduct = fetchInformation!
                                              .priceMap[newValue] ??
                                          0.0;
                                      pricePerProductCtrl.text =
                                          pricePerProduct.toString();
                                      fetchInformation!.updatePrice();
                                    });
                                  },
                                ),
                              InputField(
                                controller: quantityCtrl,
                                label: "Quantity",
                                icon: Icons.archive,
                                onChanged: (value) {
                                  setState(() {
                                    quantity = double.tryParse(value) ?? 1.0;
                                    fetchInformation!.quantity = quantity;
                                    fetchInformation!.updatePrice();
                                  });
                                },
                              ),
                              InputField(
                                controller: pricePerProductCtrl,
                                label: "Price Per Product",
                                icon: Icons.attach_money,
                                onChanged: (value) {
                                  setState(() {
                                    pricePerProduct =
                                        double.tryParse(value) ?? 0.0;
                                    fetchInformation!.pricePerProduct =
                                        pricePerProduct;
                                    fetchInformation!.quantity =
                                        double.tryParse(quantityCtrl.text) ??
                                            1.0;
                                    double productPrice =
                                        fetchInformation!.quantity *
                                            fetchInformation!.pricePerProduct;
                                    fetchInformation!.productPriceCtrl.text =
                                        productPrice.toStringAsFixed(2);
                                  });
                                },
                              ),
                              InputField(
                                controller: fetchInformation!.productPriceCtrl,
                                label: "Product Price",
                                icon: Icons.monetization_on,
                                readOnly: true,
                                onChanged: (value) {},
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                onPressed: () {
                                  Map<String, dynamic>? newItem =
                                      fetchInformation!.addItemToList();
                                  setState(() {
                                    if (newItem != null) {
                                      items.add(newItem);
                                      totalPrice +=
                                          newItem['productPrice'] as double;

                                      totalPriceCtrl.text =
                                          totalPrice.toStringAsFixed(2);
                                      selectedCategory = null;
                                      selectedSubCategory = null;
                                      selectedProductName = null;
                                      quantity = 0;
                                      pricePerProduct = 0;
                                      productPrice = 0;
                                      quantityCtrl.clear();
                                      pricePerProductCtrl.clear();
                                      productPriceCtrl.clear();
                                    }
                                  });
                                },
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 30),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ListTile(
                                    title: Text(
                                      "Product Name: ${item['productName']} \nQuantity: ${item['quantity'].toStringAsFixed(2)}\nPrice Per Product: ${item['pricePerProduct'].toStringAsFixed(2)}",
                                      style: style(16, color: Colors.black),
                                    ),
                                    subtitle: Text(
                                      "Category: ${item['category']}\nSub Category:${item['subCategory']}\nPrice: ${item['productPrice'].toStringAsFixed(2)}",
                                      style: style(16, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          totalPrice -=
                                              item['productPrice'] as double;
                                          items.removeAt(index);

                                          totalPrice = items.fold(
                                              0,
                                              (total, item) =>
                                                  total + item['productPrice']);

                                          totalPriceCtrl.text =
                                              totalPrice.toStringAsFixed(2);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              InputField(
                                controller: discountCtrl,
                                label: 'Discount',
                                icon: Icons.percent,
                                onChanged: (value) {
                                  setState(() {
                                    discount = double.tryParse(value) ?? 0.0;
                                    double total = items.fold(
                                        0,
                                        (acc, item) =>
                                            acc + item['productPrice']);
                                    totalPriceCtrl.text =
                                        (total - discount).toStringAsFixed(2);
                                  });
                                },
                              ),
                              InputField(
                                controller: totalPriceCtrl,
                                label: 'Total Price',
                                icon: Icons.attach_money,
                                readOnly: true,
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPressed: () async {
                          await updateInformation(
                            context: context,
                            targetWidget: const PurchaseProducts(),
                            controllers: {
                              'items': items,
                              'cost': totalPrice,
                              'discount': discountCtrl,
                            },
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            collectionName: 'products',
                            fieldsToSubmit: [
                              'items',
                              'cost',
                            ],
                            addTimestamp: true,
                            userId: widget.orderId,
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
        ],
      ),
    );
  }
}
