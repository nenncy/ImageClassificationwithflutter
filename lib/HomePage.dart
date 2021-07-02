import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PickedFile? _image;
  bool _loading =false ; 
  List<dynamic>?_outputs;

  void initState() {
    super.initState();
    _loading = true;
    
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
}


//Load the Tflite model
loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
}

classifyImage(image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output;
    });
  }
  Future pickImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }


  final ImagePicker _picker = ImagePicker();

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Image Classification'),
        backgroundColor: Colors.purple,
        
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
                      
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null ? Container() : Image.file(File(_image!.path)),
                    SizedBox(
                      height: 20,
                    ),
                    _outputs != null
                        ? Text('${_outputs![0]["label"]}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              background: Paint()..color = Colors.white,
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
          
      floatingActionButton: FloatingActionButton(
        onPressed: _optiondialogbox,
        backgroundColor: Colors.purple,
        child: Icon(Icons.image),
      ),
    );
  }

  //camera method
  Future<void> _optiondialogbox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.purple,
            
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "Take a Picture",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    onTap: openCamera,
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  GestureDetector(
                    child: Text(
                      "Select image ",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    onTap: openGallery,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future openCamera() async {
    var image = await _picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = image ;
    });
  }

  //camera method
  Future openGallery() async {
    var piture = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = piture;
    }
     
    );
    classifyImage(piture);
  }
}
