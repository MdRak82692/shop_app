import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/password_strong.dart';
import 'user_management_screen.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  AddUserScreenState createState() => AddUserScreenState();
}

class AddUserScreenState extends State<AddUserScreen> {
  final firestore = FirebaseFirestore.instance;
  final userNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLoading = false;
  String passwordStrength = '';
  final passwordChecker = PasswordStrengthChecker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 1),
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
                          title: 'Add New User',
                          targetWidget: () => const UserManagementScreen(),
                        ),
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

                            await addInformation(
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
                              addTimestamp: true,
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
