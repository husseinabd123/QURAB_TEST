import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/styles.dart';
import '../../providers/app_providers.dart';
import '../../data/models/dhikr.dart';

final _morningDhikrProvider = FutureProvider<List<Dhikr>>((ref) async {
  final repo = ref.watch(dhikrRepositoryProvider);
  final list = await repo.byTime('morning');
  return list.take(3).toList();
});

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_filled), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'أذكار'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'التقويم'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'القبلة'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'المزيد'),
        ],
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          widget.navigationShell.goBranch(index);
        },
      ),
    );
  }
}

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikrAsync = ref.watch(_morningDhikrProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_morningDhikrProvider);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ذكر اليوم',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              FilledButton.tonal(
                onPressed: () => context.go('/adhkar'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: dhikrAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyCard(onTap: () => ref.invalidate(_morningDhikrProvider));
                }
                return PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _DhikrCard(dhikr: item).animate().fadeIn(duration: 400.ms);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorCard(
                message: 'تعذر تحميل الأذكار',
                onRetry: () => ref.invalidate(_morningDhikrProvider),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'خدمات سريعة',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _HomeGrid(),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({required this.dhikr});

  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppPalette.lightGold),
                const SizedBox(width: 8),
                Text(
                  'التكرار: ${dhikr.repeat}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                dhikr.text,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Center(
          child: Text('لا توجد أذكار متاحة الآن. اضغط للتحديث.'),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
              const SizedBox(height: 12),
              const Icon(Icons.refresh),
              const SizedBox(height: 8),
              const Text('إعادة المحاولة'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  final List<_HomeShortcut> shortcuts = const [
    _HomeShortcut(
      icon: Icons.menu_book_rounded,
      label: 'القرآن الكريم',
      route: '/quran',
      accent: AppPalette.lightOlive,
    ),
    _HomeShortcut(
      icon: Icons.menu_rounded,
      label: 'الأحاديث',
      route: '/hadith',
      accent: AppPalette.lightGold,
    ),
    _HomeShortcut(
      icon: Icons.access_time_filled_rounded,
      label: 'المواقيت',
      route: '/prayer',
      accent: Color(0xFF6F7D3C),
    ),
    _HomeShortcut(
      icon: Icons.menu_book_outlined,
      label: 'الأدعية',
      route: '/duas',
      accent: Color(0xFFAA8C5A),
    ),
    _HomeShortcut(
      icon: Icons.fingerprint_rounded,
      label: 'المسبحة',
      route: '/tasbih',
      accent: Color(0xFF6E5A7D),
    ),
    _HomeShortcut(
      icon: Icons.calendar_today_outlined,
      label: 'التقويم',
      route: '/calendar',
      accent: Color(0xFF556B2F),
    ),
    _HomeShortcut(
      icon: Icons.explore,
      label: 'القبلة',
      route: '/qibla',
      accent: Color(0xFF357266),
    ),
    _HomeShortcut(
      icon: Icons.star_outline,
      label: 'الأذكار',
      route: '/adhkar',
      accent: Color(0xFFB38B59),
    ),
    _HomeShortcut(
      icon: Icons.settings_outlined,
      label: 'الإعدادات',
      route: '/settings',
      accent: Color(0xFF3A4A3E),
    ),
  ];

  _HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return _ShortcutCard(shortcut: shortcut);
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.shortcut});

  final _HomeShortcut shortcut;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(shortcut.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: shortcut.accent.withOpacity(0.1),
                child: Icon(shortcut.icon, color: shortcut.accent),
              ),
              const SizedBox(height: 12),
              Text(
                shortcut.label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 12, end: 0, duration: 300.ms);
  }
}

class _HomeShortcut {
  final IconData icon;
  final String label;
  final String route;
  final Color accent;

  const _HomeShortcut({
    required this.icon,
    required this.label,
    required this.route,
    required this.accent,
  });
}
