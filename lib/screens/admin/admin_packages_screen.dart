// lib/screens/admin/admin_packages_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/menu_package.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminPackagesScreen extends StatefulWidget {
  const AdminPackagesScreen({super.key});

  @override
  State<AdminPackagesScreen> createState() =>
      _AdminPackagesScreenState();
}

class _AdminPackagesScreenState extends State<AdminPackagesScreen> {
  final _db = FirestoreService();
  String _search = '';

  Future<void> _delete(MenuPackage pkg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Delete "${pkg.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cancelRed),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) await _db.deletePackage(pkg.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu Packages'),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/packages/add'),
            tooltip: 'Add Package',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search packages...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  setState(() => _search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MenuPackage>>(
              stream: _db.allPackagesStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(count: 4));
                }
                var pkgs = snap.data ?? [];
                if (_search.isNotEmpty) {
                  pkgs = pkgs
                      .where((p) =>
                          p.name.toLowerCase().contains(_search) ||
                          p.category.toLowerCase().contains(_search))
                      .toList();
                }
                if (pkgs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant_menu,
                            size: 56, color: AppColors.textLight),
                        const SizedBox(height: 10),
                        const Text('No packages found',
                            style: TextStyle(
                                color: AppColors.textLight)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/admin/packages/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Package'),
                        ),
                      ],
                    ),
                  );
                }

                // Most ordered + full list
                final mostOrdered = pkgs
                    .where((p) => p.orderCount > 0)
                    .toList()
                  ..sort((a, b) =>
                      b.orderCount.compareTo(a.orderCount));

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    if (mostOrdered.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Most Ordered',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              mostOrdered.take(5).length,
                          itemBuilder: (ctx, i) {
                            final p = mostOrdered[i];
                            return GestureDetector(
                              onTap: () => context.push(
                                  '/admin/packages/edit',
                                  extra: p),
                              child: Container(
                                width: 100,
                                margin:
                                    const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  image: p.imageUrls.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              p.imageUrls.first),
                                          fit: BoxFit.cover)
                                      : null,
                                  color: AppColors.shimmerBase,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('All Packages',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                    ...pkgs.map((pkg) => _packageTile(pkg)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/packages/add'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _packageTile(MenuPackage pkg) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12)),
            child: SizedBox(
              width: 80,
              height: 75,
              child: pkg.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: pkg.imageUrls.first,
                      fit: BoxFit.cover)
                  : Container(
                      color: AppColors.shimmerBase,
                      child: const Icon(Icons.restaurant,
                          color: Colors.white54)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(
                    '${pkg.category} · RM ${pkg.pricePerGuest.toStringAsFixed(0)}/pax',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium)),
                Text('${pkg.orderCount} orders',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary)),
              ],
            ),
          ),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.primary, size: 20),
              onPressed: () =>
                  context.push('/admin/packages/edit', extra: pkg),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.cancelRed, size: 20),
              onPressed: () => _delete(pkg),
            ),
          ]),
        ]),
      );
}
