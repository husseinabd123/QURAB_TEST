import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class TasbihState {
  final String pattern;
  final int count;
  final int target;

  const TasbihState({
    required this.pattern,
    required this.count,
    required this.target,
  });

  TasbihState copyWith({
    String? pattern,
    int? count,
    int? target,
  }) {
    return TasbihState(
      pattern: pattern ?? this.pattern,
      count: count ?? this.count,
      target: target ?? this.target,
    );
  }
}

class TasbihController extends StateNotifier<AsyncValue<TasbihState>> {
  TasbihController(this._settingsRepository)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _settingsRepository;

  Future<void> _load() async {
    final pattern = await _settingsRepository.getTasbihPattern();
    final count = await _settingsRepository.getTasbihCount();
    state = AsyncValue.data(
      TasbihState(pattern: pattern, count: count.toInt(), target: 33),
    );
  }

  Future<void> increment() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(count: current.count + 1);
    state = AsyncValue.data(updated);
    await _settingsRepository.setTasbihCount(updated.count.toDouble());
    HapticFeedback.lightImpact();
  }

  Future<void> decrement() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(count: (current.count - 1).clamp(0, 1000));
    state = AsyncValue.data(updated);
    await _settingsRepository.setTasbihCount(updated.count.toDouble());
  }

  Future<void> reset() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(count: 0);
    state = AsyncValue.data(updated);
    await _settingsRepository.setTasbihCount(0);
  }

  Future<void> changePattern(String pattern, int target) async {
    final current = state.value;
    final updated =
        (current ?? const TasbihState(pattern: 'custom', count: 0, target: 33))
            .copyWith(pattern: pattern, target: target, count: 0);
    state = AsyncValue.data(updated);
    await _settingsRepository.setTasbihPattern(pattern);
    await _settingsRepository.setTasbihCount(0);
  }
}

final tasbihControllerProvider =
    StateNotifierProvider<TasbihController, AsyncValue<TasbihState>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return TasbihController(repo);
});

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihControllerProvider);
    final controller = ref.read(tasbihControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
      ),
      body: state.when(
        data: (value) => Column(
          children: [
            const SizedBox(height: 32),
            Text(
              value.pattern == 'fatimah'
                  ? 'سبحة الزهراء (س)'
                  : 'مسبحة مخصصة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'الهدف: ${value.target}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      value.count.toString(),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove),
                    onPressed: controller.decrement,
                  ),
                  ElevatedButton(
                    onPressed: controller.increment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('سَبِّح'),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.restart_alt),
                    onPressed: controller.reset,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر النمط',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          ChoiceChip(
                            label: const Text('سبحة الزهراء'),
                            selected: value.pattern == 'fatimah',
                            onSelected: (selected) {
                              if (selected) {
                                controller.changePattern('fatimah', 100);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('مخصص 33'),
                            selected: value.pattern == 'custom33',
                            onSelected: (selected) {
                              if (selected) {
                                controller.changePattern('custom33', 33);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('مخصص 100'),
                            selected: value.pattern == 'custom100',
                            onSelected: (selected) {
                              if (selected) {
                                controller.changePattern('custom100', 100);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }
}
