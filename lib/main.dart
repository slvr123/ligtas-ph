import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disaster_awareness_app/services/fcm_service.dart';
import 'app.dart';
//import 'temp_uploader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCgRd6vyUsLrsNvfNkV_vlp7WJnrRZ51Zo",
          authDomain: "ligtas-ph-dev.firebaseapp.com",
          projectId: "ligtas-ph-dev",
          storageBucket: "ligtas-ph-dev.appspot.com",
          messagingSenderId: "1025608025233",
          appId: "1:1025608025233:web:bd1172e1a435fab147eb30",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
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
