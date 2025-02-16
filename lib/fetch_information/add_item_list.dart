import 'package:flutter/material.dart';
import '../utils/show_dialog.dart';

Map<String, dynamic>? addItemToList(
  BuildContext context,
  TextEditingController pricePerProductCtrl,
  String? selectedProductName,
  double quantity,
  double pricePerProduct,
  dynamic quantityCtrl,
  dynamic productPriceCtrl,
) {
  if (selectedProductName == null || quantity <= 0 || pricePerProduct <= 0) {
    if (!context.mounted) return null;
    showCustomDialog(context, 'Error', 'All Fields are Required.');
    return null;
  } else {
    double finalPricePerProduct =
        double.tryParse(pricePerProductCtrl.text) ?? 0.0;
    double productPrice = quantity * finalPricePerProduct;

    Map<String, dynamic> newItem = {
      'productName': selectedProductName,
      'pricePerProduct': finalPricePerProduct,
      'quantity': quantity,
      'productPrice': productPrice,
    };

    selectedProductName = null;
    quantity = 0;
    pricePerProduct = 0.0;
    productPrice = 0;

    quantityCtrl.clear();
    pricePerProductCtrl.clear();
    productPriceCtrl.clear();

    return newItem;
  }
}
