import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:device_info/device_info.dart';
import 'package:share/share.dart';

class Sender extends StatefulWidget {
  const Sender({Key? key}) : super(key: key);

  @override
  _SenderState createState() => _SenderState();
}

class _SenderState extends State<Sender> {
  List<Marker> _markers = <Marker>[];
  String id = "";
  double speed = 0.0;
  double altitude = 0.0;
  void deviceid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      id = androidInfo.androidId;
    });
  }

  void initState() {
    super.initState();
    deviceid();

    Geolocator.getPositionStream(intervalDuration: Duration(seconds: 2))
        .listen((event) {
      currentLocation = event;
      setState(() {
        lat = currentLocation.latitude;
        lang = currentLocation.longitude;
        speed = currentLocation.speed;
        altitude = currentLocation.altitude;
      });
      FirebaseFirestore.instance
          .collection("GeoData")
          .doc(id)
          .set({"dummy": "xyz"});
      FirebaseFirestore.instance
          .collection("GeoData")
          .doc(id)
          .collection("live location")
          .doc(DateTime.now().toString())
          .set({"position": currentLocation.toJson()});
    });
  }

  double lat = 0.0;
  double lang = 0.0;
  late GoogleMapController mapController;
  LatLng target = LatLng(0, 0);

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(45.521563, -122.677433), zoom: 16);
  late Position currentLocation;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = HashSet<Marker>();

  void _printandsetlocation() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo.androidId);
    setState(() {
      id = androidInfo.androidId;
    });
    var newPosition = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 16);

    CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
    CameraUpdate zoom = CameraUpdate.zoomTo(16);
    setState(() {
      lat = currentLocation.latitude;
      lang = currentLocation.longitude;
      speed = currentLocation.speed;
      altitude = currentLocation.altitude;
    });
    mapController.moveCamera(update);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(id,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              IconButton(
                  onPressed: () {
                    Share.share(id);
                  },
                  icon: Icon(Icons.share))
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Stack(children: <Widget>[
          Card(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              //     markers: Set<Marker>.of(_markers),
              initialCameraPosition: _initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "latitude:${lat.toStringAsFixed(3)}",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("  longitude:${lang.toStringAsFixed(3)}",
                          style: TextStyle(fontSize: 20))
                    ],
                  ),
                )),
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Speed:${speed.toStringAsFixed(3)}",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("  Altitude:${altitude.toStringAsFixed(3)}",
                          style: TextStyle(fontSize: 20))
                    ],
                  ),
                )),
              ],
            ),
            top: 10,
            right: 10,
          )

          //   Positioned(child: SizedBox(width: 200,child: ListTile(trailing: Row(children: <Widget>[Text("latitude:$lat"), Text("longitude:$lang")],),)), bottom: 10,),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _printandsetlocation,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), //
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
