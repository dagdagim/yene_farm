import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Get token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
    });

    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.data}');
    });
  }

  Future<void> subscribeToTopics(String userId) async {
    await _firebaseMessaging.subscribeToTopic('user_$userId');
    await _firebaseMessaging.subscribeToTopic('orders');
    await _firebaseMessaging.subscribeToTopic('market_updates');
  }
}