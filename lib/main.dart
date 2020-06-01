import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cat or Dog?",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isloading = false;
  File _image;
  List _outputs;

  @override
  void initState() {
    super.initState();
    _isloading = true;
    loadModel().then((value) {
      setState(() {
        _isloading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text("CAT OR DOG ?")),
      body: _isloading
          ? Container(
            alignment: Alignment.center,
              child: SpinKitFadingCircle(color: Colors.white, size: 50),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height:h*0.05),
                  GestureDetector(
                    onTap: () {
                      chooseImage();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width:160,
                      height:40,
                      decoration: BoxDecoration(color: Colors.grey[100],borderRadius: BorderRadius.circular(10),),
                      child: Row(
                        children: <Widget>[
                          Text("Choose Image",style: TextStyle(color:Colors.black,fontSize: 20),),
                          Icon(Icons.image,color: Colors.black,size: 30,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height:h*0.05),
                  _image == null
                      ? Container(
                        height:400,
                        width:double.infinity,
                          child: Center(
                            child: Text(
                              "Select Image",
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        )
                      : Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        height:400,
                        width:double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_image,fit:BoxFit.cover)),),
                  SizedBox(height:h*0.05),
                        
                  _outputs!=null?Text(
                    "It's a ${_outputs[0]["label"]} !",
                    style: TextStyle(fontSize: 30),
                  ):Container(),
                ],
              ),
            ),
    );
  }

  chooseImage() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img == null) {
      return null;
    }
    _isloading = true;
    _image = img;
    detectImage(_image);
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.5,
    );
    setState(() {
      _isloading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
}
