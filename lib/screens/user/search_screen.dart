// lib/screens/user/search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_package.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SearchScreen extends StatefulWidget {
  final bool isAdmin;
  const SearchScreen({super.key, this.isAdmin = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _db = FirestoreService();
  List<MenuPackage> _results = [];
  bool _loading = false;
  bool _searched = false;
  String _filterCategory = 'All';
  final _categories = ['All', 'Western', 'Asian', 'Fusion', 'Local'];

  Future<void> _search(String q) async {
    setState(() { _loading = true; _searched = true; });
    final results = await _db.searchPackages(q);
    if (mounted) {
      setState(() {
        _results = _filterCategory == 'All'
            ? results
            : results.where((p) => p.category == _filterCategory).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search packages...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
            filled: false,
          ),
          onSubmitted: _search,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                setState(() { _results = []; _searched = false; });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_ctrl.text.trim()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final sel = cat == _filterCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filterCategory = cat);
                      if (_searched) _search(_ctrl.text.trim());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? AppColors.secondary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.textMedium)),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerList(count: 4))
                : !_searched
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search,
                                size: 60,
                                color: AppColors.textLight.withOpacity(0.5)),
                            const SizedBox(height: 10),
                            const Text('Search menu packages',
                                style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 15)),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off,
                                    size: 60,
                                    color: AppColors.textLight
                                        .withOpacity(0.5)),
                                const SizedBox(height: 10),
                                const Text('No packages found',
                                    style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 15)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _results.length,
                            itemBuilder: (ctx, i) => PackageCard(
                              package: _results[i],
                              onTap: () {
                                final route = widget.isAdmin
                                    ? '/admin/packages/edit'
                                    : '/home/package/${_results[i].id}';
                                context.push(route, extra: _results[i]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
