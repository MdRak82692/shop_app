import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/category_managment/category_management_screen.dart';
import '../screens/admin/existing_product/existing_product_management_screen.dart';
import '../screens/admin/inventory_log/inventory_log_management_screen.dart';
import '../screens/admin/investment_managment/investment_management_screen.dart';
import '../screens/admin/other_cost_managment/other_cost_management_screen.dart';
import '../screens/admin/product_list/product_list_management_screen.dart';
import '../screens/admin/product_price/product_price_management_screen.dart';
import '../screens/admin/products_sale/products_sale.dart';
import '../screens/admin/profit/profit.dart';
import '../screens/admin/purchase_products/purchase_products.dart';
import '../screens/admin/sales_analytics/sales_analytics.dart';
import '../screens/admin/sales_&_finance/sale_finance_screen.dart';
import '../screens/admin/staff_management/staff_management_screen.dart';
import '../screens/admin/staff_salary_management/staff_salary_management_screen.dart';
import '../screens/admin/sub_category/sub_category_management_screen.dart';
import '../screens/admin/users_management/user_management_screen.dart';
import '../screens/login_page.dart';
import '../utils/text.dart';

class BuildSidebar extends StatefulWidget {
  final int selectedIndex;

  const BuildSidebar({super.key, required this.selectedIndex});

  @override
  BuildSidebarState createState() => BuildSidebarState();
}

class BuildSidebarState extends State<BuildSidebar> {
  bool isExpanded = true;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void navigateToPage(BuildContext context, Widget targetPage, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Row(
            children: [
              Expanded(child: targetPage),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 220 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(75),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (isExpanded)
                  Text('Manik Store\nAdmin',
                      style: style(24, color: Colors.blue)),
                const Spacer(),
                IconButton(
                  icon: Icon(
                      isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                      color: Colors.white),
                  onPressed: toggleSidebar,
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[700], height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildSidebarTile(context, Icons.dashboard, 'Dashboard',
                      const AdminDashboard(), 0),
                  buildSidebarTile(context, Icons.shopping_cart,
                      'Purchase Products', const PurchaseProducts(), 9),
                  buildSidebarTile(context, Icons.sell, 'Products Sale',
                      const ProductsSale(), 10),
                  buildSidebarTile(context, Icons.verified_user,
                      'Users Management', const UserManagementScreen(), 1),
                  buildSidebarTile(context, Icons.trending_up, 'Investment',
                      const InvestmentManagementScreen(), 2),
                  buildSidebarTile(context, Icons.money_off, 'Other Cost',
                      const OtherCostManagementScreen(), 3),
                  buildSidebarTile(context, Icons.category, 'Category',
                      const CategoryManagementScreen(), 4),
                  buildSidebarTile(context, Icons.layers, 'Sub-Category',
                      const SubCategoryManagementScreen(), 5),
                  buildSidebarTile(context, Icons.production_quantity_limits,
                      'Product List', const ProductListManagementScreen(), 6),
                  buildSidebarTile(context, Icons.price_check, 'Product Price',
                      const ProductPriceManagementScreen(), 7),
                  buildSidebarTile(
                      context,
                      Icons.inventory,
                      'Existing Products',
                      const ExistingProductManagementScreen(),
                      8),
                  buildSidebarTile(context, Icons.article, 'Inventory Log',
                      const InventoryLogManagementScreen(), 11),
                  buildSidebarTile(context, Icons.people, 'Staff Management',
                      const StaffManagementScreen(), 12),
                  buildSidebarTile(context, Icons.account_balance_wallet,
                      'Staff Salary', const StaffSalaryManagementScreen(), 13),
                  buildSidebarTile(context, Icons.analytics, 'Sales & Finance',
                      const SaleFinanceScreen(), 14),
                  buildSidebarTile(context, Icons.bar_chart, 'Sales Analytics',
                      const SalesAnalytics(), 15),
                  buildSidebarTile(context, Icons.attach_money, 'Profit',
                      const Profit(), 16),
                  buildSidebarTile(
                      context, Icons.logout, "Log Out", const LoginPage(), 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarTile(BuildContext context, IconData icon, String title,
      Widget targetPage, int index) {
    bool isSelected = widget.selectedIndex == index;
    return InkWell(
      onTap: () => navigateToPage(context, targetPage, index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.blue.shade700, Colors.blue.shade600]
                : [Colors.blueGrey.shade800, Colors.blueGrey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(75),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: isExpanded
              ? Text(title,
                  style: style1(16,
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal))
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
    );
  }
}
