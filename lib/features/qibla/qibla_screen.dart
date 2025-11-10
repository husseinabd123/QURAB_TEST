import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../core/permissions.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<CompassEvent>? _compassSub;
  double _heading = 0;
  bool _hasSensor = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final permission = await PermissionsHandler.requestLocation(precise: true);
    if (!permission) {
      setState(() => _hasSensor = false);
      return;
    }
    final sensor = await FlutterQiblah.androidDeviceSensorSupport();
    setState(() => _hasSensor = sensor ?? false);
    _compassSub = FlutterQiblah.qiblahStream.listen((event) {
      setState(() => _heading = event.qiblah);
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSensor) {
      return Scaffold(
        appBar: AppBar(title: const Text('القبلة')),
        body: const Center(
          child: Text('الجهاز لا يدعم المستشعرات المطلوبة لعرض القبلة.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => PermissionsHandler.openExactAlarmSettings(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('درجة الانحراف: ${_heading.toStringAsFixed(1)}°'),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: vector.radians(_heading),
                    child: const Icon(
                      Icons.navigation,
                      size: 120,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'إذا لاحظت انحرافًا كبيرًا، الرجاء تحريك الجهاز على شكل الرقم ثمانية لمعايرة المستشعر.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
