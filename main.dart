import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';

void main() {
  runApp(new MaterialApp(
    title: "Camera App",
    home: LandingScreen(),
  ));
}

final _scaffoldKey = GlobalKey<ScaffoldState>();

class LandingScreen extends StatefulWidget {
  @override
  LandingScreenState createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen> {
  File imageFile;

  _openGallery(BuildContext context) async {
    // ignore: deprecated_member_use
    File Picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      if (Picture != null) {
        _cropImage(Picture);
      }
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    // ignore: deprecated_member_use
    var Picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _cropImage(Picture);
    });
    Navigator.of(context).pop();
  }

  _cropImage(File picked) async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
    if (cropped != null) {
      setState(() {
        imageFile = cropped;
      });
    }
  }

  Future uploadPic(BuildContext context) async {
    String fileName = basename(imageFile.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    await uploadTask.onComplete;
    setState(() {
      final snackBar = SnackBar(content: Text('Pic uploaded'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  Future<Void> _showChoiceDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make a choice"),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () {
                    _openGallery(context);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () {
                    _openCamera(context);
                  },
                )
              ]),
            ),
          );
        });
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Text("No image selected");
    } else
      return Image.file(imageFile, width: 400, height: 400);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _decideImageView(),
              RaisedButton(
                onPressed: () {
                  _showChoiceDialogue(context);
                },
                child: Text("Select Image"),
              ),
              RaisedButton(
                onPressed: () {
                  uploadPic(context);
                },
                child: Text("Upload Image"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
