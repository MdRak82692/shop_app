import '../../../fetch_information/add_item_list.dart';
import '../../../fetch_information/quantity_fetch_information.dart';
import '../../../firestore/update_information.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../utils/text.dart';
import '../../fetch_information/product_name_fetch_information.dart';
import 'staff_products_sale.dart';
import '../../../components/product_autocomplete.dart';

class EditProductsSale extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const EditProductsSale(
      {super.key, required this.orderId, required this.orderData});

  @override
  EditProductsSaleState createState() => EditProductsSaleState();
}

class EditProductsSaleState extends State<EditProductsSale> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ProductNameFetchInformation? fetchInformation;
  QuantityFetchInformation? quantityFetchInformation;
  final quantityCtrl = TextEditingController();
  final pricePerProductCtrl = TextEditingController();
  final productPriceCtrl = TextEditingController();
  final totalPriceCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  final productAutocompleteCtrl = TextEditingController();

  double totalPrice = 0.0;
  double discount = 0.0;
  double pricePerProduct = 0.0;
  double quantity = 1.0;
  double productPrice = 0.0;
  double availableQuantity = 0.0;
  String stockStatus = '';
  bool isQuantityValid = true;

  String? selectedProductName;

  List<Map<String, dynamic>> items = [];
  Map<String, double> priceMap = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchInformation =
        ProductNameFetchInformation(firestore: firestore, setState: setState);
    fetchInformation!.fetchProductName().then((_) {});

    totalPrice = widget.orderData['sale'] ?? 0.0;
    totalPriceCtrl.text = totalPrice.toStringAsFixed(2);
    discount = widget.orderData['discount'] ?? 0.0;
    discountCtrl.text = discount.toStringAsFixed(2);
    pricePerProduct = 0.0;
    quantity = 1.0;
    productPrice = 0.0;
    items = List<Map<String, dynamic>>.from(widget.orderData['items'] ?? []);

    quantityFetchInformation =
        QuantityFetchInformation(firestore: firestore, setState: setState);
    quantityFetchInformation!.fetchAvailableQuantities().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withAlpha(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddEditTitleSection(
                            title: 'Add Products Sale Details',
                            targetWidget: () => const StaffProductsSale(),
                          ),
                          const SizedBox(height: 40),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ProductAutocomplete(
                                    fetchInformation: fetchInformation!,
                                    onSelected: (newValue) async {
                                      setState(() {
                                        fetchInformation!.selectedProductName =
                                            newValue;
                                        stockStatus = '';
                                        selectedProductName = newValue;
                                        productAutocompleteCtrl.text = newValue;
                                      });

                                      await fetchInformation!
                                          .fetchSalePrice(newValue);

                                      Map<String, double> availableQuantities =
                                          await quantityFetchInformation!
                                              .fetchAvailableQuantities();
                                      double availableQuantity =
                                          availableQuantities[newValue] ?? 0.0;

                                      double existingUserPrice =
                                          double.tryParse(
                                                  pricePerProductCtrl.text) ??
                                              0.0;
                                      double fetchedPrice = fetchInformation!
                                              .priceMap[newValue] ??
                                          0.0;

                                      setState(() {
                                        pricePerProduct =
                                            (existingUserPrice > 0)
                                                ? existingUserPrice
                                                : fetchedPrice;
                                        pricePerProductCtrl.text =
                                            pricePerProduct.toString();
                                        this.availableQuantity =
                                            availableQuantity;

                                        if (availableQuantity <= 0) {
                                          stockStatus = 'Out of Stock';
                                          isQuantityValid = false;
                                        } else {
                                          stockStatus = '';
                                          isQuantityValid = true;
                                        }
                                      });
                                    },
                                    textEditingController:
                                        productAutocompleteCtrl,
                                    focusNode: FocusNode(),
                                    onFieldSubmitted: () {},
                                  ),
                                  InputField(
                                    controller: quantityCtrl,
                                    label: "Quantity",
                                    icon: Icons.archive,
                                    onChanged: (value) {
                                      setState(() {
                                        quantity =
                                            double.tryParse(value) ?? 1.0;
                                        fetchInformation!.quantity = quantity;
                                        fetchInformation!.updatePrice();
                                        double productPrice =
                                            quantity * pricePerProduct;
                                        fetchInformation!
                                                .productPriceCtrl.text =
                                            productPrice.toStringAsFixed(2);

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
                                  Text(
                                    stockStatus,
                                    style: style(
                                      14,
                                      color: stockStatus == 'Over Stock' ||
                                              stockStatus == 'Out of Stock'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
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
                                            double.tryParse(
                                                    quantityCtrl.text) ??
                                                1.0;
                                        double productPrice =
                                            fetchInformation!.quantity *
                                                pricePerProduct;
                                        fetchInformation!
                                                .productPriceCtrl.text =
                                            productPrice.toStringAsFixed(2);
                                      });
                                    },
                                  ),
                                  InputField(
                                    controller:
                                        fetchInformation!.productPriceCtrl,
                                    label: "Product Price",
                                    icon: Icons.monetization_on,
                                    readOnly: true,
                                    onChanged: (value) {},
                                  ),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    onPressed: isQuantityValid
                                        ? () {
                                            Map<String, dynamic>? newItem =
                                                addItemToList(
                                              context,
                                              pricePerProductCtrl,
                                              selectedProductName!,
                                              quantity,
                                              pricePerProduct,
                                              quantityCtrl,
                                              productPriceCtrl,
                                            );

                                            if (newItem != null) {
                                              setState(() {
                                                items.add(newItem);
                                                totalPrice +=
                                                    (newItem['productPrice']
                                                            as double) -
                                                        (double.tryParse(
                                                                discountCtrl
                                                                    .text) ??
                                                            0.0);
                                                totalPriceCtrl.text = totalPrice
                                                    .toStringAsFixed(2);

                                                quantity = 1.0;
                                                fetchInformation!
                                                    .productPriceCtrl
                                                    .clear();
                                                productPrice = 0.0;
                                                fetchInformation!
                                                    .selectedProductName = null;
                                                quantityCtrl.text = '';
                                                pricePerProductCtrl.text = '';
                                                productPriceCtrl.text = '';
                                                productAutocompleteCtrl.text =
                                                    '';
                                              });
                                            }
                                          }
                                        : null,
                                    isLoading: isLoading,
                                  ),
                                  const SizedBox(height: 30),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return ListTile(
                                        title: Text(
                                          "Product Name: ${item['productName']} \nQuantity: ${item['quantity'].toStringAsFixed(2)}\nPrice Per Product: ${item['pricePerProduct'].toStringAsFixed(2)}",
                                          style: style(16, color: Colors.black),
                                        ),
                                        subtitle: Text(
                                          "Price: ${item['productPrice'].toStringAsFixed(2)}",
                                          style: style(16, color: Colors.black),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              totalPrice -= item['productPrice']
                                                  as double;
                                              items.removeAt(index);

                                              double totalWithoutDiscount =
                                                  items.fold(
                                                0,
                                                (total, item) =>
                                                    total +
                                                    item['productPrice'],
                                              );

                                              totalPrice =
                                                  totalWithoutDiscount -
                                                      (double.tryParse(
                                                              discountCtrl
                                                                  .text) ??
                                                          0.0);

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
                                        discount =
                                            double.tryParse(value) ?? 0.0;
                                        double total = items.fold(
                                            0,
                                            (acc, item) =>
                                                acc + item['productPrice']);
                                        totalPriceCtrl.text = (total - discount)
                                            .toStringAsFixed(2);
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
                            onPressed: isQuantityValid
                                ? () async {
                                    await updateInformation(
                                      context: context,
                                      targetWidget: const StaffProductsSale(),
                                      controllers: {
                                        'items': items,
                                        'sale': double.tryParse(
                                                totalPriceCtrl.text) ??
                                            0.0,
                                        'discount': double.tryParse(
                                                discountCtrl.text) ??
                                            0.0,
                                        'logType': 'Sales'
                                      },
                                      firestore: firestore,
                                      isLoading: isLoading,
                                      setState: setState,
                                      collectionName: 'sales',
                                      fieldsToSubmit: [
                                        'items',
                                        'sale',
                                        'logType',
                                        'discount'
                                      ],
                                      addTimestamp: true,
                                      userId: widget.orderId,
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
            ],
          ),
        ),
      ],
    );
  }
}
