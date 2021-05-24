import 'dart:async';
import 'dart:convert';
//import 'dart:html';
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
import 'package:speech_recognition/speech_recognition.dart';

class MyMapCamera extends StatefulWidget {
  @override
  _MyMapCameraState createState() => _MyMapCameraState();
}

enum SingingCharacter { photo, video, timeVideo, timePhoto }

class _MyMapCameraState extends State<MyMapCamera> {
  Timer t1;

  CameraPosition mypos;
  double lat=55.457397;
  double lng=10.371471;
  double zoom=13.0;

  GoogleMapController mapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  MarkerId selectedMarker;
  List <MyLatLng> myLatLng = [];
  Location location = Location();
  LocationData _location;
  BitmapDescriptor sourceIcon;
  String _error;
  StreamSubscription<LocationData> _locationSubscription;

  //properties camera
  String inputdata = 'Camera';
  String _newFile = "";
  final Permission _permission=Permission.storage;
  String _dir = "";
  String _filename = "";
  final myTransformer = Xml2Json();
  SingingCharacter _character = SingingCharacter.photo;

  //save json file
  File jsonFile;
  String fileName = "myJSONFile.json";

  @override
  initState() {
    super.initState();

    mypos=CameraPosition(target: new LatLng(lat, lng),zoom: zoom);
    // set the initial location
    //setSourceIcon();
    _listenLocation();
    initPermission();
    findDirFile();
    //not working - phone is connected to cam locally - no internet - activateSpeechRecognizer();
    //addInitialMarker();
  }
  //camera start
  void initPermission() async{
    final status = await _permission.request();
    setState(() {
      inputdata=status.toString();
    });
  }

  void findDirFile() async{
    _dir = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    //_filename = await getLastPhotoFromCamera();
  }

  //get files from browsing and locate newest file to download
  Future<String> getLastPhotoFromCamera(String getIt) async {

    Uri uri = Uri.parse(getIt);
    var response = await http.get(uri);
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
  //this is stopping video after time out. We know camera is in video mode
  Future<String> handleTimeout() async {  // callback function
    String myLocalString = 'Video not stopped';
    Uri uri1 = Uri.parse('http://192.168.1.254/?custom=1&cmd=2001&par=0');
    var response1 = await http.get(uri1);
    if (response1.statusCode == 200) {
      //get video from cam to phone download folder
      _filename = await getLastPhotoFromCamera('http://192.168.1.254/DCIM/MOVIE');
      String isDownloaded=await downloadFileFromCamera();
      myLatLng.add(MyLatLng(_newFile,_location.latitude.toString(), _location.longitude.toString()));

      //Each time app take picture+lat+lng, app save data of List to json file
      //create a json string from class objects in list
      String jsonTags = jsonEncode(myLatLng);
      //print(jsonTags);
      //get the name of the file
      jsonFile = File('$_dir/$fileName');
      //overwrite the json file with new data
      jsonFile.writeAsStringSync(jsonTags);

      myTransformer.parse(response1.body);
      // Transform to JSON
      var jsonString1 = myTransformer.toParker();
      var data1 = convert.jsonDecode(jsonString1);
      //find Status in XML file
      var status1 = data1['Function']['Status'];
      if (status1 == 0) {
        myLocalString = 'Video stopped';
        //set to photomode again - standard in app
        uri1 = Uri.parse('http://192.168.1.254/?custom=1&cmd=3001&par=0');
        response1 = await http.get(uri1);
      }else if (status1 == -13) {
        myLocalString = 'Camera not in video mode';
      } else if (status1 == -22) {
        myLocalString = 'No MicroSD card';
      }
    }
    return myLocalString;
  }
  //take video
  Future<String> _takePhotoVideo() async {
    String myLocalString = 'no Video';
    //change to video mode
    Uri uri1 = Uri.parse('http://192.168.1.254/?custom=1&cmd=3001&par=1');
    var response1 = await http.get(uri1);
    if (response1.statusCode == 200) {

      myTransformer.parse(response1.body);
      // Transform to JSON
      var jsonString1 = myTransformer.toParker();
      var data1 = convert.jsonDecode(jsonString1);
      //find Status in XML file
      var status1 = data1['Function']['Status'];
      if (status1 == 0) { //changed to video mode - start making video

        Uri uri = Uri.parse('http://192.168.1.254/?custom=1&cmd=2001&par=1');


        var response = await http.get(uri);

        if (response.statusCode == 200) {
          myTransformer.parse(response.body);
          // Transform to JSON
          var jsonString = myTransformer.toParker();
          var data = convert.jsonDecode(jsonString);
          var status = data['Function']['Status'];
          if (status == 0) {
            //video started - start timer 5 seconds for stop video
            var videoTime = const Duration(seconds: 5);
            t1=Timer(videoTime,handleTimeout);//handleTimeout must stop video
            //start timer and then stop video after timer
            myLocalString = 'video OK';
          } else if (status == -11) {
            myLocalString = 'MemCard empty';
          } else if (status == -13) {
            myLocalString = 'Camera not in video mode';
          } else if (status == -22) {
            myLocalString = 'No MicroSD card';
          } else {
            myLocalString = "Status number: " + response.statusCode.toString();
          }
        }

        setState(() {
          inputdata = myLocalString;
        });
      }//if (status1 == 0)
    }//if (response1.statusCode == 200)
    return myLocalString;
  }

  //take photo
  Future<String> _takePhotoImage() async {

    Uri uri = Uri.parse('http://192.168.1.254/?custom=1&cmd=1001');

    String myLocalString='no Photo';
    var response = await http.get(uri);

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

  Future<String> downloadFileFromCamera() async {


    //if file is found - more check above maybe
    if (_filename != "fail"){
      http.Client client = new http.Client();
      var url = 'http://192.168.1.254'+_filename;
      _newFile = _filename.substring(12,_filename.length);


      var req = await client.get(Uri.parse(url));

      var bytes = req.bodyBytes;


      File file = File('$_dir/$_newFile');

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

  //camera end

  //map start
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }


  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
          setState(() {
            _error = err.code;
          });
          _locationSubscription.cancel();
          //return to previous screen
          Navigator.pushNamed(context, '/first');
        }).listen((LocationData currentLocation) {

          setState(() {
            _error = null;

            _location = currentLocation;

            mypos = CameraPosition(target: new LatLng(_location.latitude, _location.longitude),zoom: zoom,);
            /*mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                mypos,
              ),
            );*/
            //setupMap();
          });
        });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
  }

  @override
  void deactivate(){
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _stopListen();

  }

  //take photo and transfer to download folder
  //then make a new Marker
  //write extend json file with both
  //finally create the new Marker in Google Maps
  void _add() async {
    //take the photo - no check for now of fault
    String myResult = await _takePhotoImage();
    //return string with filename or string fail - no check for now of fail
    _filename = await getLastPhotoFromCamera('http://192.168.1.254/DCIM/PHOTO');
    //print("add: "+_filename);
    //download image to download folder on android phone
    String isDownloaded=await downloadFileFromCamera();
    //print("add: "+isDownloaded);
    //image end
    //Now create the marker
    //length of list of Markers

    //log('data: $_location.latitude');
    //add the filename, lat, lon to List of Classes
    myLatLng.add(MyLatLng(_newFile,_location.latitude.toString(), _location.longitude.toString()));

    //Each time app take picture+lat+lng, app save data of List to json file
    //create a json string from class objects in list
    String jsonTags = jsonEncode(myLatLng);
    //print(jsonTags);
    //get the name of the file
    jsonFile = File('$_dir/$fileName');
    //overwrite the json file with new data
    jsonFile.writeAsStringSync(jsonTags);



  }

  Future<void> deleteFile() async {
    try {
      var file = File(_filename);

      if (await file.exists()) {
        // file exits, it is safe to call delete on it
        await file.delete();
      }

    } catch (e) {
      // error in getting access to the file
    }
  }

  void _remove() {
    setState(() {
      if (_markers.containsKey(selectedMarker)) {
        _markers.remove(selectedMarker);
      }
    });
    //delete image in Download folder
    deleteFile();
    //update list
    MyLatLng l1 = myLatLng.removeLast();
    MyLatLng l2 = myLatLng.last;
    _filename = l2.file;
    //write json file
    String jsonTags = jsonEncode(myLatLng);
    jsonFile = File('$_dir/$fileName');
    jsonFile.writeAsStringSync(jsonTags);

  }

  //map end

  @override
  Widget build(BuildContext context) {

    final GoogleMap googleMap = GoogleMap(
      initialCameraPosition: mypos,
      onMapCreated: _onMapCreated,
    );

    return Scaffold(
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
              title: Text('Settings'),
              onTap: (){
                Navigator.pushNamed(context, '/MySettings');
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
              onTap: (){
                Navigator.pushNamed(context, '/MyMap');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('PhotoCheck'),
              onTap: (){
                Navigator.pushNamed(context, '/MyPhoto');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation)=>
          orientation == Orientation.portrait ? buildPortrait() : buildLandscape(),
        ),
      ),
    );
  }
  Widget buildButton(int myFlex, Function f, String s, double fSize, Color fColor, Color bColor, Color tColor, String fFamily) => Expanded(
    flex: myFlex,
    child: SizedBox.expand(
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(fColor),
          backgroundColor: MaterialStateProperty.all<Color>(bColor),
        ),
        //color: Colors.blue,
        //textColor: Colors.white,
        onPressed: () => f,
        child: Text(
          s,
          style: TextStyle(
            fontFamily: fFamily,
            fontSize: fSize,
            color: tColor,
          ),
        ),
      ),
    ),
  );


  Widget buildLandscape() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      buildButton(2, _add, "PHOTO", 22.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),
      SizedBox(width: 5),
      buildButton(2, _takePhotoVideo, "VIDEO", 22.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),
      SizedBox(width: 5),
      buildButton(2, _remove, "DELETE", 22.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),
    ],
  );

  Widget buildPortrait() => Column(

    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      buildButton(2, _add, "PHOTO", 48.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),
      SizedBox(height: 5),
      buildButton(2, _takePhotoVideo, "VIDEO", 48.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),
      SizedBox(height: 5),
      buildButton(2, _remove, "DELETE", 48.0, Colors.white, Colors.blue, Colors.white, "Roboto-Black"),


    ],
  );

}
