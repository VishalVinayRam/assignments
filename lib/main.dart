import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'screens/set_photo_screen.dart';
import 'package:native_notify/native_notify.dart';
import 'package:firebase_core/firebase_core.dart';

background() async {
  try {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "flutter_background example app",
      notificationText:
          "Background notification for keeping the example app running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    bool success =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    if (success) {
      FlutterBackground.enableBackgroundExecution();
    }
  } catch (e) {
    print(e);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NativeNotify.initialize(2225, '08pjyYJ3ppgb3bXqPBxOOV');
  background();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Picker and Cropper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SetPhotoScreen(),
    );
  }
}
