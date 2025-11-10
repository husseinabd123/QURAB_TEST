import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/dua.dart';
import '../../core/utils.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدعية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Show favorites
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildDuaList()),
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
          hintText: 'البحث في الأدعية...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildDuaList() {
    final duasAsync = ref.watch(duaListProvider);

    return duasAsync.when(
      data: (duas) {
        var filteredDuas = duas;

        if (_searchQuery.isNotEmpty) {
          filteredDuas = duas.where((d) {
            return d.title.contains(_searchQuery) ||
                   d.text.contains(_searchQuery);
          }).toList();
        }

        if (filteredDuas.isEmpty) {
          return const Center(
            child: Text('لا توجد أدعية'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDuas.length,
          itemBuilder: (context, index) {
            return _buildDuaCard(filteredDuas[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
    );
  }

  Widget _buildDuaCard(Dua dua) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showDuaDetails(dua),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dua.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      dua.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: dua.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () async {
                      await ref.read(duaRepoProvider).toggleFavorite(dua.id);
                      ref.invalidate(duaListProvider);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dua.text.length > 150 
                    ? '${dua.text.substring(0, 150)}...' 
                    : dua.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDuaDetails(Dua dua) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dua.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        dua.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          height: 2.0,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: dua.text));
                              AppUtils.showSnackbar(context, 'تم النسخ');
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('نسخ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Share dua
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('مشاركة'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
