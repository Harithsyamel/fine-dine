// lib/screens/admin/admin_reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/reservation.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState
    extends State<AdminReservationsScreen>
    with SingleTickerProviderStateMixin {
  final _db = FirestoreService();
  late TabController _tabCtrl;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Reservations'),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.secondary,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by user or package...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Reservation>>(
              stream: _db.allReservationsStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(count: 5));
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return const Center(
                      child: Text('No reservations found.',
                          style:
                              TextStyle(color: AppColors.textLight)));
                }

                var all = snap.data!;
                if (_search.isNotEmpty) {
                  all = all
                      .where((r) =>
                          r.userName.toLowerCase().contains(_search) ||
                          r.packageName.toLowerCase().contains(_search))
                      .toList();
                }

                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(all),
                    _buildList(all
                        .where((r) =>
                            r.status == ReservationStatus.upcoming)
                        .toList()),
                    _buildList(all
                        .where((r) =>
                            r.status == ReservationStatus.cancelled)
                        .toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Reservation> items) {
    if (items.isEmpty) {
      return const Center(
          child: Text('No reservations in this category.',
              style: TextStyle(color: AppColors.textLight)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final r = items[i];
        return GestureDetector(
          onTap: () => context.push('/admin/reservations/${r.id}',
              extra: r),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                child: SizedBox(
                  width: 90,
                  height: 85,
                  child: r.packageImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: r.packageImageUrl,
                          fit: BoxFit.cover)
                      : Container(
                          color: AppColors.shimmerBase,
                          child: const Icon(Icons.restaurant,
                              color: Colors.white54)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(r.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                        StatusBadge(status: r.status.name),
                      ]),
                      const SizedBox(height: 3),
                      Text(r.packageName,
                          style: const TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(
                          '${r.eventDate.day}/${r.eventDate.month}/${r.eventDate.year} · ${r.numGuests} guests',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight)),
                      Text('RM ${r.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right,
                    color: AppColors.textLight),
              ),
            ]),
          ),
        );
      },
    );
  }
}
