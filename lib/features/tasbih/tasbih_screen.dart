import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> with SingleTickerProviderStateMixin {
  String _currentPattern = 'fatimah';
  int _currentStage = 0; // For Fatimah pattern: 0=Allahu Akbar(34), 1=Alhamdulillah(33), 2=SubhanAllah(33)
  int _target = 34;
  bool _enableSound = false;
  bool _enableVibration = true;
  late AnimationController _animationController;

  final Map<String, List<Map<String, dynamic>>> _patterns = {
    'fatimah': [
      {'text': 'الله أكبر', 'target': 34},
      {'text': 'الحمد لله', 'target': 33},
      {'text': 'سبحان الله', 'target': 33},
    ],
    'custom': [
      {'text': 'سبحان الله', 'target': 33},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _currentDhikr => _patterns[_currentPattern]![_currentStage]['text'];

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(tasbihCountProvider);
    final progress = count / _target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'pattern') {
                _showPatternPicker();
              } else if (value == 'settings') {
                _showSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pattern',
                child: Text('اختيار النمط'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('الإعدادات'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          _buildPatternInfo(),
          const SizedBox(height: 24),
          _buildProgressIndicator(progress),
          const SizedBox(height: 16),
          _buildCounter(count),
          const Spacer(),
          _buildMainButton(count),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPatternInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _currentPattern == 'fatimah' ? 'سبحة الزهراء (ع)' : 'نمط مخصص',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentDhikr,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'الهدف: $_target',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(int count) {
    return Column(
      children: [
        Text(
          'العدد',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(int count) {
    return GestureDetector(
      onTap: () => _incrementCount(count),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 1.0 - (_animationController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.touch_app,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton.icon(
            onPressed: () => _decrementCount(),
            icon: const Icon(Icons.remove),
            label: const Text('تراجع'),
          ),
          ElevatedButton.icon(
            onPressed: () => _resetCount(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة'),
          ),
        ],
      ),
    );
  }

  void _incrementCount(int currentCount) {
    _animationController.forward().then((_) => _animationController.reverse());

    if (_enableVibration) {
      HapticFeedback.lightImpact();
    }

    ref.read(tasbihCountProvider.notifier).increment();

    // Check if target reached
    if (currentCount + 1 >= _target) {
      HapticFeedback.heavyImpact();
      _showCompletionDialog();
      
      // Move to next stage in Fatimah pattern
      if (_currentPattern == 'fatimah' && _currentStage < 2) {
        setState(() {
          _currentStage++;
          _target = _patterns['fatimah']![_currentStage]['target'];
        });
        ref.read(tasbihCountProvider.notifier).reset();
      }
    }
  }

  void _decrementCount() {
    ref.read(tasbihCountProvider.notifier).decrement();
  }

  void _resetCount() {
    ref.read(tasbihCountProvider.notifier).reset();
    setState(() {
      _currentStage = 0;
      _target = _patterns[_currentPattern]![0]['target'];
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بارك الله فيك!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'لقد أتممت الذكر المحدد',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showPatternPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر النمط',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('سبحة الزهراء (ع)'),
                subtitle: const Text('34 الله أكبر + 33 الحمد لله + 33 سبحان الله'),
                onTap: () {
                  setState(() {
                    _currentPattern = 'fatimah';
                    _currentStage = 0;
                    _target = 34;
                  });
                  _resetCount();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('نمط مخصص'),
                subtitle: const Text('حدد الذكر والعدد'),
                onTap: () {
                  setState(() {
                    _currentPattern = 'custom';
                    _currentStage = 0;
                    _target = 33;
                  });
                  _resetCount();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إعدادات المسبحة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('الاهتزاز'),
                    subtitle: const Text('اهتزاز خفيف عند كل ضغطة'),
                    value: _enableVibration,
                    onChanged: (value) {
                      setModalState(() {
                        _enableVibration = value;
                      });
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('الصوت'),
                    subtitle: const Text('صوت خفيف عند كل ضغطة'),
                    value: _enableSound,
                    onChanged: (value) {
                      setModalState(() {
                        _enableSound = value;
                      });
                      setState(() {});
                    },
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
