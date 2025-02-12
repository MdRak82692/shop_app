import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/drop_down_button.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import 'sub_category_management_screen.dart';

class AddSubCategoryScreen extends StatefulWidget {
  const AddSubCategoryScreen({super.key});

  @override
  AddSubCategoryScreenState createState() => AddSubCategoryScreenState();
}

class AddSubCategoryScreenState extends State<AddSubCategoryScreen> {
  final firestore = FirebaseFirestore.instance;
  final subCategoryNameCtrl = TextEditingController();
  FetchInformation? fetchInformation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchInformation = FetchInformation(
      firestore: firestore,
      setState: setState,
    );
    fetchInformation!.fetchCategories().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 5),
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
                        const AddEditTitleSection(
                            title: 'Add Sub-Category Detail'),
                        const SizedBox(height: 40),
                        DropDownButton(
                          label: 'Category',
                          items: fetchInformation!.categories,
                          selectedItem: fetchInformation!.selectedCategory,
                          icon: Icons.category,
                          onChanged: (newValue) {
                            setState(() {
                              fetchInformation!.selectedCategory = newValue;
                            });
                          },
                        ),
                        InputField(
                            controller: subCategoryNameCtrl,
                            label: "Sub-Category Name",
                            icon: Icons.layers),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await addInformation(
                              context: context,
                              targetWidget: const SubCategoryManagementScreen(),
                              controllers: {
                                'subCategory': subCategoryNameCtrl.text,
                                'category': fetchInformation!.selectedCategory,
                              },
                              name: 'subCategory',
                              option: 'subCategory',
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'subCategory',
                              fieldsToSubmit: ['subCategory', 'category'],
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
