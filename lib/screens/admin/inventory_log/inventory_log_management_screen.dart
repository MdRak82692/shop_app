import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/sale_title.dart';
import '../../../data_table/separate_data_table.dart';
import '../../../data_table/order_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_inventory_log_screen.dart';
import '../../../utils/search.dart';
import 'add_inventory_log_screen.dart';

class InventoryLogManagementScreen extends StatefulWidget {
  const InventoryLogManagementScreen({super.key});

  @override
  InventoryLogManagementScreenState createState() =>
      InventoryLogManagementScreenState();
}

class InventoryLogManagementScreenState
    extends State<InventoryLogManagementScreen> {
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
          const BuildSidebar(selectedIndex: 11),
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
                  title: 'Inventory Log',
                  targetWidget: AddInventoryLogScreen(),
                  addIcon: true,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SaleTitle(title: 'Purchase Transaction'),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DynamicDataTable1(
                              targetWidget: (userId, userData) {
                                return Container();
                              },
                              searchQuery: searchQuery,
                              collectionName: 'products',
                              columnNames: const ['Log Type', 'Time'],
                              columnFieldMapping: const {
                                'items': 'items',
                                'Time': 'time',
                                'Log Type': 'logType'
                              },
                              fieldName: 'time',
                              itemNames: const [
                                'Product Name',
                                'Quantity',
                              ],
                              itemFieldMapping: const {
                                'Category': 'category',
                                'Sub Category': 'subCategory',
                                'Product Name': 'productName',
                                'Quantity': 'quantity',
                                'Price Per Product': 'pricePerProduct',
                                'Product Price': 'productPrice',
                              },
                              editDelete: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Sales Transaction'),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DynamicDataTable1(
                              targetWidget: (userId, userData) {
                                return Container();
                              },
                              searchQuery: searchQuery,
                              collectionName: 'sales',
                              columnNames: const ['Log Type', 'Time'],
                              columnFieldMapping: const {
                                'items': 'items',
                                'Time': 'time',
                                'Log Type': 'logType',
                              },
                              fieldName: 'time',
                              itemNames: const [
                                'Product Name',
                                'Quantity',
                              ],
                              itemFieldMapping: const {
                                'Product Name': 'productName',
                                'Quantity': 'quantity',
                              },
                              editDelete: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Other Transaction'),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DynamicDataTable(
                              searchQuery: searchQuery,
                              collectionName: 'inventoryLog',
                              columnNames: const [
                                'Log ID',
                                'Product Name',
                                'Quantity',
                                'Log Type',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Log ID': 'id',
                                'Product Name': 'productName',
                                'Quantity': 'quantity',
                                'Log Type': 'logType',
                                'Time': 'time'
                              },
                              targetWidget: (userId, userData) {
                                return EditInventoryLogScreen(
                                    userId: userId, userData: userData);
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                      ],
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
