import 'package:flutter/material.dart';

import 'hadith_tabs.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأحاديث الشريفة'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'النبي (ص)'),
              Tab(text: 'نهج البلاغة'),
              Tab(text: 'الإمام الحسين (ع)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HadithTabView(source: 'النبي'),
            HadithTabView(source: 'نهج'),
            HadithTabView(source: 'الإمام الحسين'),
          ],
        ),
      ),
    );
  }
}
