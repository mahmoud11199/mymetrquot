import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<List<String>> requestCorePermissions() async {
    final warnings = <String>[];

    final location = await Permission.locationWhenInUse.request();
    if (!location.isGranted) {
      warnings.add('Location permission denied. Map pickup/dropoff may be limited.');
    }

    final camera = await Permission.camera.request();
    if (!camera.isGranted) {
      warnings.add('Camera permission denied. KYC upload will be unavailable.');
    }

    final notification = await Permission.notification.request();
    if (!notification.isGranted) {
      warnings.add('Notification permission denied. You may miss ride updates.');
    }

    return warnings;
  }
}
