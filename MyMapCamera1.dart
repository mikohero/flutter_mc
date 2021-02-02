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

class MyMapCamera extends StatefulWidget {
  @override
  _MyMapCameraState createState() => _MyMapCameraState();
}

enum SingingCharacter { photo, video, timeVideo, timePhoto }

class _MyMapCameraState extends State<MyMapCamera> {
  CameraPosition mypos;
  double lat=55.457397;
  double lng=10.371471;
  double zoom=16.0;

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
    
    mypos=CameraPosition(target: new LatLng(lat, lng),zoom: zoom,);
    // set the initial location
    setSourceIcon();
    _listenLocation();
    initPermission();
    findDirFile();
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

  void setSourceIcon() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/driving_pin.png');
  }

  void addInitialMarker() {
    final String markerIdVal = 'sourcePin';
    final MarkerId markerId = MarkerId(markerIdVal);


    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat,lng),
        icon: sourceIcon
    );

    setState(() {
      _markers[markerId] = marker;
    });
    //String s = _markers[markerId].toString();
    //log('markers: $s');
  }

  void setupMap() {
    addInitialMarker();
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

            mypos = CameraPosition(target: new LatLng(_location.latitude, _location.longitude),zoom: 16.0,);
            mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                mypos,
              ),
            );
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


  void _add() async {
    //image start
    //take photo and send to download. Hold filename
    String myResult = await _takePhotoImage();
    _filename = await getLastPhotoFromCamera();
    print("add: "+_filename);
    String isDownloaded=await downloadFileFromCamera();
    print("add: "+isDownloaded);
    //image end

    final int markerCount = _markers.length;
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    selectedMarker = markerId;
    //log('data: $_location.latitude');
    myLatLng.add(MyLatLng(_newFile,_location.latitude.toString(), _location.longitude.toString()));

    String jsonTags = jsonEncode(myLatLng);
    print(jsonTags);
    jsonFile = File('$_dir/$fileName');
    jsonFile.writeAsStringSync(jsonTags);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(_location.latitude, _location.longitude),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        //_onMarkerTapped(markerId);

      },
      onDragEnd: (LatLng position) {
        //_onMarkerDragEnd(markerId, position);
      },
    );

    setState(() {
      //myLatLng
      _markers[markerId] = marker;
    });

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
                title: Text('Settings'),
                onTap: (){
                  Navigator.pushNamed(context, '/MySettings');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: GoogleMap(
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: mypos,
                  markers: Set<Marker>.of(_markers.values),
                  onTap: (LatLng latLng) {
                    // you have latitude and longitude here
                    var latitude = latLng.latitude;
                    var longitude = latLng.longitude;
                    _add();
                    //call mark here
                  },
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
                    "MARK",
                    style: TextStyle(
                      fontFamily: 'Roboto-Black',
                      fontSize: 48.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                flex: 2,
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    _remove();
                  },
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      fontFamily: 'Roboto-Black',
                      fontSize: 48.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
