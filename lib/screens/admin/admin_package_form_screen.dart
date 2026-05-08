// lib/screens/admin/admin_package_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_package.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminPackageFormScreen extends StatefulWidget {
  final MenuPackage? package;

  const AdminPackageFormScreen({super.key, required this.package});

  @override
  State<AdminPackageFormScreen> createState() =>
      _AdminPackageFormScreenState();
}

class _AdminPackageFormScreenState
    extends State<AdminPackageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirestoreService();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _includeCtrl;

  String _category = 'All';
  bool _isAvailable = true;
  bool _isSaving = false;
  List<String> _imageUrls = [];
  List<String> _includes = [];
  final _categories = ['All', 'Western', 'Asian', 'Fusion', 'Local'];

  bool get _isEditing => widget.package != null;

  @override
  void initState() {
    super.initState();
    final pkg = widget.package;
    _nameCtrl = TextEditingController(text: pkg?.name ?? '');
    _descCtrl = TextEditingController(text: pkg?.description ?? '');
    _priceCtrl = TextEditingController(
        text: pkg?.pricePerGuest.toStringAsFixed(0) ?? '');
    _imageCtrl = TextEditingController();
    _minCtrl =
        TextEditingController(text: '${pkg?.minGuests ?? 10}');
    _maxCtrl =
        TextEditingController(text: '${pkg?.maxGuests ?? 200}');
    _includeCtrl = TextEditingController();
    _category = pkg?.category ?? 'All';
    _isAvailable = pkg?.isAvailable ?? true;
    _imageUrls = List.from(pkg?.imageUrls ?? []);
    _includes = List.from(pkg?.includes ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _includeCtrl.dispose();
    super.dispose();
  }

  void _addImageUrl() {
    final url = _imageCtrl.text.trim();
    if (url.isNotEmpty) {
      setState(() => _imageUrls.add(url));
      _imageCtrl.clear();
    }
  }

  void _addInclude() {
    final item = _includeCtrl.text.trim();
    if (item.isNotEmpty) {
      setState(() => _includes.add(item));
      _includeCtrl.clear();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final pkg = MenuPackage(
        id: widget.package?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        pricePerGuest: double.parse(_priceCtrl.text),
        imageUrls: _imageUrls,
        includes: _includes,
        category: _category,
        minGuests: int.tryParse(_minCtrl.text) ?? 10,
        maxGuests: int.tryParse(_maxCtrl.text) ?? 200,
        isAvailable: _isAvailable,
        orderCount: widget.package?.orderCount ?? 0,
        createdAt: widget.package?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await _db.updatePackage(pkg);
      } else {
        await _db.addPackage(pkg);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing
            ? 'Package updated successfully'
            : 'Package added successfully'),
        backgroundColor: AppColors.success,
      ));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Package' : 'Add Package'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Package Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration:
                  const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? 'All'),
            ),
            const SizedBox(height: 14),

            // Price
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price Per Guest (RM)',
                prefixText: 'RM ',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null)
                  return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Min/Max guests
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Min Guests'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Max Guests'),
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: 'Description'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Available switch
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Text('Available for booking',
                    style: TextStyle(fontSize: 15)),
                const Spacer(),
                Switch(
                  value: _isAvailable,
                  onChanged: (v) =>
                      setState(() => _isAvailable = v),
                  activeColor: AppColors.secondary,
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Image URLs
            const Text('Package Images (URLs)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Paste image URL...'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: _addImageUrl,
                  child: const Text('Add')),
            ]),
            const SizedBox(height: 8),
            if (_imageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imageUrls.asMap().entries.map((e) {
                  return Chip(
                    label: Text('Image ${e.key + 1}',
                        style:
                            const TextStyle(fontSize: 11)),
                    deleteIcon: const Icon(Icons.close,
                        size: 14),
                    onDeleted: () => setState(
                        () => _imageUrls.removeAt(e.key)),
                    backgroundColor:
                        AppColors.secondary.withOpacity(0.15),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // Includes
            const Text("What's Included",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _includeCtrl,
                  decoration: const InputDecoration(
                      hintText: 'e.g. 5-course meal...'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: _addInclude,
                  child: const Text('Add')),
            ]),
            const SizedBox(height: 8),
            ..._includes.asMap().entries.map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  title: Text(e.value,
                      style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.cancelRed, size: 18),
                    onPressed: () => setState(
                        () => _includes.removeAt(e.key)),
                  ),
                )),
            const SizedBox(height: 24),

            GoldButton(
              text: _isEditing
                  ? 'UPDATE PACKAGE'
                  : 'ADD PACKAGE',
              onPressed: _save,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
