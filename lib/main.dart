import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_object_dectection_app/scr/homepage.dart';
import 'package:flutter_object_dectection_app/scr/loading.dart';

List<CameraDescription> camera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  camera = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dectection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
