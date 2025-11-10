import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/prayer_settings.dart';
import '../../providers/app_providers.dart';

class PrayerOffsetController extends StateNotifier<Map<String, int>> {
  PrayerOffsetController(this._settingsController)
      : super(_settingsController.state.value?.offsets ??
            PrayerSettings.defaults().offsets);

  final SettingsController _settingsController;

  void updateOffset(String key, int minutes) {
    final updated = Map<String, int>.from(state)..[key] = minutes;
    state = updated;
    final current = _settingsController.state.value ?? PrayerSettings.defaults();
    _settingsController.update(current.copyWith(offsets: updated));
  }
}

final prayerOffsetProvider =
    StateNotifierProvider<PrayerOffsetController, Map<String, int>>((ref) {
  final controller = ref.watch(settingsControllerProvider.notifier);
  return PrayerOffsetController(controller);
});
