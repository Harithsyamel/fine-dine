// lib/screens/admin/admin_reservation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/reservation.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminReservationDetailScreen extends StatefulWidget {
  final Reservation reservation;

  const AdminReservationDetailScreen(
      {super.key, required this.reservation});

  @override
  State<AdminReservationDetailScreen> createState() =>
      _AdminReservationDetailScreenState();
}

class _AdminReservationDetailScreenState
    extends State<AdminReservationDetailScreen> {
  late Reservation _res;
  final _db = FirestoreService();
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _res = widget.reservation;
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content:
            Text('Cancel ${_res.userName}\'s booking?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cancelRed),
            child: const Text('Yes',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _cancelling = true);
    await _db.cancelReservation(_res.id);
    if (!mounted) return;
    setState(() {
      _res = _res.copyWith(status: ReservationStatus.cancelled);
      _cancelling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${_res.userName} Reservation'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_res.packageImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                    imageUrl: _res.packageImageUrl,
                    fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 16),

          Row(children: [
            StatusBadge(status: _res.status.name),
          ]),
          const SizedBox(height: 12),

          _card([
            _row('User', _res.userName),
            _row('Email', _res.userEmail),
            _row('Phone', _res.userPhone),
            const Divider(height: 16),
            _row('Package', _res.packageName),
            _row('Date',
                '${_res.eventDate.day}/${_res.eventDate.month}/${_res.eventDate.year}'),
            _row('Time', _res.eventTime),
            _row('Guests', '${_res.numGuests}'),
            _row('Price/Guest',
                'RM ${_res.pricePerGuest.toStringAsFixed(2)}'),
            if (_res.customizationTotal > 0)
              _row('Add-ons',
                  'RM ${_res.customizationTotal.toStringAsFixed(2)}'),
            _row('Total',
                'RM ${_res.totalPrice.toStringAsFixed(2)}',
                bold: true,
                valueColor: AppColors.secondary),
          ]),

          if (_res.additionalPreferences != null &&
              _res.additionalPreferences!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card([
              const Text('Special Requests',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 6),
              Text(_res.additionalPreferences!,
                  style: const TextStyle(
                      color: AppColors.textMedium, fontSize: 13)),
            ]),
          ],

          const SizedBox(height: 24),
          if (_res.status == ReservationStatus.upcoming)
            DangerButton(
              text: 'CANCEL BOOKING',
              onPressed: _cancel,
              isLoading: _cancelling,
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text('$label:',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMedium)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.w500,
                    color: valueColor ?? AppColors.textDark),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
}
