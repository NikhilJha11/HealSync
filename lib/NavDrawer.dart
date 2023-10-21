import 'dart:math';
import 'package:aarogya/AarogyaGPT.dart';
import 'package:aarogya/Ambulance.dart';
import 'package:aarogya/History.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'Login.dart';
import 'main.dart';
class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  var imgLink = "https://i.pinimg.com/564x/98/98/19/9898199841701e52cb871ed12b22204a.jpg";
  var currIndex = 0;
  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance.collection("Aarogya");

  var PatientName = "Shrutis";

  var selectedItemIndex = 0;

  List<Widget> pagesList = [
    Home(),
    Ambulance(),
    AarogyaGPT(),
    History(),

  ];

  List<IconData> iconsList = [
    CupertinoIcons.home,
    CupertinoIcons.helm,
    CupertinoIcons.heart_fill,
    CupertinoIcons.at_badge_minus,
  ];

  void fetchPatient() async{
    var query2 = await firestore.doc("Patients").collection("PatientUids").where("pid", isEqualTo: auth.currentUser!.uid).get();
    query2.docs.forEach((doc) async {
      setState(() {
        PatientName = doc.data()["name"];
      });

    });



  }

  @override
  void initState() {
    super.initState();
    fetchPatient();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffececec),
        title: Text('Hey $PatientName!', style: TextStyle(color: Colors.black),),
        leading: Icon(CupertinoIcons.profile_circled, color: Colors.black,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),  // Add your logout icon here
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Login()));
            },
          ),
        ],
      ),
      body: pagesList[currIndex],
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(25),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.symmetric(horizontal: 50),
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff327ffa),
                Color(0xff5a9aff),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(.1),
                blurRadius: 30,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            itemCount: iconsList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() {
                  currIndex = index;
                },
                );
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 1500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    margin: EdgeInsets.only(
                      bottom: index == currIndex ? 0 : 11,
                      right: 8,
                      left: 8,
                    ),
                    width: 35,
                    height: index == currIndex ? 5 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(50),
                      ),
                    ),
                  ),
                  Icon(
                    iconsList[index],
                    size: 30,
                    color: index == currIndex
                        ? Colors.white
                        : Color(0xFFECECEC),
                  ),
                  SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

