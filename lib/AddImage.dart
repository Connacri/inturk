import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'home.dart';

class AddImage extends StatefulWidget {
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool uploading = false;
  double val = 0;
  late firebase_storage.Reference ref;

  TextEditingController _itemController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _likesController = new TextEditingController();
  String _typeSelected = '';

  CollectionReference imgRef =
      FirebaseFirestore.instance.collection('Products');

  List<File> _image = [];

  final picker = ImagePicker();

  @override
  Widget _buildContactType(String catego) {
    return InkWell(
      child: Container(
        //height: 45,
        width: 100, //MediaQuery.of(context).size.width*0.25,
        decoration: BoxDecoration(
          color: _typeSelected == catego
              ? Colors.green
              : Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            catego,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _typeSelected = catego;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajouter Une Annonce'),
        ),
        body: ListView(children: [
          Container(
            height: 300, // zedtha 10h34**************
            padding: EdgeInsets.all(44),
            child: GridView.builder(
                physics:
                    NeverScrollableScrollPhysics(), // zedtha 10h34***************
                shrinkWrap: true, // zedtha 10h34***************
                itemCount: _image.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //mainAxisExtent: 2
                ),
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                          child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () =>
                                  !uploading ? chooseImage() : null),
                        )
                      : Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(_image[index - 1]),
                                  fit: BoxFit.cover)),
                        );
                }),
          ),
          uploading
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Text(
                        'uploading...',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(
                      value: val,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    )
                  ],
                ))
              : Container(),
          TextFormField(
            controller: _itemController,
            decoration: InputDecoration(
              hintText: 'Enter Item',
              prefixIcon: Icon(
                Icons.account_circle,
                size: 30,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: 'Enter Code',
              prefixIcon: Icon(
                Icons.account_circle,
                size: 30,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              hintText: 'Enter Price',
              prefixIcon: Icon(
                Icons.phone_iphone,
                size: 30,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _likesController,
            decoration: InputDecoration(
              hintText: 'Enter likes',
              prefixIcon: Icon(
                Icons.phone_iphone,
                size: 30,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Enter Déscription',
              prefixIcon: Icon(
                Icons.phone_iphone,
                size: 30,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
            ),
          ),

//CATEGORIES**********************************************************
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Container(
              height: 35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildContactType('Hotel'),
                  SizedBox(width: 10),
                  _buildContactType('Residence'),
                  SizedBox(width: 10),
                  _buildContactType('Agence'),
                  SizedBox(width: 10),
                  _buildContactType('Autres'),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
//ADD ITEMS***********************************************************
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: RaisedButton(
              child: Text(
                'Ajouter',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                setState(() {
                  uploading = true;
                  home();
                });
                uploadFile().whenComplete(() => Navigator.of(context).pop());
              },
              color: Theme.of(context).primaryColor,
            ),
          ),
        ]));
  }

  chooseImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxHeight: 1080,
        maxWidth: 1920);

    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    int i = 1;
    String item = _itemController.text;
    String price = _priceController.text;
    String code = _codeController.text;
    String description = _descriptionController.text;
    String likes = _likesController.text;
    var now = DateTime.now().millisecondsSinceEpoch;
    List<String> _imageFiles = []; //****************

    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(img.path)}');

//***********************************************************************************
      /*DocumentReference doc_ref=FirebaseFirestore.instance.collection("board").doc(doc_id);
      DocumentSnapshot docSnap = await doc_ref.get();
      var doc_id2 = docSnap.reference.documentID;*/
//***********************************************************************************

      await ref.putFile(img).whenComplete(() async {
        //*****************************************
        await ref.getDownloadURL().then((value) {
          _imageFiles.add(value);
          i++;

          /*     i++;
              i < 3
                  ? setItems(
                  value, item, code, price, _typeSelected, now.toString()
              )*/
          /*: FirebaseFirestore.instance
                  .collection('UserContent')
                  .doc().snapshots();*/
//***********************************************************************************
          /*Future<String> get_data(DocumentReference doc_ref) async {
                DocumentSnapshot docSnap = await doc_ref.get();
                var doc_id2 = docSnap.reference.documentID;
                return doc_id2;
              }
              //To retrieve the string
                  String documentID = await get_data();*/
//***********************************************************************************
          /* FirebaseFirestore.instance
                  .collection('UserContent')
                  .doc()
                  .set({'url${i - 1}': value} */ /*,SetOptions().mergeFields);*/
          //il faut voir doc() pour eviter put
          /*if(i==1){
            setItems(value, item, code, price, _typeSelected, now.toString());
          } else {
            //setItems(value, item, code, price, _typeSelected, now.toString());
            FirebaseFirestore.instance.collection('UserContent').doc().set({'url$i': value});
          }*/
        });
      });
    }
    //print(_imageFiles);


    imgRef.add({
      'themb': _imageFiles.first,
      'urls': _imageFiles,
      "item": item,
      'code': code,
      'price': price, // + '.00 dzd ',
      'category': _typeSelected,
      'createdAt': Timestamp.now(), //now.toString(),
      'Description' : description,
      'likes': likes
    });
  }

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection('Products');
  }
}
