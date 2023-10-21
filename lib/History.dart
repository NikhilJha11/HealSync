import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../main.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  var imgLink = "https://i.pinimg.com/564x/df/00/14/df001467ef17f34e505f54a7f60e4440.jpg";
  var searchCtrl = TextEditingController();

  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance.collection("Aarogya");

  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Color(0xffececec),),

          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: InkWell(
                                  onTap: (){

                                  },
                                  child: Icon(CupertinoIcons.search)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: searchCtrl,
                                decoration: InputDecoration(
                                  hintText: "Search Contact...",
                                  border: InputBorder.none,
                                ),
                                onChanged: (value){
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white
                        ),
                        child: Transform.scale(
                            scale: 0.5,
                            child: SvgPicture.asset('assets/icons/filter.svg', color: Colors.black,)
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40,),
                  Row(
                    children: [
                      SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("History", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.black, fontSize: 28, height: 1.2, letterSpacing: 1.2),),
                          SizedBox(height: 20,),
                        ],
                      ),
                    ],
                  ),

                  // SizedBox(height: 20,),

                  StreamBuilder(
                    stream: firestore.doc("Patients").collection("PatientUids").doc(auth.currentUser!.uid).collection("History").snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){


                      if (snapshot.hasError){
                        return Center(child: Text("Something went wrong"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CupertinoActivityIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty){
                        return Center(child: Text("No data found"));
                      }

                      if (snapshot!=null && snapshot.data!=null){
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index){
                            var did = snapshot.data!.docs[index].id;
                            var dname = snapshot.data!.docs[index]['d_name'];
                            var dr_name = snapshot.data!.docs[index]['dr_name'];
                            var dr_code = snapshot.data!.docs[index]['dr_code'];
                            return InkWell(
                              onLongPress: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return CupertinoAlertDialog(
                                      title: Text("Remove Item"),
                                      content: Column(
                                        children: [
                                          SizedBox(height: 10,),
                                          Container(
                                            height: 88,
                                            width: 88,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text("Are you sure you want to remove this item ?"),
                                        ],
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () async{
                                            firestore.doc("Patients").collection("PatientUids").doc(auth.currentUser!.uid).collection("History").doc(did).delete();

                                            Navigator.pop(context);
                                          },
                                          child: Text("Yes"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20,),
                                height: 180,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFFF7BA7).withOpacity(0.6),
                                        spreadRadius: -20,
                                        blurRadius: 25,
                                        offset: Offset(0, 30),
                                      ),
                                    ],
                                    color: Colors.pinkAccent
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 25,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Text(snapshot.data!.docs[index]['iLoc'], style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12, height: 1.2),),
                                                Container(
                                                    width: 290,
                                                    child: Text(dname, style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24, height: 1.2),)),
                                                SizedBox(height: 26,),
                                                Text(dr_name, style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, height: 1),),
                                                Text(dr_code, style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12, height: 1.2),),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      // print(snapshot.data!.docs[0]['b']);
                      return Container();
                    },
                  ),




                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
