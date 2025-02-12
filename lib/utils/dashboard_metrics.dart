import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, double>> fetchDashboardMetrics() async {
  final firestore = FirebaseFirestore.instance;
  final metrics = {
    'totalUsers': 0.0,
    'totalCost': 0.0,
    'totalSale': 0.0,
    'dailyCost': 0.0,
    'dailySale': 0.0,
    'dailyProfit': 0.0,
    'dailyStaffSalary': 0.0,
    'totalStaffSalary': 0.0,
    'totalProfit': 0.0,
    'totalStaff': 0.0,
    'dailyInvestment': 0.0,
    'dailyOtherCost': 0.0,
    'totalInvestment': 0.0,
    'totalOtherCost': 0.0,
  };

  double safeDouble(dynamic value) {
    return (value is num) ? value.toDouble() : 0.0;
  }

  try {
    final userSnapshot = await firestore.collection('users').get();
    final orderSnapshot = await firestore.collection('sales').get();
    final productSnapshot = await firestore.collection('products').get();
    final staffSnapshot = await firestore.collection('staff').get();
    final staffSalarySnapshot = await firestore.collection('staffsalary').get();
    final investmentSnapshot = await firestore.collection('investment').get();
    final otherCostSnapshot = await firestore.collection('otherCost').get();

    metrics['totalUsers'] = userSnapshot.size.toDouble();
    metrics['totalStaff'] = staffSnapshot.size.toDouble();

    metrics['totalInvestment'] = investmentSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['sale']));
    metrics['totalOtherCost'] = otherCostSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['cost']));
    metrics['totalCost'] = productSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['cost']));
    metrics['totalSale'] = orderSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['sale']));
    metrics['totalStaffSalary'] = staffSalarySnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['salary']));

    metrics['totalProfit'] = (metrics['totalInvestment'] ?? 0.0) +
        (metrics['totalSale'] ?? 0.0) -
        (metrics['totalCost'] ?? 0.0) -
        (metrics['totalOtherCost'] ?? 0.0) -
        (metrics['totalStaffSalary'] ?? 0.0);

    final now = DateTime.now();
    final todayStart =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final todayEnd =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final dailyInvestmentSnapshot = await firestore
        .collection('investment')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyInvestment'] = dailyInvestmentSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['sale']));

    final dailyOtherCostSnapshot = await firestore
        .collection('otherCost')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyOtherCost'] = dailyOtherCostSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['cost']));

    final dailyCostSnapshot = await firestore
        .collection('products')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyCost'] = dailyCostSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['cost']));

    final dailySalesSnapshot = await firestore
        .collection('sales')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailySale'] = dailySalesSnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['sale']));

    final dailyStaffSalarySnapshot = await firestore
        .collection('staffsalary')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyStaffSalary'] = dailyStaffSalarySnapshot.docs
        .fold<double>(0.0, (total, doc) => total + safeDouble(doc['salary']));

    metrics['dailyProfit'] = (metrics['dailyInvestment'] ?? 0.0) +
        (metrics['dailySale'] ?? 0.0) -
        (metrics['dailyCost'] ?? 0.0) -
        (metrics['dailyOtherCost'] ?? 0.0) -
        (metrics['dailyStaffSalary'] ?? 0.0);
  } catch (e) {
    return {};
  }

  return metrics;
}
