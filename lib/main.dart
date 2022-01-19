import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'screens/camera_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = await availableCameras();

  CameraDescription mainCamera = cameras.firstWhere(
      (element) => element.lensDirection == CameraLensDirection.back);

  runApp(MyApp(mainCamera: mainCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription mainCamera;
  const MyApp({Key? key, required this.mainCamera}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Reviews',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(
        camera: mainCamera,
      ),
    );
  }
}
