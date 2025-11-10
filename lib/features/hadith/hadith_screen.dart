import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/hadith.dart';
import '../../core/utils.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأحاديث'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'النبي (ص)'),
            Tab(text: 'نهج البلاغة'),
            Tab(text: 'الإمام الحسين (ع)'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHadithList(null),
                _buildHadithList('النبي (ص)'),
                _buildHadithList('نهج البلاغة'),
                _buildHadithList('الإمام الحسين (ع)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'البحث في الأحاديث...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildHadithList(String? source) {
    final hadithsAsync = ref.watch(hadithListProvider);

    return hadithsAsync.when(
      data: (hadiths) {
        var filteredHadiths = hadiths;

        // Filter by source
        if (source != null) {
          filteredHadiths = hadiths.where((h) => h.source == source).toList();
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          filteredHadiths = filteredHadiths.where((h) {
            return h.text.contains(_searchQuery) ||
                   h.source.contains(_searchQuery) ||
                   h.tags.any((tag) => tag.contains(_searchQuery));
          }).toList();
        }

        if (filteredHadiths.isEmpty) {
          return const Center(
            child: Text('لا توجد أحاديث'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredHadiths.length,
          itemBuilder: (context, index) {
            return _buildHadithCard(filteredHadiths[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
    );
  }

  Widget _buildHadithCard(Hadith hadith) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hadith.source,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    hadith.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: hadith.isFavorite ? Colors.red : null,
                    size: 20,
                  ),
                  onPressed: () async {
                    await ref.read(hadithRepoProvider).toggleFavorite(hadith.id);
                    ref.invalidate(hadithListProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hadith.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.8,
              ),
              textAlign: TextAlign.justify,
            ),
            if (hadith.reference != null) ...[
              const SizedBox(height: 12),
              Text(
                'المصدر: ${hadith.reference}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: hadith.text));
                    AppUtils.showSnackbar(context, 'تم النسخ');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('نسخ'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Share hadith
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
