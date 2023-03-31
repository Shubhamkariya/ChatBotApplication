import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';



class RealtimeData extends StatefulWidget {


  const RealtimeData({Key? key}) : super(key: key);

  @override
  State<RealtimeData> createState() => _RealtimeDataState();
}

class _RealtimeDataState extends State<RealtimeData> {



  @override
  Widget build(BuildContext context) {

    DatabaseReference tempvaleur =
    FirebaseDatabase.instance.ref('/Messages/NEsoRiDO2xNSswVMLsiCHgmyPz93/receiver-id');

    return Scaffold(
      appBar: AppBar(
        title: Text("ChatBot",
            style: TextStyle(
                color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // DateChip(
                //   date: new DateTime(now.year, now.month, now.day - 2),
                // ),
                listView(),

                //
                // StreamBuilder(
                //     stream: tempvaleur.onValue,
                //     builder: (context, snapshot) {
                //       if (snapshot.hasData) {
                //         var data = (snapshot.data! as DatabaseEvent).snapshot.value;
                //
                //         return BubbleSpecialOne(
                //           text: data.toString(),
                //           tail: false,
                //           sent: false,
                //           isSender: false,
                //             color: Color(0xFF1B97F3),
                //             textStyle: TextStyle(
                //               fontSize: 20,
                //               color: Colors.black,
                //             ),
                //         );
                //       }
                //       return CircularProgressIndicator();
                //     }
                // ),

                // BubbleSpecialOne(
                //   text: 'bubble special one without tail',
                //   isSender: false,
                //   tail: false,
                //   color: Color(0xFF1B97F3),
                //   textStyle: TextStyle(
                //     fontSize: 20,
                //     color: Colors.black,
                //   ),
                // ),
                // BubbleSpecialOne(
                //   text: 'bubble special one without tail',
                //   tail: false,
                //   color: Color(0xFFE8E8EE),
                //   sent: true,
                // ),

                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          MessageBar(
            onSend: (_) => createData((_)),

            actions: [
              InkWell(
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24,
                ),
                onTap: () {},
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                    size: 24,
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  listView()  {
    DatabaseReference tempvaleur1 =
    FirebaseDatabase.instance.ref('/Messages/NEsoRiDO2xNSswVMLsiCHgmyPz93/');
    tempvaleur1.onValue.listen((event) {
      for (final child in event.snapshot.children) {
        // Handle the post.
        print(child.child("message").value);

      }
    });

  }

  void createData(String Message) async {
    var uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("UID");
    DatabaseReference ref = FirebaseDatabase.instance.ref("Messages")
        .child(uid)
        .push();
    ref.set({
      "name": uid,
      "message": Message,
      "isSender": uid,
      "sent": true
    });
    // }
  }

  readData() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }
  }
}
