import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) => '₹${NumberFormat('#,##,###').format(amount)}';
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String time(DateTime d) => DateFormat('hh:mm a').format(d);
  static String memberCode(String code) => code; // e.g. CML-AB1234
  
  static String daysRemaining(DateTime endDate) {
    final diff = endDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Expired';
    if (diff == 0) return 'Expires Today';
    return '$diff days';
  }
  
  static String attendancePercent(int present, int total) {
    if (total == 0) return '0%';
    return '${(present / total * 100).toStringAsFixed(0)}%';
  }
}
