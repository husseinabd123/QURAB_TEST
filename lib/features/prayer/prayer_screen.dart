import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/permissions.dart';
import '../../core/utils.dart';
import '../../providers/app_providers.dart';
import 'prayer_service.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final hasPermission = await PermissionsService.requestLocationPermission();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
        });
        
        // Save location to settings
        final repo = ref.read(settingsRepoProvider);
        await repo.updateLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'تعذر الحصول على الموقع', isError: true);
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _loadLocation,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open prayer settings
            },
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          final lat = _currentPosition?.latitude ?? settings.latitude ?? 33.3152;
          final lng = _currentPosition?.longitude ?? settings.longitude ?? 44.3661;
          
          final prayerTimes = PrayerService.calculatePrayerTimes(
            lat,
            lng,
            DateTime.now(),
            settings.offsets,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildLocationCard(settings.city ?? 'بغداد'),
                _buildNextPrayerCard(prayerTimes),
                _buildPrayerTimesList(prayerTimes),
                _buildAdhanSettings(settings.adhanEnabled),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }

  Widget _buildLocationCard(String city) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الموقع الحالي',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    MapEntry<String, DateTime>? nextPrayer;

    for (var entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayer = entry;
        break;
      }
    }

    if (nextPrayer == null) {
      return const SizedBox.shrink();
    }

    final remaining = nextPrayer.value.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            nextPrayer.key,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppUtils.formatTime(nextPrayer.value),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'بعد $hours ساعة و $minutes دقيقة',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(Map<String, DateTime> prayerTimes) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: prayerTimes.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = prayerTimes.entries.elementAt(index);
          return ListTile(
            leading: Icon(
              _getPrayerIcon(entry.key),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              AppUtils.formatTime(entry.value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdhanSettings(bool adhanEnabled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SwitchListTile(
        title: const Text('تفعيل الأذان'),
        subtitle: const Text('إشعار صوتي عند وقت الصلاة'),
        value: adhanEnabled,
        onChanged: (value) async {
          final repo = ref.read(settingsRepoProvider);
          await repo.updateAdhanEnabled(value);
          ref.invalidate(settingsProvider);
        },
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny;
      case 'الظهر':
        return Icons.wb_sunny_outlined;
      case 'العصر':
        return Icons.light_mode;
      case 'المغرب':
        return Icons.nights_stay;
      case 'العشاء':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}
