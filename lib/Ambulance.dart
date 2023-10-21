import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

import 'ToastUtil.dart';

class Ambulance extends StatefulWidget {
  const Ambulance({super.key});

  @override
  State<Ambulance> createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {


  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), (Timer timer2) {
      getCurrLoc();
      gmapLink = "https://www.google.com/maps/place/$currLat,$currLong";
      print(currLat.toString()+" "+currLong.toString());
    });
    goToCurrentLoc();
    marker.addAll(markerList);
  }

  var gmapLink = "https://www.google.com/maps/place/29.2839,78.8281";
  var auth = FirebaseAuth.instance;
  var detector;

  var currLat=29.2839;
  var currLong=78.8281;
  var currCoordinates;

  late Timer smsTimer;
  var firestore = FirebaseFirestore.instance.collection("Aarogya");

  RegExp regex = RegExp(r"^\d+");


  List<Marker> marker = [];
  List<Marker> markerList = [
    Marker(markerId: MarkerId('1'), position: LatLng(37.42796133580664, -122.085749655962), infoWindow: InfoWindow(title: "target")),
  ];

  Completer<GoogleMapController> mapCtrl = Completer();
  var initLocation = CameraPosition(target: LatLng(29.2839, 78.8281), zoom: 14,);

  var pickLocCtrl = TextEditingController();
  var dropLocCtrl = TextEditingController();

  Future<Position> getCurrLoc() async{

    currCoordinates = await Geolocator.getCurrentPosition();

    if (mounted){
      setState(() {
        currLat = currCoordinates.latitude;
        currLong = currCoordinates.longitude;
        marker.removeWhere((m) => m.markerId.value == '2');
        marker.add(Marker(markerId: MarkerId('2'), position: LatLng(currLat, currLong), infoWindow: InfoWindow(title: "Current Location")),);

        initLocation = CameraPosition(
          target: LatLng(currLat, currLong),
          zoom: 14,
        );

      });
    }


    // }).onError((error, stackTrace) async{
    //   await Geolocator.requestPermission();
    //   print("Error fetching current location");
    // });

    return currCoordinates;
  }

  void goToCurrentLoc() async{


    await getCurrLoc().then((value) async{

      GoogleMapController ctrl = await mapCtrl.future;
      ctrl.animateCamera(CameraUpdate.newCameraPosition(
          initLocation
      ));

    });

  }

  Future<void> sendSms(String msg, String iPhone) async{
    if (await Permission.sms.status.isGranted){
      final Telephony telephony = Telephony.instance;
      // var permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
      telephony.sendSms(
        to: iPhone,
        message: msg,
        isMultipart: true,
      );
      print("sms sent to $iPhone");
    }
    else{
      print("Permissions not given for sms");
    }

  }

  void sendLocation() async{

    ToastUtil().toast("SOS Triggered");
    smsTimer = Timer.periodic(Duration(seconds: 15), (Timer timer) async{
      var query = await firestore.doc("SOS").collection("EmergencyContacts").get();
      query.docs.forEach((doc) async {
        var iPhone = doc.data()["iPhone"];
        await sendSms(gmapLink, iPhone);
      });
    });

  }
  void stopLocation(){
    ToastUtil().toast("SOS Stopped");
    smsTimer.cancel();
  }


  void makeCall(String number) async{

    if (await Permission.phone.isGranted) {
      FlutterPhoneDirectCaller.callNumber("+91"+number);
    } else {
      print("Permissions not granted for making a phone call");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xffececec),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Container(
                    width: 350,
                    height: 500,
                    decoration: BoxDecoration(
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Color(0xFF3E2445).withOpacity(0.6),
                      //     spreadRadius: 3,
                      //     blurRadius: 25,
                      //     offset: Offset(0, 30),
                      //   ),
                      // ],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.blue, // Specify your border color here
                        width: 2.0, // Specify the border width
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: GoogleMap(
                        initialCameraPosition: initLocation,
                        mapType: MapType.normal,
                        compassEnabled: true,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        markers: Set<Marker>.of(marker),
                        onMapCreated: (GoogleMapController controller){
                          mapCtrl.complete(controller);
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  Center(
                    child: InkWell(
                      onTap: (){
                        makeCall("8171592676");
                        sendLocation();
                      },
                      onLongPress: (){
                        stopLocation();
                        print("sms stopped");
                      },
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(child: Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                      ),
                    ),
                  ),

                  SizedBox(height: 40,),

                  Text("Ambulance Booking", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, height: 1.2, letterSpacing: 1.2),),
                  SizedBox(height: 20,),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xffE7F0FF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: pickLocCtrl,
                            decoration: InputDecoration(
                                hintText: "Pick Location",
                                hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Color(0xff468DFF), // Change this color to your desired hint text color
                                ),
                                prefixIcon: Icon(CupertinoIcons.pencil_circle, color: Color(0xff418AFF),),
                                suffixIcon: Icon(CupertinoIcons.xmark, color: Color(0xff418AFF),),
                                border: InputBorder.none
                            ),
                            maxLines: 1,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Mail Id";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black,
                        )
                      ),
                    ],
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xffE7F0FF),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: dropLocCtrl,
                            decoration: InputDecoration(
                                hintText: "Drop Location",
                                hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Color(0xff468DFF), // Change this color to your desired hint text color
                                ),
                                prefixIcon: Icon(CupertinoIcons.pencil_circle, color: Color(0xff418AFF),),
                                suffixIcon: Icon(CupertinoIcons.xmark, color: Color(0xff418AFF),),
                                border: InputBorder.none
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 40,
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black
                        ),
                        child: Center(child: Text("Pick Ambulance", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12, ),),),
                      ),
                      Container(
                        height: 40,
                        width: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue
                        ),
                        child: Center(child: Text("Book now !", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12, ),),),
                      ),
                    ],
                  ),
                  SizedBox(height: 120,),


                ],
              ),
            ),
          )

        ],
      )
    );
  }
}
