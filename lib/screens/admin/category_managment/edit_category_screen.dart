import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'category_management_screen.dart';

class EditCategoryScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditCategoryScreen(
      {super.key, required this.userId, required this.userData});

  @override
  EditCategoryScreenState createState() => EditCategoryScreenState();
}

class EditCategoryScreenState extends State<EditCategoryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController categoryNameCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'categoryName': categoryNameCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'category',
      fieldsToSubmit: ['categoryName'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 4),
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
                        const AddEditTitleSection(title: 'Update Category'),
                        const SizedBox(height: 40),
                        InputField(
                            controller: categoryNameCtrl,
                            label: "Category Name",
                            icon: Icons.category),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            await updateInformation(
                              userId: widget.userId,
                              context: context,
                              targetWidget: const CategoryManagementScreen(),
                              controllers: {
                                'categoryName': categoryNameCtrl.text,
                              },
                              name: 'categoryName',
                              option: 'categoryName',
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              collectionName: 'category',
                              fieldsToSubmit: ['categoryName'],
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
