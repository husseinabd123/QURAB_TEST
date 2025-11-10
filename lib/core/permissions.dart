import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsService {
  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if exact alarm permission is granted (Android 12+)
  static Future<bool> checkExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }
    return false;
  }

  /// Open app settings for exact alarm permission
  static Future<void> openExactAlarmSettings() async {
    await Permission.scheduleExactAlarm.request();
  }

  /// Request battery optimization exemption
  static Future<bool> requestIgnoreBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return true;
    
    final result = await Permission.ignoreBatteryOptimizations.request();
    return result.isGranted;
  }

  /// Show dialog explaining why location permission is needed
  static void showLocationPermissionDialog(BuildContext context, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إذن الموقع', textAlign: TextAlign.right),
        content: const Text(
          'نحتاج إلى إذن الموقع لحساب مواقيت الصلاة وتحديد اتجاه القبلة.\n\n'
          'يمكنك أيضاً اختيار المحافظة يدوياً من الإعدادات.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// Show dialog for exact alarm permission (Android 14+)
  static void showExactAlarmPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إذن المنبهات الدقيقة', textAlign: TextAlign.right),
        content: const Text(
          'لتلقي إشعارات الأذان في الوقت المحدد بدقة، نحتاج إلى إذن المنبهات الدقيقة.\n\n'
          'يرجى تفعيل "السماح بتعيين المنبهات والتذكيرات" في الإعدادات.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openExactAlarmSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  /// Show dialog for battery optimization
  static void showBatteryOptimizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحسين البطارية', textAlign: TextAlign.right),
        content: const Text(
          'للحصول على أفضل أداء لإشعارات الأذان والتذكيرات، نوصي بتعطيل تحسين البطارية لهذا التطبيق.\n\n'
          'هذا يضمن عمل التطبيق في الخلفية بشكل صحيح.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await requestIgnoreBatteryOptimization();
            },
            child: const Text('تعطيل التحسين'),
          ),
        ],
      ),
    );
  }

  /// Check all required permissions
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'location': await Geolocator.checkPermission() != LocationPermission.denied,
      'notification': await Permission.notification.isGranted,
      'exactAlarm': await checkExactAlarmPermission(),
      'batteryOptimization': await Permission.ignoreBatteryOptimizations.isGranted,
    };
  }
}
