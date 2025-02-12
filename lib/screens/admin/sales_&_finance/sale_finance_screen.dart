import '../../../../data_table/sale_data_table.dart';
import '../../../../components/sale_title.dart';
import '../../../../components/title_section.dart';
import '../../../../utils/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firestore/sale_fetch_information.dart';
import '../../../utils/loading_display.dart';
import '../../../utils/slider_bar.dart';

class SaleFinanceScreen extends StatefulWidget {
  const SaleFinanceScreen({super.key});

  @override
  SaleFinanceScreenState createState() => SaleFinanceScreenState();
}

class SaleFinanceScreenState extends State<SaleFinanceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<double> calculateTotal(String collection, String fieldName) async {
    double total = 0.0;
    final snapshot = await firestore.collection(collection).get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data[fieldName] is num) {
        total += data[fieldName].toDouble();
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 14),
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
                  title: 'Sale & Finance Management',
                  addIcon: false,
                ),
                const SizedBox(height: 10),
                const SalesDataWidget(),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Investment'),
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
                              collectionName: 'investment',
                              columnNames: const [
                                'Investment ID',
                                'Inverstor Name',
                                'Amount',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Investment ID': 'id',
                                'Inverstor Name': 'inverstorName',
                                'Amount': 'sale',
                                'Time': 'time',
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('investment', 'sale'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return buildLoadingOverlay();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Other Cost'),
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
                              collectionName: 'otherCost',
                              columnNames: const [
                                'Other Cost ID',
                                'Recipient Name',
                                'Amount',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Other Cost ID': 'id',
                                'Recipient Name': 'recipientName',
                                'Amount': 'cost',
                                'Time': 'time',
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('products', 'cost'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return buildLoadingOverlay();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Product Cost'),
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
                              collectionName: 'products',
                              columnNames: const [
                                'Product ID',
                                'Product Name',
                                'Total Price',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Product ID': 'id',
                                'Product Name': 'productName',
                                'Total Price': 'cost',
                                'Time': 'time',
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('products', 'cost'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return buildLoadingOverlay();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Products Sale'),
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
                              collectionName: 'sales',
                              columnNames: const [
                                'Order ID',
                                'Product Name',
                                'Total Price',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Order ID': 'id',
                                'Total Price': 'sale',
                                'Time': 'time',
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('sales', 'sale'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return buildLoadingOverlay();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Staff Salary'),
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
                              collectionName: 'staffsalary',
                              columnNames: const [
                                'Salary ID',
                                'Staff Name',
                                'Salary Amount',
                                'Time'
                              ],
                              columnFieldMapping: const {
                                'Salary ID': 'id',
                                'Staff Name': 'staffName',
                                'Salary Amount': 'salary',
                                'Time': 'time',
                              },
                              fieldName: 'time',
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('staffsalary', 'salary'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return buildLoadingOverlay();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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
