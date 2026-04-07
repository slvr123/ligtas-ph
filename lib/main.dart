import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disaster_awareness_app/services/fcm_service.dart';
import 'package:disaster_awareness_app/firebase_options.dart';
import 'app.dart';
//import 'temp_uploader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize FCM for push notifications
  try {
    await FCMService().initialize();
    print('✅ FCM initialized successfully');
  } catch (e) {
    print('❌ Error initializing FCM: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DisasterReadyApp());
  //runApp(const MyApp());
}
