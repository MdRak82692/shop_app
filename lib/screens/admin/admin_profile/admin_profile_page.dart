import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../data_table/admin_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_admin_profile.dart';
import 'edit_admin_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final searchController = TextEditingController();
  String searchQuery = '';
  String? primaryAdminUID;
  String? primaryAdminEmail;
  String? primaryAdminCreationDate;
  String passwordDisplay = '';
  bool isLoading = true;
  List<Map<String, dynamic>> admins = [];

  @override
  void initState() {
    super.initState();
    getPrimaryAdminDetails();
  }

  void getPrimaryAdminDetails() async {
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        primaryAdminUID = user.uid;
        primaryAdminEmail = user.email ?? '';

        if (user.metadata.creationTime != null) {
          primaryAdminCreationDate = DateFormat('dd MMM yyyy hh:mm a')
              .format(user.metadata.creationTime!);
        } else {
          primaryAdminCreationDate = '';
        }

        admins.insert(0, {
          'id': primaryAdminUID,
          'name': 'Primary Admin',
          'email': primaryAdminEmail,
          'time': primaryAdminCreationDate,
          'password': passwordDisplay
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(selectedIndex: 0),
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
                  title: 'Admin Profile',
                  targetWidget: AddAdminProfile(),
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
                          collectionName: 'admin',
                          columnNames: const [
                            'Admin UID',
                            'Admin Name',
                            'Email',
                            'Created Date & Time',
                            'Password'
                          ],
                          columnFieldMapping: const {
                            'Admin UID': 'id',
                            'Admin Name': 'name',
                            'Email': 'email',
                            'Created Date & Time': 'time',
                            'Password': 'password',
                          },
                          items: admins,
                          targetWidget: (userId, userData) {
                            return EditAdminProfile(
                                adminId: userId, adminData: userData);
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
