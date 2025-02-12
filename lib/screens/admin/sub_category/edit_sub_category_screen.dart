import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'sub_category_management_screen.dart';

class EditSubCategoryScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditSubCategoryScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditSubCategoryScreenState createState() => EditSubCategoryScreenState();
}

class EditSubCategoryScreenState extends State<EditSubCategoryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final subCategoryNameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'subCategory': subCategoryNameCtrl,
      'category': categoryCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'subCategory',
      fieldsToSubmit: ['subCategory', 'category'],
    );
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
                            title: 'Update Sub-Category Detail'),
                        const SizedBox(height: 40),
                        InputField(
                          controller: categoryCtrl,
                          label: 'Category',
                          icon: Icons.category,
                          readOnly: true,
                        ),
                        InputField(
                            controller: subCategoryNameCtrl,
                            label: "Sub-Category Name",
                            icon: Icons.layers),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget: const SubCategoryManagementScreen(),
                              controllers: {
                                'subCategory': subCategoryNameCtrl.text,
                                'category': categoryCtrl.text,
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
