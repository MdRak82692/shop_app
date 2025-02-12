import '../../../firestore/update_information.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../utils/slider_bar.dart';
import 'user_management_screen.dart';
import '../../../utils/password_strong.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserScreen(
      {super.key, required this.userId, required this.userData});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final firestore = FirebaseFirestore.instance;
  final userNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isLoading = false;
  String passwordStrength = '';
  final passwordChecker = PasswordStrengthChecker();

  @override
  void initState() {
    super.initState();

    Map<String, TextEditingController> controllers = {
      'userName': userNameCtrl,
      'email': emailCtrl,
      'password': passwordCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'users',
      fieldsToSubmit: ['userName', 'email', 'password'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 2),
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
                        const AddEditTitleSection(title: 'Update User'),
                        const SizedBox(height: 40),
                        InputField(
                          controller: userNameCtrl,
                          label: "User Name",
                          icon: Icons.person,
                        ),
                        InputField(
                          controller: emailCtrl,
                          label: "Email",
                          icon: Icons.email,
                        ),
                        InputField(
                          controller: passwordCtrl,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: true,
                          onChanged: (text) => passwordChecker.isPasswordStrong(
                            text,
                            (s) => setState(() => passwordStrength = s),
                          ),
                        ),
                        buildPasswordStrengthIndicator(passwordStrength),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () async {
                            setState(() => isLoading = true);

                            await updateInformation(
                              context: context,
                              targetWidget: const UserManagementScreen(),
                              controllers: {
                                'userName': userNameCtrl.text,
                                'email': emailCtrl.text,
                                'password': passwordCtrl.text,
                              },
                              name: 'email',
                              option: 'email',
                              firestore: firestore,
                              isLoading: isLoading,
                              setState: setState,
                              passwordChecker: passwordChecker,
                              collectionName: 'users',
                              fieldsToSubmit: ['userName', 'email', 'password'],
                              addTimestamp: false,
                              userId: widget.userId,
                            );

                            setState(() => isLoading = false);
                          },
                          isLoading: isLoading,
                        ),
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
