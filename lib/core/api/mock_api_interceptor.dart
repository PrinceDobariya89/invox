import 'package:dio/dio.dart';
import 'api_endpoints.dart';

/// In-memory mock database and interceptor that satisfies all REST API contracts.
/// Seamlessly intercepts requests when mock mode is enabled or backend is unavailable.
class MockApiInterceptor extends Interceptor {
  // In-memory data stores (Clean Non-GST Paver Blocks Billing)
  static final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'Patel Construction Co.',
      'phone': '+91 98250 11223',
      'email': 'contact@patelconstruction.in',
      'address': 'Near Shital Park, 150 Feet Ring Road, Rajkot, Gujarat',
      'gstin': '',
      'total_billed': 133000.0,
      'total_paid': 80000.0,
      'outstanding_balance': 53000.0,
      'created_at': '2026-02-01T10:00:00Z',
    },
    {
      'id': '2',
      'name': 'Shreeji Infrastructure & Developers',
      'phone': '+91 94280 44556',
      'email': 'accounts@shreejigroup.in',
      'address': 'Plot No. 42, GIDC Phase 2, Morbi, Gujarat',
      'gstin': '',
      'total_billed': 196000.0,
      'total_paid': 196000.0,
      'outstanding_balance': 0.0,
      'created_at': '2026-02-05T11:30:00Z',
    },
    {
      'id': '3',
      'name': 'Maruti Enterprise (Contractor)',
      'phone': '+91 99090 77889',
      'email': 'marutipavers@gmail.com',
      'address': 'Opp. Crystal Mall, Kalawad Road, Rajkot, Gujarat',
      'gstin': '',
      'total_billed': 78600.0,
      'total_paid': 0.0,
      'outstanding_balance': 78600.0,
      'created_at': '2026-02-10T09:15:00Z',
    },
    {
      'id': '4',
      'name': 'Jay Ambe Builders',
      'phone': '+91 97120 33445',
      'email': 'jayambebuilders@yahoo.com',
      'address': 'Near Bus Station, Gondal, Gujarat',
      'gstin': '',
      'total_billed': 44400.0,
      'total_paid': 0.0,
      'outstanding_balance': 44400.0,
      'created_at': '2026-01-20T14:20:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _invoices = [
    {
      'id': '1',
      'customer_id': '1',
      'customer_name': 'Patel Construction Co.',
      'invoice_number': 'INV-2026-001',
      'date': '2026-02-05',
      'due_date': '2026-02-20',
      'status': 'PARTIAL',
      'site_location': 'Dream Heights, 150 Ft Ring Road, Rajkot',
      'vehicle_no': 'GJ-03-BW-4512',
      'challan_no': 'CH-8821',
      'subtotal': 133000.0,
      'tax_amount': 0.0,
      'discount_amount': 0.0,
      'total_amount': 133000.0,
      'amount_paid': 80000.0,
      'balance_amount': 53000.0,
      'notes': 'Zig-Zag 60mm M30 grade Paver Blocks delivered at site.',
      'items': [
        {
          'description': 'Zig-Zag Paver Blocks (60mm Heavy Duty - M30 Grade)',
          'unit': 'Sq. Ft.',
          'qty': 2500.0,
          'rate': 38.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 95000.0,
        },
        {
          'description': 'Kerb Stones (300x300x100mm)',
          'unit': 'Pcs',
          'qty': 300.0,
          'rate': 110.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 33000.0,
        },
        {
          'description': 'Tractor Freight & Unloading Charges',
          'unit': 'Trips',
          'qty': 2.0,
          'rate': 2500.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 5000.0,
        },
      ],
    },
    {
      'id': '2',
      'customer_id': '2',
      'customer_name': 'Shreeji Infrastructure & Developers',
      'invoice_number': 'INV-2026-002',
      'date': '2026-02-12',
      'due_date': '2026-02-27',
      'status': 'PAID',
      'site_location': 'Shreeji Industrial Park, Morbi Highway',
      'vehicle_no': 'GJ-36-T-8890',
      'challan_no': 'CH-8840',
      'subtotal': 196000.0,
      'tax_amount': 0.0,
      'discount_amount': 0.0,
      'total_amount': 196000.0,
      'amount_paid': 196000.0,
      'balance_amount': 0.0,
      'notes': 'Full industrial lot laying completed.',
      'items': [
        {
          'description': 'I-Shape Paver Blocks (80mm Industrial Grade)',
          'unit': 'Sq. Ft.',
          'qty': 4000.0,
          'rate': 42.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 168000.0,
        },
        {
          'description': 'Laying & Sand Levelling Labour Work',
          'unit': 'Sq. Ft.',
          'qty': 4000.0,
          'rate': 7.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 28000.0,
        },
      ],
    },
    {
      'id': '3',
      'customer_id': '3',
      'customer_name': 'Maruti Enterprise (Contractor)',
      'invoice_number': 'INV-2026-003',
      'date': '2026-02-18',
      'due_date': '2026-03-05',
      'status': 'UNPAID',
      'site_location': 'Row Houses Scheme, Kalawad Road',
      'vehicle_no': 'GJ-03-BX-1029',
      'challan_no': 'CH-8865',
      'subtotal': 78600.0,
      'tax_amount': 0.0,
      'discount_amount': 0.0,
      'total_amount': 78600.0,
      'amount_paid': 0.0,
      'balance_amount': 78600.0,
      'notes': 'Payment due within 15 days.',
      'items': [
        {
          'description': 'Cosmic / Star Paver Blocks (Red & Yellow 60mm)',
          'unit': 'Sq. Ft.',
          'qty': 1800.0,
          'rate': 40.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 72000.0,
        },
        {
          'description': 'Stone Dust / Stone Powder Fillings',
          'unit': 'Brass',
          'qty': 3.0,
          'rate': 2200.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 6600.0,
        },
      ],
    },
    {
      'id': '4',
      'customer_id': '4',
      'customer_name': 'Jay Ambe Builders',
      'invoice_number': 'INV-2026-004',
      'date': '2026-01-20',
      'due_date': '2026-02-05',
      'status': 'UNPAID',
      'site_location': 'Residency Scheme, Gondal',
      'vehicle_no': 'GJ-03-AZ-7711',
      'challan_no': 'CH-8790',
      'subtotal': 44400.0,
      'tax_amount': 0.0,
      'discount_amount': 0.0,
      'total_amount': 44400.0,
      'amount_paid': 0.0,
      'balance_amount': 44400.0,
      'notes': 'Payment overdue by customer.',
      'items': [
        {
          'description': 'Dumbbell / Dog-Bone Paver (60mm)',
          'unit': 'Sq. Ft.',
          'qty': 1200.0,
          'rate': 37.0,
          'discount': 0.0,
          'tax': 0.0,
          'amount': 44400.0,
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> _payments = [
    {
      'id': '1',
      'invoice_id': '1',
      'invoice_number': 'INV-2026-001',
      'customer_id': '1',
      'customer_name': 'Patel Construction Co.',
      'amount': 80000.0,
      'payment_mode': 'Bank Transfer',
      'reference_no': 'UTR88291039',
      'payment_date': '2026-02-08',
      'notes': 'Part payment received via RTGS',
    },
    {
      'id': '2',
      'invoice_id': '2',
      'invoice_number': 'INV-2026-002',
      'customer_id': '2',
      'customer_name': 'Shreeji Infrastructure & Developers',
      'amount': 196000.0,
      'payment_mode': 'Cheque',
      'reference_no': 'CHQ-554412',
      'payment_date': '2026-02-15',
      'notes': 'Full payment settled against invoice',
    },
  ];

  void _resolve(RequestInterceptorHandler handler, Response response) {
    handler.resolve(response, true);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Artificial slight latency for realistic network experience
    await Future.delayed(const Duration(milliseconds: 150));

    final path = options.path;
    final method = options.method.toUpperCase();

    // 1. Auth: POST /api/auth/login
    if (path.endsWith(ApiEndpoints.login) && method == 'POST') {
      final email = options.data['email'] ?? 'admin@invox.com';
      return _resolve(
        handler,
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'token': 'mock_sanctum_token_paver_blocks_2026',
            'user': {
              'id': '1',
              'name': 'Prince Dobariya',
              'email': email,
              'business_name': 'Shreeji Paver Blocks & Precast',
              'gstin': '',
              'currency': 'INR',
            },
          },
        ),
      );
    }

    // 2. Customers List: GET /api/customers
    if (path.endsWith(ApiEndpoints.customers) && method == 'GET') {
      final search = options.queryParameters['search']?.toString().toLowerCase();
      var result = List<Map<String, dynamic>>.from(_customers);
      if (search != null && search.isNotEmpty) {
        result = result
            .where((c) =>
                (c['name'] as String).toLowerCase().contains(search) ||
                (c['phone'] as String).toLowerCase().contains(search))
            .toList();
      }
      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }

    // Customer Detail: GET /api/customers/{id}
    final customerDetailRegex = RegExp(r'/customers/([^/?]+)$');
    if (customerDetailRegex.hasMatch(path) && method == 'GET') {
      final match = customerDetailRegex.firstMatch(path);
      final id = match?.group(1);
      final customer = _customers.firstWhere(
        (c) => c['id'] == id,
        orElse: () => _customers.first,
      );

      final customerInvoices = _invoices.where((i) => i['customer_id'] == id).toList();
      final customerPayments = _payments.where((p) => p['customer_id'] == id).toList();

      final responseData = Map<String, dynamic>.from(customer);
      responseData['invoices'] = customerInvoices;
      responseData['payments'] = customerPayments;

      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: responseData),
      );
    }

    // Customer Create: POST /api/customers
    if (path.endsWith(ApiEndpoints.customers) && method == 'POST') {
      final data = options.data as Map<String, dynamic>;
      final newCustomer = {
        'id': 'cust_${DateTime.now().millisecondsSinceEpoch}',
        'name': data['name'] ?? 'New Customer',
        'phone': data['phone'] ?? '',
        'email': data['email'] ?? '',
        'address': data['address'] ?? '',
        'gstin': data['gstin'] ?? '',
        'total_billed': 0.0,
        'total_paid': 0.0,
        'outstanding_balance': 0.0,
        'created_at': DateTime.now().toIso8601String(),
      };
      _customers.insert(0, newCustomer);
      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 201, data: newCustomer),
      );
    }

    // 3. Invoices List: GET /api/invoices
    if (path.endsWith(ApiEndpoints.invoices) && method == 'GET') {
      final customerId = options.queryParameters['customer_id']?.toString();
      final status = options.queryParameters['status']?.toString();
      final search = options.queryParameters['search']?.toString().toLowerCase();

      var result = List<Map<String, dynamic>>.from(_invoices);
      if (customerId != null && customerId.isNotEmpty) {
        result = result.where((i) => i['customer_id'] == customerId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'ALL') {
        result = result.where((i) => i['status'] == status).toList();
      }
      if (search != null && search.isNotEmpty) {
        result = result
            .where((i) =>
                (i['invoice_number'] as String).toLowerCase().contains(search) ||
                (i['customer_name'] as String).toLowerCase().contains(search))
            .toList();
      }
      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }

    // Invoice Detail: GET /api/invoices/{id}
    final invoiceDetailRegex = RegExp(r'/invoices/([^/?]+)$');
    if (invoiceDetailRegex.hasMatch(path) && method == 'GET') {
      final match = invoiceDetailRegex.firstMatch(path);
      final id = match?.group(1);
      final invoice = _invoices.firstWhere(
        (i) => i['id'] == id,
        orElse: () => _invoices.first,
      );
      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: invoice),
      );
    }

    // Invoice Create: POST /api/invoices
    if (path.endsWith(ApiEndpoints.invoices) && method == 'POST') {
      final data = options.data as Map<String, dynamic>;
      final rawItems = (data['items'] as List?) ?? [];

      double subtotal = 0.0;
      double totalDiscount = 0.0;
      final items = <Map<String, dynamic>>[];

      for (final item in rawItems) {
        final qty = (item['qty'] as num?)?.toDouble() ?? 0.0;
        final rate = (item['rate'] as num?)?.toDouble() ?? 0.0;
        final disc = (item['discount'] as num?)?.toDouble() ?? 0.0;
        final base = qty * rate;
        final discAmount = base * (disc / 100);
        final lineTotal = base - discAmount;

        subtotal += base;
        totalDiscount += discAmount;

        items.add({
          'description': item['description'] ?? '',
          'unit': item['unit'] ?? 'Sq. Ft.',
          'qty': qty,
          'rate': rate,
          'discount': disc,
          'tax': 0.0,
          'amount': lineTotal,
        });
      }

      final grandTotal = subtotal - totalDiscount;
      final customerId = data['customer_id']?.toString() ?? '';
      final customer = _customers.firstWhere(
        (c) => c['id'] == customerId,
        orElse: () => {'name': 'Valued Client'},
      );

      final newInvoice = {
        'id': 'inv_${DateTime.now().millisecondsSinceEpoch}',
        'customer_id': customerId,
        'customer_name': customer['name'],
        'invoice_number': data['invoice_number'] ?? 'INV-PREVIEW',
        'date': data['date'] ?? DateTime.now().toIso8601String().substring(0, 10),
        'due_date': data['due_date'] ?? DateTime.now().add(const Duration(days: 15)).toIso8601String().substring(0, 10),
        'status': 'UNPAID',
        'site_location': data['site_location'] ?? '',
        'vehicle_no': data['vehicle_no'] ?? '',
        'challan_no': data['challan_no'] ?? '',
        'subtotal': subtotal,
        'tax_amount': 0.0,
        'discount_amount': totalDiscount,
        'total_amount': grandTotal,
        'amount_paid': 0.0,
        'balance_amount': grandTotal,
        'notes': data['notes'] ?? '',
        'items': items,
      };

      _invoices.insert(0, newInvoice);

      // Update customer balance
      final custIdx = _customers.indexWhere((c) => c['id'] == customerId);
      if (custIdx != -1) {
        _customers[custIdx]['total_billed'] = (_customers[custIdx]['total_billed'] as double) + grandTotal;
        _customers[custIdx]['outstanding_balance'] = (_customers[custIdx]['outstanding_balance'] as double) + grandTotal;
      }

      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 201, data: newInvoice),
      );
    }

    // 4. Payment Create: POST /api/payments
    if (path.endsWith(ApiEndpoints.payments) && method == 'POST') {
      final data = options.data as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final invoiceId = data['invoice_id']?.toString() ?? '';
      final customerId = data['customer_id']?.toString() ?? '';

      final invoice = _invoices.firstWhere(
        (i) => i['id'] == invoiceId,
        orElse: () => {'invoice_number': 'INV-N/A'},
      );
      final customer = _customers.firstWhere(
        (c) => c['id'] == customerId,
        orElse: () => {'name': 'Customer'},
      );

      final newPayment = {
        'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
        'invoice_id': invoiceId,
        'invoice_number': invoice['invoice_number'],
        'customer_id': customerId,
        'customer_name': customer['name'],
        'amount': amount,
        'payment_mode': data['payment_mode'] ?? 'Cash',
        'reference_no': data['reference_no'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'payment_date': data['payment_date'] ?? DateTime.now().toIso8601String().substring(0, 10),
        'notes': data['notes'] ?? '',
      };

      _payments.insert(0, newPayment);

      // Update Invoice Status
      final invIdx = _invoices.indexWhere((i) => i['id'] == invoiceId);
      if (invIdx != -1) {
        final currentPaid = (_invoices[invIdx]['amount_paid'] as double) + amount;
        final total = _invoices[invIdx]['total_amount'] as double;
        final newBalance = total - currentPaid;

        _invoices[invIdx]['amount_paid'] = currentPaid;
        _invoices[invIdx]['balance_amount'] = newBalance <= 0 ? 0.0 : newBalance;
        _invoices[invIdx]['status'] = newBalance <= 0 ? 'PAID' : 'PARTIAL';
      }

      // Update Customer Total Paid & Outstanding
      final custIdx = _customers.indexWhere((c) => c['id'] == customerId);
      if (custIdx != -1) {
        final currentPaid = (_customers[custIdx]['total_paid'] as double) + amount;
        final currentOutstanding = (_customers[custIdx]['outstanding_balance'] as double) - amount;

        _customers[custIdx]['total_paid'] = currentPaid;
        _customers[custIdx]['outstanding_balance'] = currentOutstanding <= 0 ? 0.0 : currentOutstanding;
      }

      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 201, data: newPayment),
      );
    }

    // Payments List: GET /api/payments
    if (path.endsWith(ApiEndpoints.payments) && method == 'GET') {
      final invoiceId = options.queryParameters['invoice_id']?.toString();
      var result = List<Map<String, dynamic>>.from(_payments);
      if (invoiceId != null && invoiceId.isNotEmpty) {
        result = result.where((p) => p['invoice_id'] == invoiceId).toList();
      }
      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }

    // 5. Analytics Summary: GET /api/analytics/summary
    if (path.endsWith(ApiEndpoints.analyticsSummary) && method == 'GET') {
      double totalBilled = 0.0;
      double totalCollected = 0.0;
      double totalOutstanding = 0.0;
      double overdueAmount = 0.0;
      final now = DateTime.now();

      for (final inv in _invoices) {
        final billed = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
        final paid = (inv['amount_paid'] as num?)?.toDouble() ?? 0.0;
        final balance = (inv['balance_amount'] as num?)?.toDouble() ?? 0.0;
        totalBilled += billed;
        totalCollected += paid;
        totalOutstanding += balance;

        final dueDate = DateTime.tryParse(inv['due_date'] ?? '');
        if (balance > 0 && dueDate != null && dueDate.isBefore(now)) {
          overdueAmount += balance;
        }
      }

      return _resolve(
        handler,
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'total_billed': totalBilled,
            'total_collected': totalCollected,
            'total_outstanding': totalOutstanding,
            'overdue_amount': overdueAmount,
            'total_invoices_count': _invoices.length,
            'unpaid_invoices_count': _invoices.where((i) => i['status'] != 'PAID').length,
          },
        ),
      );
    }

    // Analytics Monthly: GET /api/analytics/monthly?year=2026&month=02
    if (path.endsWith(ApiEndpoints.analyticsMonthly) && method == 'GET') {
      final year = int.tryParse(options.queryParameters['year']?.toString() ?? '2026') ?? 2026;
      final month = int.tryParse(options.queryParameters['month']?.toString() ?? '2') ?? 2;

      final monthlyData = {
        'year': year,
        'month': month,
        'sales': 407600.0,
        'collections': 276000.0,
        'pending_invoices_count': 2,
        'pending_amount': 131600.0,
        'paid_invoices_count': 1,
      };

      return _resolve(
        handler,
        Response(requestOptions: options, statusCode: 200, data: monthlyData),
      );
    }

    // Analytics Yearly: GET /api/analytics/yearly?year=2026
    if (path.endsWith(ApiEndpoints.analyticsYearly) && method == 'GET') {
      final year = int.tryParse(options.queryParameters['year']?.toString() ?? '2026') ?? 2026;

      final monthsTrend = [
        {'month': 1, 'month_name': 'Jan', 'billed': 44400.0, 'collected': 0.0, 'outstanding': 44400.0},
        {'month': 2, 'month_name': 'Feb', 'billed': 407600.0, 'collected': 276000.0, 'outstanding': 131600.0},
        {'month': 3, 'month_name': 'Mar', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 4, 'month_name': 'Apr', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 5, 'month_name': 'May', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 6, 'month_name': 'Jun', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 7, 'month_name': 'Jul', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 8, 'month_name': 'Aug', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 9, 'month_name': 'Sep', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 10, 'month_name': 'Oct', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 11, 'month_name': 'Nov', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
        {'month': 12, 'month_name': 'Dec', 'billed': 0.0, 'collected': 0.0, 'outstanding': 0.0},
      ];

      return _resolve(
        handler,
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'year': year,
            'trends': monthsTrend,
          },
        ),
      );
    }

    // Analytics Aging: GET /api/analytics/aging
    if (path.endsWith(ApiEndpoints.analyticsAging) && method == 'GET') {
      return _resolve(
        handler,
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'bucket_0_30': 176000.0,
            'bucket_31_60': 0.0,
            'bucket_60_plus': 0.0,
            'total_aging_outstanding': 176000.0,
          },
        ),
      );
    }

    // Default: continue to network
    return handler.next(options);
  }
}
