import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'product_list_management_screen.dart';

class EditProductListScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditProductListScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditProductListScreenState createState() => EditProductListScreenState();
}

class EditProductListScreenState extends State<EditProductListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final productNameCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'productName': productNameCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'productList',
      fieldsToSubmit: ['productName'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withAlpha(50),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddEditTitleSection(
                            title: 'Update Product Detail',
                            targetWidget: () =>
                                const ProductListManagementScreen()),
                        const SizedBox(height: 40),
                        InputField(
                            controller: productNameCtrl,
                            label: "Product Name",
                            icon: Icons.label),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget: const ProductListManagementScreen(),
                              controllers: {
                                'productName': productNameCtrl.text,
                              },
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'productList',
                              fieldsToSubmit: [
                                'productName',
                              ],
                              name: 'productName',
                              option: 'productName',
                              addTimestamp: false,
                            );
                          },
                          isLoading: isLoading,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
