import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/styles.dart';
import '../../providers/app_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('إعدادات التطبيق'),
              subtitle: Text('الوضع الحالي: ${_describeTheme(settings.themeMode)}'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push('/settings'),
            ),
          ),
          const SizedBox(height: 16),
          Text('الخدمات', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _MoreGrid(),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التنبيهات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _NotifySwitchTile(
                    value: settings.adhanEnabled,
                    title: 'تفعيل تنبيهات الأذان',
                    onChanged: (value) =>
                        ref.read(settingsControllerProvider.notifier).toggleAdhan(value),
                  ),
                  const Divider(),
                  _NotifySwitchTile(
                    value: settings.hourlyHadithEnabled,
                    title: 'تفعيل حديث الساعة',
                    onChanged: (value) => ref
                        .read(settingsControllerProvider.notifier)
                        .toggleHourlyHadith(value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('حدث خطأ: $error'),
      ),
    );
  }

  String _describeTheme(String theme) {
    return switch (theme) {
      'light' => 'فاتح',
      'dark' => 'داكن',
      _ => 'حسب النظام',
    };
  }
}

class _MoreGrid extends StatelessWidget {
  final List<_MoreItem> items = const [
    _MoreItem(Icons.volume_up_outlined, 'إدارة الأذان', '/prayer'),
    _MoreItem(Icons.download_for_offline_outlined, 'إدارة التخزين', '/settings'),
    _MoreItem(Icons.analytics_outlined, 'مركز المتابعة', '/prayer'),
    _MoreItem(Icons.bug_report_outlined, 'وضع الاختبار', '/settings'),
    _MoreItem(Icons.info_outline, 'عن التطبيق', '/settings'),
    _MoreItem(Icons.privacy_tip_outlined, 'سياسة الخصوصية', '/settings'),
  ];

  _MoreGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(item.route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Icon(item.icon, color: AppPalette.lightOlive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotifySwitchTile extends StatelessWidget {
  const _NotifySwitchTile({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(title),
      onChanged: onChanged,
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String title;
  final String route;

  const _MoreItem(this.icon, this.title, this.route);
}
