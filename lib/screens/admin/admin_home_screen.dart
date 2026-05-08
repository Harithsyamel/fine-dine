// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'admin_users_screen.dart';
import 'admin_packages_screen.dart';
import 'admin_reservations_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _AdminDashboard(),
          AdminReservationsScreen(),
          AdminPackagesScreen(),
          AdminUsersScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Reservations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Packages'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users'),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────

class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();

  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {
  final _auth = AuthService();
  final _db = FirestoreService();

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    context.go('/guest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu,
                color: AppColors.secondary, size: 22),
            SizedBox(width: 8),
            Text('ADMIN Fine-Dine'),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/admin/search')),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats row
          StreamBuilder(
            stream: _db.allReservationsStream(),
            builder: (ctx, snap) {
              final count = snap.data?.length ?? 0;
              final revenue = snap.data
                      ?.where((r) => r.status.name != 'cancelled')
                      .fold(0.0, (sum, r) => sum + r.totalPrice) ??
                  0.0;
              return Row(children: [
                _statCard('Total Bookings', '$count',
                    Icons.calendar_today, AppColors.secondary),
                const SizedBox(width: 12),
                _statCard('Revenue',
                    'RM ${revenue.toStringAsFixed(0)}',
                    Icons.attach_money, AppColors.success),
              ]);
            },
          ),
          const SizedBox(height: 20),

          // Quick actions
          const Text('Quick Actions',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),

          _actionCard('Manage Users', Icons.people_outline,
              'View, edit & delete user accounts', () {
            context.push('/admin/users');
          }),
          const SizedBox(height: 10),
          _actionCard('All Reservations', Icons.calendar_month,
              'View and manage all bookings', () {
            context.push('/admin/reservations');
          }),
          const SizedBox(height: 10),
          _actionCard('Menu Packages', Icons.restaurant_menu_outlined,
              'Add, edit & remove packages', () {
            context.push('/admin/packages');
          }),
          const SizedBox(height: 24),

          // Recent reservations preview
          const Text('Recent Reservations',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: _db.allReservationsStream(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }
              final recent = snap.data!.take(3).toList();
              return Column(
                children: recent.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.person_outline,
                        color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(r.packageName,
                              style: const TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                        'RM ${r.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600)),
                  ]),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight)),
          ]),
        ),
      );

  Widget _actionCard(String title, IconData icon, String subtitle,
      VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textLight),
          ]),
        ),
      );
}

