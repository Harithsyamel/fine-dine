// lib/screens/user/user_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/menu_package.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../user/profile_screen.dart';
import '../user/my_reservations_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _navIndex = 0;
  final _db = FirestoreService();
  final _auth = AuthService();
  String _selectedCategory = 'All';
  final _categories = ['All', 'Western', 'Asian', 'Fusion', 'Local'];

  final _pages = const [_HomeTab(), _ReservationsTab(), _ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'My Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Home Tab ──────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _db = FirestoreService();
  String _selectedCategory = 'All';
  final _categories = ['All', 'Western', 'Asian', 'Fusion', 'Local'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: AppColors.secondary, size: 22),
            SizedBox(width: 8),
            Text('Fine-Dine'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/home/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.secondary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.secondary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMedium)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Most Ordered
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Most Ordered',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<MenuPackage>>(
            future: _db.getMostOrdered(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return SizedBox(
                  height: 110,
                  child: Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: Row(
                      children: List.generate(
                          3,
                          (_) => Container(
                              margin: const EdgeInsets.only(left: 16),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)))),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snap.data!.length,
                  itemBuilder: (ctx, i) {
                    final pkg = snap.data![i];
                    return GestureDetector(
                      onTap: () => context.push(
                          '/home/package/${pkg.id}',
                          extra: pkg),
                      child: Container(
                        width: 105,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: pkg.imageUrls.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(pkg.imageUrls.first),
                                  fit: BoxFit.cover)
                              : null,
                          color: AppColors.shimmerBase,
                        ),
                        child: pkg.imageUrls.isEmpty
                            ? const Icon(Icons.restaurant,
                                color: Colors.white54)
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Menu label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Menu',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textDark)),
            ]),
          ),
          const SizedBox(height: 8),

          // Package grid
          Expanded(
            child: StreamBuilder<List<MenuPackage>>(
              stream: _db.packagesStream(
                  category: _selectedCategory == 'All'
                      ? null
                      : _selectedCategory),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(count: 3));
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return const Center(
                      child: Text('No packages available',
                          style: TextStyle(color: AppColors.textLight)));
                }
                final packages = snap.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (ctx, i) => PackageCard(
                    package: packages[i],
                    onTap: () => context.push(
                        '/home/package/${packages[i].id}',
                        extra: packages[i]),
                    onAdd: () => context.push('/home/book',
                        extra: packages[i]),
                    showAdd: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reservations Tab (quick view) ────────────────────────────────────────

class _ReservationsTab extends StatelessWidget {
  const _ReservationsTab();

  @override
  Widget build(BuildContext context) {
    return const MyReservationsScreen();
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

// Imports needed — these are inline to avoid circular import issues
