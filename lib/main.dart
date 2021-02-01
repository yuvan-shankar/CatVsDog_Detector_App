import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  File _image;
  List _output;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  uploadImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cat Vs Dog"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Text(
              "Hey guys,",
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Detect Cat Or Dog",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              child: _loading
                  ? Container(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/dogcat.png",
                            width: 300.0,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Image.file(_image),
                          ),
                          SizedBox(height: 20),
                          _output != null
                              ? Text(
                                  "This is a ${_output[0]['label']}",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 40.0),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 13.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "Capture Photo",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () {
                      uploadImage();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 13.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "Upload Photo",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
