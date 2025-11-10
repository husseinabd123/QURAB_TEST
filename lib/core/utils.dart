import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class AppUtils {
  AppUtils._();

  /// Format time in 24h or 12h format
  static String formatTime(DateTime time, {bool is24Hour = true}) {
    if (is24Hour) {
      return intl.DateFormat('HH:mm').format(time);
    } else {
      return intl.DateFormat('h:mm a').format(time);
    }
  }

  /// Format date in Arabic
  static String formatDate(DateTime date) {
    return intl.DateFormat('yyyy/MM/dd').format(date);
  }

  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Calculate bearing between two coordinates
  static double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = degreesToRadians(lon2 - lon1);
    final lat1Rad = degreesToRadians(lat1);
    final lat2Rad = degreesToRadians(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (radiansToDegrees(bearing) + 360) % 360;
  }

  /// Show snackbar with message
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'نعم',
    String cancelText = 'لا',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: Text(message, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Low-pass filter for smoothing sensor values
  static double lowPassFilter(double current, double previous, double alpha) {
    return alpha * current + (1 - alpha) * previous;
  }

  /// Format file size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'ليلة مباركة';
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }
}
