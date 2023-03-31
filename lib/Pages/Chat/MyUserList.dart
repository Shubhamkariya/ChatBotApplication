import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/Constants.dart';
import 'package:untitled1/Pages/Account/update.dart';
import 'package:untitled1/Pages/FirebaseMessaging/Messaging.dart';
import 'package:untitled1/Utils/CheckAuth.dart';
import 'package:untitled1/main.dart';

class MyUserList extends StatefulWidget {
  const MyUserList({Key? key}) : super(key: key);


  @override
  State<MyUserList> createState() => _MyUserListState();
}

class _MyUserListState extends State<MyUserList> {
  late DatabaseReference dbReference;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenUpdate();
  }

  @override
  Query dbRef = FirebaseDatabase.instance.ref().child('User');
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('User');

   listItem({required Map student}) {
     final FirebaseAuth auth = FirebaseAuth.instance;
     final User? user = auth.currentUser;
     final uid = user?.uid;
     if (student.isNotEmpty) {
       if (student['userId'] != uid) {
         return Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Card(
               color: kPrimaryColor,
               child: ListTile(
                 title: Text(student['name'],style: TextStyle(color: Colors.white,fontSize: 20)),
                 leading: Icon(Icons.ac_unit_outlined, color: Colors.white),
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) =>
                           Messaging(userId: student['userId'],
                               name: student['name']),
                     ),
                   );
                   print(student['userId']);
                 },
               ),
             ),
           ],
         );
       }
       else {
         return SizedBox(
           height: 0.0,
         );
       }
     }
     else {
       return CircularProgressIndicator();
     }
   }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit an App?'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('No'),
            ),

            ElevatedButton(
              onPressed: () => exit(0),
              //return true when click on "Yes"
              child:Text('Yes'),
            ),

          ],
        ),
      )??false; //if showDialouge had returned null, then return false
    }
    return WillPopScope(
         onWillPop:showExitPopup,
    child:Scaffold(
      backgroundColor: kPrimaryLightColor,
        appBar: AppBar(
          backgroundColor: PrimaryColor,
          title: const Text('User data list'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            PopupMenuButton(
              // add icon, by default "3 dot" icon
              // icon: Icon(Icons.book)
                itemBuilder: (context){
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.account_circle,color: Colors.black),
                          Text('Account'),
                        ],
                      ),
                    ),

                    PopupMenuItem<int>(
                      value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.settings,color: Colors.black),
                            Text('Setting'),
                          ],
                        )
                    ),

                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.logout,color: Colors.black),
                          Text('Logout'),
                        ],
                      )

                    ),
                  ];
                },
                onSelected:(value) async {
                  if(value == 0){
                    print("My account menu is selected.");
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User? user = auth.currentUser;
                    final uid = user?.uid;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => UpdateAccountRecord())
                    );
                  }else if(value == 1){
                    print("Settings menu is selected.");
                  }else if(value == 2){
                    await FirebaseAuth.instance.signOut();

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => CheckAuth())
                              );
                        }
                  }
            ),
          ],

        ),
        body:Stack(
          children: [
        SingleChildScrollView(
        child:Column(

        children: <Widget>[
          Container(
          height: MediaQuery.of(context).size.height,
          child: FirebaseAnimatedList(
            query: dbRef,
            itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
              Map student = snapshot.value as Map;
              student['key'] = snapshot.key;
              return listItem(student: student);

            },
          ),

        ),]
    )),
      ]
    )
    )
    );

  }
  void createData(String Message) async {
    var uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("UID");

    late DatabaseReference dbRef;
    dbRef = FirebaseDatabase.instance.ref().child('Messages').child("NEsoRiDO2xNSswVMLsiCHgmyPz93");
    Map<String, dynamic> students = {
      'name': uid,
      'message': Message,
      'isSent':true,
      'userId':"NEsoRiDO2xNSswVMLsiCHgmyPz93"
    };

    dbRef.push().set(students);

    // }
  }

  Future<void> tokenUpdate() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    print(fcmToken);
    final FirebaseAuth auth1 = FirebaseAuth.instance;
    final User? user = auth1.currentUser;
    final uid = user?.uid;
    DatabaseReference dbReference = FirebaseDatabase.instance.ref()
        .child('User')
        .child(uid.toString());
    dbReference.update({
      "token": fcmToken
    });
  }

}