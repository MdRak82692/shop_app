import 'package:cloud_firestore/cloud_firestore.dart';

class QuantityFetchInformation {
  final FirebaseFirestore firestore;
  Function(void Function()) setState;

  QuantityFetchInformation({required this.firestore, required this.setState});

  Future<Map<String, double>> fetchAvailableQuantities() async {
    Map<String, double> availableQuantities = {};

    QuerySnapshot productListSnapshot =
        await firestore.collection('productList').get();

    for (var doc in productListSnapshot.docs) {
      String productName = doc['productName'];

      double purchaseQty =
          await sumArrayFieldCollection('products', productName);

      double salesQty = await sumArrayFieldCollection('sales', productName);

      double inventoryLogQty =
          await sumDirectFieldCollection('inventoryLog', productName);

      availableQuantities[productName] =
          purchaseQty - salesQty - inventoryLogQty;
    }

    return availableQuantities;
  }

  Future<double> sumArrayFieldCollection(
      String collection, String productName) async {
    QuerySnapshot snapshot = await firestore.collection(collection).get();

    double totalQuantity = 0;

    for (var doc in snapshot.docs) {
      List<dynamic> items = doc['items'];

      for (var item in items) {
        if (item['productName'] == productName) {
          totalQuantity += (item['quantity'] ?? 0).toDouble();
        }
      }
    }

    return totalQuantity;
  }

  Future<double> sumDirectFieldCollection(
      String collection, String productName) async {
    QuerySnapshot snapshot = await firestore
        .collection(collection)
        .where('productName', isEqualTo: productName)
        .get();

    return snapshot.docs.fold<double>(0, (double sum, doc) {
      double quantity = (doc['quantity'] ?? 0).toDouble();
      return sum + quantity;
    });
  }
}
