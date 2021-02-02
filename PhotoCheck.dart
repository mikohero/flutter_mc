import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'LatLng.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
//import camera
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert' as convert;
class MyPhotoControl extends StatefulWidget {
  @override
  _MyPhotoControlState createState() => _MyPhotoControlState();
}

class _MyPhotoControlState extends State<MyPhotoControl> {
  String dir="";
  String _newFile="";
  String inputdata="";
  String _filename="";
  String path="";
  final myTransformer = Xml2Json();

  @override
  initState() {
    super.initState();
    findDir();
  }

  void findDir() async{
    dir = await findDirFile();
    print("findDir: "+dir);
  }

  Future<String> downloadFileFromCamera() async {


    //if file is found - more check above maybe
    if (_filename != "fail"){
      http.Client client = new http.Client();
      var url = 'http://192.168.1.254'+_filename;
      _newFile = _filename.substring(12,_filename.length);


      var req = await client.get(Uri.parse(url));

      var bytes = req.bodyBytes;


      File file = File('$dir/$_newFile');

      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      await file.writeAsBytes(bytes);
      setState(() {
        inputdata = "photo downloaded";
      });
      return "photo downloaded";
    }else {
      setState(() {
        inputdata = "Failed to get photoname";
      });
      return "photo not downloaded";
    }
  }

  void _add() async {

    String myResult = await _takePhotoImage();
    _filename = await getLastPhotoFromCamera();
    String isDownloaded=await downloadFileFromCamera();
    print("add: "+isDownloaded);
    String _myfilename = _filename.substring(12,_filename.length);
    setState(() {
      path = dir+"/"+_myfilename;
    });

  }

  Future<String> findDirFile() async{
    String myDir="";
    return myDir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    //_filename = await getLastPhotoFromCamera();
  }

  //take photo
  Future<String> _takePhotoImage() async {
    final String url = 'http://192.168.1.254/?custom=1&cmd=1001';
    String myLocalString='no Photo';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      myTransformer.parse(response.body);
      // Transform to JSON
      var jsonString = myTransformer.toParker();
      var data = convert.jsonDecode(jsonString);
      var status = data['Function']['Status'];
      if (status == 0) {
        myLocalString = 'photo OK';
      }else if (status == -13) {
        myLocalString = 'Camera not in photo mode';
      }else if (status == -22) {
        myLocalString = 'No MicroSD card';
      }else {
        myLocalString = "Status number: "+response.statusCode.toString();
      }
    }
    setState(() {
      inputdata = myLocalString;
    });
    return myLocalString;
  }

  //get files from browsing and locate newest file to download
  Future<String> getLastPhotoFromCamera() async {
    var url = 'http://192.168.1.254/DCIM/PHOTO';
    var response = await http.get(url);
    var val;
    if (response.statusCode == 200) {
      var document = parse(response.body);
      print("document: "+document.toString());
      //newest photo is last with 2 x a href.
      //get all the a href into a list
      var list = document.getElementsByTagName('a');
      //get the second list a href from list - last is for delete
      var len = list.length-2;
      var elemen1 = list[len];
      print("element: "+elemen1.toString());
      //run through the attributes. only one in a - href
      elemen1.attributes.forEach((k, v) {
        print('{ key: $k, value: $v }');
        val = v;
      });
      print("getLastPhotoFromCamera: "+val);
      return val;
    }else {
      return 'fail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(

          title: Text('MY MAP - Photo',
            style: TextStyle(
              fontFamily: 'Roboto-Black',
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green[700],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget> [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Go To',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: (){
                  Navigator.pushNamed(context, '/MySettings');
                },
              ),
              ListTile(
                leading: Icon(Icons.add_location),
                title: Text('Map'),
                onTap: (){Navigator.pushNamed(context, '/');},
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Image(
                  image: FileImage(File(path))
                ),
              ),
              Expanded(
                flex: 2,
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    _add();
                  },
                  child: Text(
                    "Photo",
                    style: TextStyle(
                      fontFamily: 'Roboto-Black',
                      fontSize: 48.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

}

