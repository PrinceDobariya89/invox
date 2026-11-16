import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Determine appropriate localhost baseUrl based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // return 'http://127.0.0.1:8000/api';
      return 'http://192.168.31.149/invox_backend/public/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Auth
  static const String login = '/auth/login';

  // Customers
  static const String customers = '/customers';
  static String customerDetail(String id) => '/customers/$id';

  // Invoices
  static const String invoices = '/invoices';
  static String invoiceDetail(String id) => '/invoices/$id';

  // Payments
  static const String payments = '/payments';

  // Analytics
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsMonthly = '/analytics/monthly';
  static const String analyticsYearly = '/analytics/yearly';
  static const String analyticsAging = '/analytics/aging';
}
