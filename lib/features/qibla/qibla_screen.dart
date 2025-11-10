import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/permissions.dart';
import '../../core/utils.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _hasPermission = false;
  double _qiblaBearing = 0.0;
  
  // Kaaba coordinates
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await PermissionsService.requestLocationPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
    
    if (hasPermission) {
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _qiblaBearing = AppUtils.calculateBearing(
          position.latitude,
          position.longitude,
          kaabaLat,
          kaabaLng,
        );
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocation,
          ),
        ],
      ),
      body: _hasPermission
          ? _buildQiblaCompass()
          : _buildPermissionRequired(),
    );
  }

  Widget _buildPermissionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'نحتاج إلى إذن الموقع',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'لتحديد اتجاه القبلة بدقة، يرجى السماح بالوصول إلى موقعك',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('منح الإذن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaCompass() {
    if (_isLoadingLocation || _currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحديد الموقع...'),
          ],
        ),
      );
    }

    return StreamBuilder<FlutterQiblahState>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildFallbackCompass();
        }

        final qiblahState = snapshot.data!;
        
        if (qiblahState.status == QiblahStatus.notSupported) {
          return _buildFallbackCompass();
        }

        return Column(
          children: [
            _buildLocationInfo(),
            Expanded(
              child: Center(
                child: _buildCompassWidget(qiblahState.qiblah),
              ),
            ),
            _buildBearingInfo(qiblahState.qiblah),
          ],
        );
      },
    );
  }

  Widget _buildFallbackCompass() {
    return Column(
      children: [
        _buildLocationInfo(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'اتجاه القبلة',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_qiblaBearing.toStringAsFixed(1)}°',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'ملاحظة: البوصلة غير مدعومة على هذا الجهاز. يتم عرض الاتجاه المحسوب فقط.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (_currentPosition == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              Text(
                'موقعك الحالي',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'خط العرض: ${_currentPosition!.latitude.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'خط الطول: ${_currentPosition!.longitude.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassWidget(double qiblah) {
    return Transform.rotate(
      angle: qiblah * (math.pi / 180) * -1,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // North indicator
            Positioned(
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ش',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Qibla arrow
            Icon(
              Icons.navigation,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            // Center dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBearingInfo(double qiblah) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اتجاه القبلة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '${qiblah.toStringAsFixed(1)}°',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'وجّه الهاتف نحو السهم الأخضر',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
