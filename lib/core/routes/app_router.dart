import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/dashboard_screen.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/customers/presentation/customer_detail_screen.dart';
import '../../features/customers/presentation/customer_list_screen.dart';
import '../../features/invoices/presentation/invoice_create_screen.dart';
import '../../features/invoices/presentation/invoice_detail_screen.dart';
import '../../features/invoices/presentation/invoice_list_screen.dart';
import '../../features/navigation/main_navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _dashboardNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _invoicesNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _customersNavigatorKey =
    GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),

      // Stateful Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard & Analytics
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Invoices
          StatefulShellBranch(
            navigatorKey: _invoicesNavigatorKey,
            routes: [
              GoRoute(
                path: '/invoices',
                name: 'invoices',
                builder: (context, state) => const InvoiceListScreen(),
              ),
            ],
          ),

          // Branch 2: Customers
          StatefulShellBranch(
            navigatorKey: _customersNavigatorKey,
            routes: [
              GoRoute(
                path: '/customers',
                name: 'customers',
                builder: (context, state) => const CustomerListScreen(),
              ),
            ],
          ),
        ],
      ),

      // Deep Routes (Push on top of Shell)
      GoRoute(
        path: '/invoices/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customer_id'];
          return InvoiceCreateScreen(initialCustomerId: customerId);
        },
      ),
      GoRoute(
        path: '/invoices/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/customers/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomerDetailScreen(customerId: id);
        },
      ),
    ],
  );
});
