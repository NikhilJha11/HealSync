import 'dart:async';
import 'dart:io';

import 'package:aarogya/SplashPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ToastUtil.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.location.request();

  runApp(MaterialApp(
    home: SplashPage(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var d_name ="Disease Name";
  var dr_name = "Doctor Name";
  var dr_code = "Doctor Code";
  var severity = "Severity";
  var symptoms = "Symptoms";

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), (Timer timer2) {
      getCurrLoc();
      gmapLink = "https://www.google.com/maps/place/$currLat,$currLong";
      print(currLat.toString()+" "+currLong.toString());
    });

    loadModel();
  }

  var symptomCtrl = TextEditingController();
  var severityCtrl = TextEditingController();
  var durationCtrl = TextEditingController();

  var firestore = FirebaseFirestore.instance.collection("Aarogya");
  var auth = FirebaseAuth.instance;
  var detector;

  var currLat=29.2839;
  var currLong=78.8281;
  var currCoordinates;
  var gmapLink = "https://www.google.com/maps/place/29.2839,78.8281";

  late Timer smsTimer;

  RegExp regex = RegExp(r"^\d+");

  Future<Position> getCurrLoc() async{
    currCoordinates = await Geolocator.getCurrentPosition();
    if (mounted){
      setState(() {
        currLat = currCoordinates.latitude;
        currLong = currCoordinates.longitude;
      });
    }

    return currCoordinates;
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

  File? photoFile;
  File? finalPhotoFile;
  List<dynamic> results = [];

  void getPhoto({required ImageSource source}) async{
    var pickedImg = await ImagePicker().pickImage(source: source);

    if (pickedImg != null){
      setState(() {
        photoFile = File(pickedImg.path);
      });

      print("photoFile :"+photoFile.toString());
      imageClassification(photoFile!);
    }
    else{
      print("Pick an image");
    }
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
  void makeCall(String number) async{

    if (await Permission.phone.isGranted) {
      FlutterPhoneDirectCaller.callNumber("+91"+number);
    } else {
      print("Permissions not granted for making a phone call");
    }

  }

  Future loadModel() async{
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    )
    )!;

    print("model fetching status "+res);

  }

  Future imageClassification(File imgFile) async{
    var recognitions = await Tflite.runModelOnImage(
      path: imgFile.path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      results = recognitions!;
      finalPhotoFile = imgFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffececec),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40,),
                  Text("Get", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 28, height: 1.2, letterSpacing: 1.2),),
                  Text("Recommendations", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, height: 1.2, letterSpacing: 1.2),),
                  SizedBox(height: 70,),

                  Text("  Symptoms", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, height: 1.2, letterSpacing: 1.2),),
                  SizedBox(height: 8,),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xffE7F0FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15,),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: symptomCtrl,
                            decoration: InputDecoration(
                                hintText: "Enter Symtomps",
                                hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Color(0xff468DFF), // Change this color to your desired hint text color
                                ),
                                border: InputBorder.none
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("  Severity", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, height: 1.2, letterSpacing: 1.2),),
                          SizedBox(height: 8,),
                          Container(
                            height: 60,
                            width: 170,
                            decoration: BoxDecoration(
                              color: Color(0xffE7F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: severityCtrl,
                                  decoration: InputDecoration(
                                      hintText: "Severity Level",
                                      hintStyle: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xff468DFF), // Change this color to your desired hint text color
                                      ),
                                      border: InputBorder.none
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("  Duration", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, height: 1.2, letterSpacing: 1.2),),
                          SizedBox(height: 8,),
                          Container(
                            height: 60,
                            width: 170,
                            decoration: BoxDecoration(
                              color: Color(0xffE7F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: durationCtrl,
                                  decoration: InputDecoration(
                                      hintText: "Duration (in days)",
                                      hintStyle: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xff468DFF), // Change this color to your desired hint text color
                                      ),
                                      border: InputBorder.none
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 40,),
                  Center(
                    child: InkWell(
                      onTap: () async{
                        if (symptomCtrl.text!=null){
                          var query2 = await firestore.doc("Diseases").collection("DiseaseUids")
                              .where("symptoms", isEqualTo: symptomCtrl.text)
                              .where("severity", isEqualTo: severityCtrl.text)
                              .get();
                          query2.docs.forEach((doc) async {
                            setState(() {
                              d_name = doc.data()["d_name"];
                              dr_name = doc.data()["dr_name"];
                              dr_code = doc.data()["dr_code"];
                              severity = doc.data()["severity"];
                              symptoms = doc.data()["symptoms"];


                            });

                            firestore.doc("Patients").collection("PatientUids").doc(auth.currentUser!.uid).collection("History").add(
                                {
                                  "d_name":d_name,
                                  "dr_name":dr_name,
                                  "dr_code":dr_code,
                                }
                            );


                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.blue
                        ),
                        child: Center(child: Text("Recommend", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12, ),),),
                      ),
                    ),
                  ),


                  SizedBox(height: 20,),
                  Container(
                    width: 350,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.blue,
                    ),

                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5,),
                          Text("Recommendations :", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, ),),
                          SizedBox(height: 6,),
                          Text(d_name),
                          Text(dr_name),
                          Text(dr_code),
                          Text(severity),
                          Text(symptoms),
                        ],
                      ),
                    ),
                  ),

                  TextButton(onPressed: () async{
                    var url = "https://www.youtube.com";

                    if (await canLaunch(url)){
                      await launch(
                        url,
                        forceSafariVC: true,
                        forceWebView: true,
                        enableJavaScript: true,
                      );

                    }
                  }, child: Text("Check out website !")),


                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
