import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:http/http.dart' as http;


class MySendData extends StatefulWidget {
  @override
  _MySendDataState createState() => _MySendDataState();
}

class _MySendDataState extends State<MySendData> {

  String _dir;
  String _fileName = "myJSONFile.json";
  File jsonFile;
  List data1;
  String data2;



  Future<void> doStuff() async {
    await findDirFile();
    String f = '$_dir/$_fileName';
    print("file is: "+f);
    var jsonFile = File(f);
    //jsonFile = File('$_dir/$_fileName');
    jsonFile.readAsString().then((String contents) {
      //print("content: "+contents);
      //print(contents); //send contents to server as string
      data1 = jsonDecode(contents);
      data2=contents;

      //read string to json - then load files and send to server
      //print('file 0, ${data1[0]['file']}!');
      //print('file 0, ${data1[1]['file']}!');
      //print('file 0, ${data1[0]['lng']}!');

    });
  }

  @override
  initState() {
    super.initState();
    doStuff();
  }

  Future<void> sendData() async{
    print(data2);
    var response = await http.post("insert/path/file.php", body: {
      "content": data2,
    });
    //print(response.toString());
  }
  Future<void> findDirFile() async{
    _dir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
  }

  Future<void>upLoad(String fileName) async{
    String url="insert/path/file.php";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
        await http.MultipartFile.fromPath(
            'picture',
            fileName
        )
    );
    var res = await request.send();
  }
  startUploadImages() {
    //String f = data1[0]['file'];
    String f1 = '';
    String f2='';
    //print("file is: "+f1);
    //var imgFile = File(f1);
    for (var i=0;i<data1.length;i++){
      f2=data1[i]['file'];
      f1='$_dir/$f2';
      print(f1);
      upLoad(f1);
    }

  }





  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(

          title: Text('MY MAP - MARK ON MAP',
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
                title: Text('MAP'),
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
                flex: 1,
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    sendData();
                  },
                  child: Text(
                    "Send Data",
                    style: TextStyle(
                      fontFamily: 'Roboto-Black',
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              Expanded(
                flex: 1,
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    startUploadImages();
                  },
                  child: Text(
                    "Upload Images",
                    style: TextStyle(
                      fontFamily: 'Roboto-Black',
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

