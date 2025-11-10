import 'package:flutter/material.dart';

import '../../data/models/surah.dart';

typedef SurahSelectedCallback = void Function(Surah surah);

class QuranSearchDelegate extends SearchDelegate<Surah?> {
  QuranSearchDelegate({
    required this.surahs,
    required this.onSelected,
  });

  final List<Surah> surahs;
  final SurahSelectedCallback onSelected;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matches = _search(query);
    return _buildList(matches);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final matches = _search(query);
    return _buildList(matches);
  }

  List<Surah> _search(String query) {
    if (query.isEmpty) return surahs.take(10).toList();
    final normalized = query.trim();
    return surahs.where((surah) {
      final numberMatch = surah.number.toString().contains(normalized);
      final nameMatch = surah.name.contains(normalized);
      return numberMatch || nameMatch;
    }).toList();
  }

  Widget _buildList(List<Surah> surahs) {
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          title: Text(surah.name),
          subtitle: Text('عدد الآيات: ${surah.ayahCount}'),
          trailing: Text('#${surah.number}'),
          onTap: () {
            onSelected(surah);
            close(context, surah);
          },
        );
      },
    );
  }
}
