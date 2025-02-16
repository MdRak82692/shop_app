import '../../../data_table/order_data_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_products_sale.dart';
import 'edit_products_sale.dart';

class ProductsSale extends StatefulWidget {
  const ProductsSale({super.key});

  @override
  ProductsSaleState createState() => ProductsSaleState();
}

class ProductsSaleState extends State<ProductsSale> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 10),
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
                  title: 'Products Sale',
                  targetWidget: AddProductsSale(),
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
                            return EditProductsSale(
                                orderId: userId, orderData: userData);
                          },
                          searchQuery: searchQuery,
                          collectionName: 'sales',
                          columnNames: const [
                            'Discount',
                            'Total Price',
                            'Time',
                            'Print',
                          ],
                          columnFieldMapping: const {
                            'items': 'items',
                            'Discount': 'discount',
                            'Total Price': 'sale',
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
