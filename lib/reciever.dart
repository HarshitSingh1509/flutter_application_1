import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:device_info/device_info.dart';

class Reciever extends StatefulWidget {
  final String deviceid;
  Reciever(this.deviceid);

  @override
  _RecieverState createState() => _RecieverState();
}

class _RecieverState extends State<Reciever> {
  double lat = 0.0;
  double lang = 0.0;
  late GoogleMapController mapController;
  LatLng target = LatLng(0, 0);

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(45.521563, -122.677433), zoom: 16);
  Position currentLocation = Position(
      longitude: 45.521563,
      latitude: -122.677433,
      timestamp: DateTime(2000),
      accuracy: 1,
      altitude: 2,
      heading: 1,
      speed: 0,
      speedAccuracy: 0);
  List<Marker> _markers = <Marker>[];
  String id = "";
  List<String> allData = [];
  int a = 0;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection("/GeoData/${widget.deviceid}/live location")
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        if (this.mounted) {
          setState(() {
            a = 1;
          });
        }
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text("GPS DEMO APP"),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  id,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        body:
            // return showDialog(
            //   context: context,
            //   builder: (context) {
            //     return AlertDialog(
            //       // Retrieve the text the that user has entered by using the
            //       // TextEditingController.
            //       content: Text(myController.text),
            //     );
            //   },)

            //  return showDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog(
            //               // Retrieve the text the that user has entered by using the
            //               // TextEditingController.
            //               content: Text(myController.text),
            //             );
            //           },)

            SafeArea(
                child: StreamBuilder<dynamic>(
                    stream: FirebaseFirestore.instance
                        .collection("/GeoData")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'No Data...',
                        );
                      } else {
                        printcoll();

                        return SizedBox(
                          height: 700,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  height: 600,
                                  child: Card(
                                      child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(80, 30),
                                      // target: LatLng(
                                      //     snapshot.data!.docs
                                      //             .last["position"]
                                      //         ["latitude"],
                                      //     snapshot.data!.docs
                                      //             .last["position"]
                                      //         ["longitude"]),
                                      zoom: 3,
                                    ),
                                    mapType: MapType.normal,
                                    markers: Set<Marker>.of(_markers),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      mapController = controller;
                                    },
                                  )),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                    itemCount: allData.length,
                                    itemBuilder: (context, index) => StreamBuilder<
                                            dynamic>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                "/GeoData/${allData[index]}/live location")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Text(
                                              'No Data...',
                                            );
                                          } else {
                                            if (a == 1) {
                                              return AlertDialog(
                                                content: Text(
                                                    "Sorry, Device id is wrong or no data available"),
                                              );
                                            }
                                          }
                                          _markers.add(Marker(
                                              markerId:
                                                  MarkerId(index.toString()),
                                              position: LatLng(
                                                  snapshot.data!.docs
                                                          .last["position"]
                                                      ["latitude"],
                                                  snapshot.data!.docs
                                                          .last["position"]
                                                      ["longitude"]),
                                              infoWindow: InfoWindow(
                                                  title:
                                                      'The title of the marker')));
                                          print(_markers);
                                          return Container();
                                          //  Padding(
                                          //   padding: const EdgeInsets.all(20),
                                          //   child: SizedBox(
                                          //     height: 700,
                                          //     child: Card(
                                          //         child: GoogleMap(
                                          //       initialCameraPosition:
                                          //           CameraPosition(
                                          //         target: LatLng(
                                          //             snapshot.data!.docs
                                          //                     .last["position"]
                                          //                 ["latitude"],
                                          //             snapshot.data!.docs
                                          //                     .last["position"]
                                          //                 ["longitude"]),
                                          //         zoom: 9.0,
                                          //       ),
                                          //       mapType: MapType.normal,
                                          //       markers:
                                          //           Set<Marker>.of(_markers),
                                          //       onMapCreated:
                                          //           (GoogleMapController
                                          //               controller) {
                                          //         mapController = controller;
                                          //       },
                                          //     )),
                                          //   ),
                                          // );
                                        })),
                              ),
                            ],
                          ),
                        );
                      }
                    })));
  }

  Future<void> printcoll() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('GeoData');

    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List

    setState(() {
      allData = querySnapshot.docs.map((doc) => doc.id).toList();
    });

    //  print(allData);
  }
  //
}
