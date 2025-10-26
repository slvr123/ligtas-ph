import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  
  factory FCMService() {
    return _instance;
  }
  
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize FCM
  Future<void> initialize() async {
    print('Initializing FCM...');
    
    // Request notification permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $token');
    // TODO: Send this token to your backend to store it with user data for targeted notifications
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 Foreground message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    
    // Firebase automatically shows notifications on Android
    // If you need custom handling, add logic here
  }

  /// Handle background messages (when user taps notification)
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('👆 Background message tapped:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    
    // TODO: Navigate to alerts screen or handle based on message data
    // Example: if (message.data['type'] == 'alert') { /* navigate to alerts */ }
  }

  /// Subscribe to alert topics based on location
  Future<void> subscribeToAlertTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from alert topics
  Future<void> unsubscribeFromAlertTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to location-based topics
  Future<void> subscribeToLocationAlerts(String location) async {
    // Subscribe to city-specific alerts and general alerts
    final cityTopic = 'alerts_${location.toLowerCase().replaceAll(' ', '_')}';
    await subscribeToAlertTopic(cityTopic);
    await subscribeToAlertTopic('alerts_all');
    print('📍 Subscribed to location alerts for: $location');
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}