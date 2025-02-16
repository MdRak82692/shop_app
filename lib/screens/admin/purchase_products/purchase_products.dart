import '../../../data_table/order_data_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_purchase_products.dart';
import 'edit_purchase_products.dart';

class PurchaseProducts extends StatefulWidget {
  const PurchaseProducts({super.key});

  @override
  PurchaseProductsState createState() => PurchaseProductsState();
}

class PurchaseProductsState extends State<PurchaseProducts> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 9),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value),
                ),
                const TitleSection(
                  title: 'Purchase Products',
                  targetWidget: AddPurchaseProducts(),
                  addIcon: true,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DynamicDataTable1(
                          targetWidget: (userId, userData) {
                            return EditPurchaseProducts(
                                orderId: userId, orderData: userData);
                          },
                          searchQuery: searchQuery,
                          collectionName: 'products',
                          columnNames: const [
                            'Discount',
                            'Total Price',
                            'Time',
                          ],
                          columnFieldMapping: const {
                            'items': 'items',
                            'Discount': 'discount',
                            'Total Price': 'cost',
                            'Time': 'time',
                          },
                          fieldName: 'time',
                          itemNames: const [
                            'Product Name',
                            'Quantity',
                            'Price Per Product',
                            'Product Price',
                          ],
                          itemFieldMapping: const {
                            'Product Name': 'productName',
                            'Quantity': 'quantity',
                            'Price Per Product': 'pricePerProduct',
                            'Product Price': 'productPrice',
                          },
                          editDelete: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
