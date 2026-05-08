// lib/screens/admin/admin_user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final UserModel user;
  final bool isEdit;

  const AdminUserDetailScreen(
      {super.key, required this.user, this.isEdit = false});

  @override
  State<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState
    extends State<AdminUserDetailScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isSaving = false;
  final _db = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _db.updateUserByAdmin(widget.user.uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User updated successfully'),
        backgroundColor: AppColors.success,
      ));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage ${widget.user.name}'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                backgroundImage: widget.user.profileImageUrl != null
                    ? NetworkImage(widget.user.profileImageUrl!)
                    : null,
                child: widget.user.profileImageUrl == null
                    ? Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 28,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(height: 8),
              Text(widget.user.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              Text(widget.user.email,
                  style: const TextStyle(
                      color: AppColors.textMedium, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 28),

          TextField(
            controller: _nameCtrl,
            decoration:
                const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration:
                const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: 24),

          GoldButton(
            text: 'CONFIRM EDIT',
            onPressed: _save,
            isLoading: _isSaving,
          ),
          const SizedBox(height: 12),
          DangerButton(
            text: 'CANCEL EDIT',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
