// lib/screens/user/booking_success_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState
    extends State<BookingSuccessScreen> {
  double _rating = 0;

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
            Text('Fine-Dine'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: AppColors.success, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text('Reservation has\nbeen placed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.3)),
                  const SizedBox(height: 10),
                  const Text('Thank you for booking with us.',
                      style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 14)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Rate your experience',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _rating = (i + 1).toDouble()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          child: Icon(
                            i < _rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.secondary,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
              const SizedBox(height: 32),
              GoldButton(
                text: 'GO BACK TO HOME',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    context.go('/home/reservations'),
                child: const Text('View My Reservations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
