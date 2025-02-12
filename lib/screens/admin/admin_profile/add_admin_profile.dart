import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/slider_bar.dart';
import 'admin_profile_page.dart';
import '../../../utils/password_strong.dart';

class AddAdminProfile extends StatefulWidget {
  const AddAdminProfile({
    super.key,
  });

  @override
  AddAdminProfileState createState() => AddAdminProfileState();
}

class AddAdminProfileState extends State<AddAdminProfile> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  final adminNameCtrl = TextEditingController();
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
          const BuildSidebar(selectedIndex: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: Colors.black.withAlpha(50),
                child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AddEditTitleSection(
                              title: 'Add New Admin Profile'),
                          const SizedBox(height: 40),
                          InputField(
                              controller: adminNameCtrl,
                              label: "Admin Name",
                              icon: Icons.person),
                          InputField(
                              controller: emailCtrl,
                              label: "Email",
                              icon: Icons.email),
                          InputField(
                              controller: passwordCtrl,
                              label: "Password",
                              icon: Icons.lock,
                              obscure: true,
                              onChanged: (text) =>
                                  passwordChecker.isPasswordStrong(
                                      text,
                                      (s) => setState(
                                          () => passwordStrength = s))),
                          buildPasswordStrengthIndicator(passwordStrength),
                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: () async {
                              await addInformation(
                                context: context,
                                targetWidget: const ProfilePage(),
                                controllers: {
                                  'name': adminNameCtrl.text,
                                  'email': emailCtrl.text,
                                  'password': passwordCtrl.text,
                                },
                                name: 'email',
                                option: 'email',
                                firestore: firestore,
                                isLoading: isLoading,
                                setState: setState,
                                passwordChecker: passwordChecker,
                                collectionName: 'admin',
                                fieldsToSubmit: ['name', 'email', 'password'],
                                addTimestamp: true,
                                name1: '',
                                option1: '',
                              );
                            },
                            isLoading: isLoading,
                          )
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
