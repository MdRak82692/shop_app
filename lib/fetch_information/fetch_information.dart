import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchInformation {
  final FirebaseFirestore firestore;
  Function(void Function()) setState;

  FetchInformation({required this.firestore, required this.setState});
  final productPriceCtrl = TextEditingController();
  final totalPriceCtrl = TextEditingController();
  final pricePerProductCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();

  FetchInformation? fetchInformation;
  double totalPrice = 0.0;
  double discount = 0.0;
  double pricePerProduct = 0.0;
  double quantity = 1.0;
  double productPrice = 0.0;

  String? selectedProductName;
  String? selectedStaff;

  List<String> productName = [];
  List<Map<String, dynamic>> staffList = [];
  List<String> excludedStaffNames = [];
  List<Map<String, String>> excludedStaffNamesAndPositions = [];
  Map<String, double> priceMap = {};
  List<Map<String, dynamic>> items = [];

  Future<void> fetchProductName() async {
    QuerySnapshot querySnapshot =
        await firestore.collection('productList').get();
    QuerySnapshot priceSnapshot =
        await firestore.collection('productPrice').get();

    Map<String, List<String>> productPriceTypes = {};
    for (var doc in priceSnapshot.docs) {
      String productName = doc['productName'] as String;
      String priceType = doc['priceType'] as String;

      if (productPriceTypes[productName] == null) {
        productPriceTypes[productName] = [];
      }
      productPriceTypes[productName]!.add(priceType);
    }

    setState(() {
      productName = querySnapshot.docs
          .map((doc) => doc['productName'] as String)
          .where((name) {
        return true;
      }).toList()
        ..sort((a, b) => a.compareTo(b));
    });
  }

  Future<List<String>> getAvailablePriceTypes(String productName) async {
    QuerySnapshot priceSnapshot = await firestore
        .collection('productPrice')
        .where('productName', isEqualTo: productName)
        .get();

    List<String> existingPriceTypes =
        priceSnapshot.docs.map((doc) => doc['priceType'] as String).toList();

    if (existingPriceTypes.contains('Buying Price')) {
      return ['Selling Price'];
    } else if (existingPriceTypes.contains('Selling Price')) {
      return ['Buying Price'];
    } else {
      return ['Buying Price', 'Selling Price'];
    }
  }

  Future<void> fetchPurchaseProductName() async {
    QuerySnapshot querySnapshot =
        await firestore.collection('productList').get();

    setState(() {
      productName = querySnapshot.docs
          .map((doc) => doc['productName'] as String)
          .toList()
        ..sort((a, b) => a.compareTo(b));
    });
  }

  Future<void> fetchProductPrice(String productName) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('productPrice')
        .where('priceType', isEqualTo: 'Buying Price')
        .where('productName', isEqualTo: productName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      double fetchedPrice =
          (querySnapshot.docs.first['productPrice'] as num).toDouble();

      setState(() {
        if (pricePerProductCtrl.text.isEmpty ||
            pricePerProduct == priceMap[productName]) {
          pricePerProductCtrl.text = fetchedPrice.toString();
          pricePerProduct = fetchedPrice;
        }

        priceMap[productName] = fetchedPrice;
      });

      updatePrice();
    }
  }

  Future<void> fetchSalePrice(String productName) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('productPrice')
        .where('priceType', isEqualTo: 'Selling Price')
        .where('productName', isEqualTo: productName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var price = querySnapshot.docs.first['productPrice'];
      setState(() {
        priceMap[productName] = (price as num).toDouble();
        pricePerProductCtrl.text = price.toString();
      });

      updatePrice();
    }
  }

  Future<void> fetchStaffData() async {
    try {
      final salarySnapshot =
          await firestore.collection('staffsalaryinformation').get();

      excludedStaffNamesAndPositions = salarySnapshot.docs
          .map((doc) => {
                'name': doc['staffName'] as String,
              })
          .toList();

      final staffSnapshot = await firestore.collection('staff').get();

      setState(() {
        staffList = staffSnapshot.docs
            .map((doc) => {
                  'name': "${doc['staffName']}",
                })
            .where((staff) {
          return !excludedStaffNamesAndPositions
              .any((excludedStaff) => excludedStaff['name'] == staff['name']);
        }).toList();
      });
    } finally {}
  }

  void updatePrice() {
    if (selectedProductName != null) {
      pricePerProduct = double.tryParse(pricePerProductCtrl.text) ?? 0.0;
    }

    double productPrice = quantity * pricePerProduct;

    setState(() {
      productPriceCtrl.text = productPrice.toStringAsFixed(2);
    });
  }
}
