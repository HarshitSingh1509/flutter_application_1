import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('GeoData').snapshots();

  @override
  Widget build(BuildContext context) {
    var doc_ref = FirebaseFirestore.instance.collection("GeoData").get();
    //document(doc_id).collection("Dates").getDocuments();
    doc_ref.then((value) => print(value.docs));
// forEach((result) {
    //print(result.documentID);
//});
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          // print(snapshot.data!.document);
          return Scaffold();
        },
      ),
    );
  }
}
