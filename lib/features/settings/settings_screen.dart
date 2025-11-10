import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../core/background.dart';
import '../../core/permissions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _debugTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _debugTapCount++;
              if (_debugTapCount >= 7) {
                _debugTapCount = 0;
                _showDebugScreen();
              }
            });
          },
          child: const Text('الإعدادات'),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSection('الصلاة والأذان'),
            _buildAdhanSettings(settings),
            _buildHourlyHadithSettings(settings),
            const Divider(height: 32),
            _buildSection('التقويم الهجري'),
            _buildHijriOffsetSetting(settings),
            const Divider(height: 32),
            _buildSection('المظهر'),
            _buildThemeSettings(settings),
            _buildFontSizeSettings(settings),
            const Divider(height: 32),
            _buildSection('الأذونات'),
            _buildPermissionSettings(),
            const Divider(height: 32),
            _buildSection('حول التطبيق'),
            _buildAboutSection(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdhanSettings(settings) {
    return SwitchListTile(
      title: const Text('تفعيل الأذان'),
      subtitle: const Text('إشعار صوتي عند وقت الصلاة'),
      value: settings.adhanEnabled,
      onChanged: (value) async {
        if (value) {
          await PermissionsService.showExactAlarmPermissionDialog(context);
        }
        final repo = ref.read(settingsRepoProvider);
        await repo.updateAdhanEnabled(value);
        ref.invalidate(settingsProvider);
      },
    );
  }

  Widget _buildHourlyHadithSettings(settings) {
    return SwitchListTile(
      title: const Text('تذكير الحديث الساعي'),
      subtitle: const Text('تلقي حديث جديد كل ساعة'),
      value: settings.hourlyHadithEnabled,
      onChanged: (value) async {
        await BackgroundService.setHourlyHadithEnabled(value);
        final repo = ref.read(settingsRepoProvider);
        await repo.updateHourlyHadithEnabled(value);
        ref.invalidate(settingsProvider);
      },
    );
  }

  Widget _buildHijriOffsetSetting(settings) {
    return ListTile(
      title: const Text('تعديل التقويم الهجري'),
      subtitle: Text('التعديل الحالي: ${settings.hijriOffset > 0 ? '+' : ''}${settings.hijriOffset} يوم'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showHijriOffsetDialog(settings.hijriOffset),
    );
  }

  Widget _buildThemeSettings(settings) {
    return ListTile(
      title: const Text('المظهر'),
      subtitle: Text(_getThemeLabel(settings.theme)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showThemePicker(settings.theme),
    );
  }

  Widget _buildFontSizeSettings(settings) {
    return ListTile(
      title: const Text('حجم الخط'),
      subtitle: Slider(
        value: settings.fontSize,
        min: 0.8,
        max: 1.5,
        divisions: 7,
        label: '${(settings.fontSize * 100).toInt()}%',
        onChanged: (value) async {
          final repo = ref.read(settingsRepoProvider);
          await repo.updateFontSize(value);
          ref.invalidate(settingsProvider);
        },
      ),
    );
  }

  Widget _buildPermissionSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('إذن الموقع'),
          subtitle: const Text('لحساب مواقيت الصلاة والقبلة'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            await PermissionsService.requestLocationPermission();
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('إذن الإشعارات'),
          subtitle: const Text('لتلقي تنبيهات الأذان والأحاديث'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            await PermissionsService.requestNotificationPermission();
          },
        ),
        ListTile(
          leading: const Icon(Icons.alarm),
          title: const Text('المنبهات الدقيقة'),
          subtitle: const Text('لضمان دقة إشعارات الأذان'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            PermissionsService.showExactAlarmPermissionDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.battery_charging_full),
          title: const Text('تحسين البطارية'),
          subtitle: const Text('إعدادات توفير الطاقة'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            PermissionsService.showBatteryOptimizationDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('الإصدار'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('الخصوصية'),
          subtitle: const Text('لا يتم جمع أي بيانات شخصية'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('المطور'),
          subtitle: const Text('حقيبة المؤمن+'),
        ),
      ],
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  void _showHijriOffsetDialog(int currentOffset) {
    showDialog(
      context: context,
      builder: (context) {
        int tempOffset = currentOffset;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تعديل التقويم الهجري', textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'قم بتعديل التقويم الهجري حسب رؤية الهلال',
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setDialogState(() {
                            tempOffset--;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tempOffset > 0 ? '+$tempOffset' : '$tempOffset',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            tempOffset++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(settingsRepoProvider);
                    await repo.updateHijriOffset(tempOffset);
                    ref.invalidate(settingsProvider);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThemePicker(String currentTheme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('فاتح'),
              onTap: () async {
                await _updateTheme('light');
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('داكن'),
              onTap: () async {
                await _updateTheme('dark');
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('تلقائي'),
              onTap: () async {
                await _updateTheme('system');
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTheme(String theme) async {
    final repo = ref.read(settingsRepoProvider);
    await repo.updateTheme(theme);
    ref.read(themeModeProvider.notifier).setThemeMode(theme);
    ref.invalidate(settingsProvider);
  }

  void _showDebugScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وضع المطور'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نسخة التطبيق: 1.0.0'),
              Text('Flutter SDK: 3.x'),
              Text('Min SDK: 24'),
              Text('Target SDK: 35'),
              SizedBox(height: 16),
              Text('الإصدار: إنتاج'),
              Text('البناء: Release'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
