import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_object_dectection_app/main.dart';
import 'package:flutter_object_dectection_app/scr/loading.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  void loadingWidget() async {
    await Future.delayed(Duration(seconds: 4), () {
      setState(() {
        isLoading = true;
      });
    });
  }

  CameraImage imgCamera;
  CameraController cameraController;
  bool isWorking = false;
  String result = "";

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224.tflite',
      labels: 'assets/mobilenet_v1_1.0_224.txt',
    );
  }

  initCamera() {
    cameraController = CameraController(camera[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((image) {
          if (!isWorking) {
            isWorking = true;
            imgCamera = image;
            runModelOnStreamFrames();
          }
        });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
      );

      result = "";
      recognitions.forEach((element) {
        result += element["label"] +
            "  " +
            (element["confidence"] as double).toString() +
            "%\n\n";
      });

      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadingWidget();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? LoadingSrc()
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SafeArea(
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          Center(
                            child: Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                          ),
                          Center(
                            child: FlatButton(
                              onPressed: () {
                                initCamera();
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 35),
                                height: 270,
                                width: MediaQuery.of(context).size.width,
                                child: imgCamera == null
                                    ? Container(
                                        height: 270,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Icon(
                                          Icons.photo_camera_front,
                                          color: Colors.blue,
                                          size: 40,
                                        ),
                                      )
                                    : AspectRatio(
                                        aspectRatio:
                                            cameraController.value.aspectRatio,
                                        child: CameraPreview(cameraController),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 35),
                          child: SingleChildScrollView(
                            child: Text(
                              '${result}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
