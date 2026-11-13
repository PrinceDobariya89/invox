import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../auth/providers/auth_provider.dart';

class MainNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktopOrTablet = context.isDesktopOrTablet;
    final isDesktop = context.isDesktop;
    final user = ref.watch(authProvider).value;

    if (isDesktopOrTablet) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              currentIndex: navigationShell.currentIndex,
              isExpanded: isDesktop,
              userBusinessName: user?.businessName ?? 'Invox Enterprises',
              userEmail: user?.email ?? 'admin@invox.com',
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              onLogout: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: navigationShell,
            ),
          ],
        ),
      );
    }

    // Mobile Bottom Navigation
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Customers',
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final bool isExpanded;
  final String userBusinessName;
  final String userEmail;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.isExpanded,
    required this.userBusinessName,
    required this.userEmail,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? 240.0 : 80.0;

    return Container(
      width: width,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment:
            isExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // App Brand Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 20.0 : 12.0,
              vertical: 24.0,
            ),
            child: Row(
              mainAxisAlignment:
                  isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invox',
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'Invoicing & Analytics',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Primary Quick Action: + Create Invoice
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16.0 : 12.0,
              vertical: 8.0,
            ),
            child: isExpanded
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/invoices/create'),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Create Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : IconButton.filled(
                    onPressed: () => context.push('/invoices/create'),
                    icon: const Icon(Icons.add_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Create Bill',
                  ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12.0 : 8.0,
              ),
              children: [
                _NavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: 'Dashboard',
                  isSelected: currentIndex == 0,
                  isExpanded: isExpanded,
                  onTap: () => onDestinationSelected(0),
                ),
                const SizedBox(height: 6),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Invoices',
                  isSelected: currentIndex == 1,
                  isExpanded: isExpanded,
                  onTap: () => onDestinationSelected(1),
                ),
                const SizedBox(height: 6),
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Customers',
                  isSelected: currentIndex == 2,
                  isExpanded: isExpanded,
                  onTap: () => onDestinationSelected(2),
                ),
              ],
            ),
          ),

          // Bottom Account / Business Info & Logout
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(isExpanded ? 16.0 : 8.0),
            child: isExpanded
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          userBusinessName.isNotEmpty
                              ? userBusinessName[0].toUpperCase()
                              : 'I',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userBusinessName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userEmail,
                              style: AppTextStyles.caption.copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18),
                        color: AppColors.textSecondary,
                        tooltip: 'Logout',
                        onPressed: onLogout,
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Logout ($userEmail)',
                    onPressed: onLogout,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeBg = AppColors.primarySurface;
    const activeColor = AppColors.primary;
    const inactiveColor = AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 14.0 : 8.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
