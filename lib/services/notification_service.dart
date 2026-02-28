import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Firebase may be unconfigured in local/dev environments.
    }
  }
}
