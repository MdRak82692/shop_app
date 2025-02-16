import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data_table/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_product_list_screen.dart';
import '../../../utils/search.dart';
import 'add_product_list_screen.dart';

class ProductListManagementScreen extends StatefulWidget {
  const ProductListManagementScreen({super.key});

  @override
  ProductListManagementScreenState createState() =>
      ProductListManagementScreenState();
}

class ProductListManagementScreenState
    extends State<ProductListManagementScreen> {
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
          const BuildSidebar(selectedIndex: 6),
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
                  title: 'Product List',
                  targetWidget: AddProductListScreen(),
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
                          collectionName: 'productList',
                          columnNames: const [
                            'Product ID',
                            'Product Name',
                          ],
                          columnFieldMapping: const {
                            'Product ID': 'id',
                            'Product Name': 'productName',
                          },
                          targetWidget: (userId, userData) {
                            return EditProductListScreen(
                                userId: userId, userData: userData);
                          },
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
