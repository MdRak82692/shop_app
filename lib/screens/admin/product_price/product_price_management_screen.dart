import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_product_price_screen.dart';
import '../../../utils/search.dart';
import 'add_product_price_screen.dart';

class ProductPriceManagementScreen extends StatefulWidget {
  const ProductPriceManagementScreen({super.key});

  @override
  PProductPriceManagementScreenState createState() =>
      PProductPriceManagementScreenState();
}

class PProductPriceManagementScreenState
    extends State<ProductPriceManagementScreen> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 7),
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
                  title: 'Product Price',
                  targetWidget: AddProductPriceScreen(),
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
                        child: DynamicDataTable(
                          searchQuery: searchQuery,
                          collectionName: 'productPrice',
                          columnNames: const [
                            'Product Price ID',
                            'Product Name',
                            'Product Price',
                          ],
                          columnFieldMapping: const {
                            'Product Price ID': 'id',
                            'Product Name': 'productName',
                            'Product Price': 'productPrice',
                          },
                          targetWidget: (userId, userData) {
                            return EditProductPriceScreen(
                                userId: userId, userData: userData);
                          },
                          fieldName: 'priceType',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
