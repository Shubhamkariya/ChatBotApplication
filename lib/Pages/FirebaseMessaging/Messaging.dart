import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/Constants.dart';
import 'package:untitled1/main.dart';

class Messaging extends StatefulWidget {

  const Messaging({Key? key, required this.userId, required this.name}) : super(key: key);
  final String userId;
  final String name;

  @override
  State<Messaging> createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  late File imageFile;
  String imageUrl = '';
  bool isLoading =true ;

  Widget listItem({required Map student}) {
    if(student['isSender'] == true) {
      if(student['datatype']=='image'){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height:5,
            ),
            BubbleNormalImage(
              id: 'id001',
              image: Image.network(student['message']),
              tail: true,
              isSender: true,
              delivered: true,
            ),
            SizedBox(
              height:20,
            ),

          ],

        );
      }
      else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),

            BubbleSpecialOne(
              text: student['message'],
              isSender: true,
              tail: true,
              sent: student['isSent'],
              seen: student['isSeen'],
              delivered: student['isDelivered'],
              color: kPrimaryColor,
              textStyle: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),

          ],

        );
      }
    }
    else
    {
      if(student['datatype']=='image'){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height:5,
            ),
            BubbleNormalImage(
              id: 'id001',
              image: Image.network(student['message']),
              tail: true,
              isSender: false,
              delivered: true,
            ),
            SizedBox(
              height:20,
            ),

          ],

        );
      }
      else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height:5,
            ),
            BubbleSpecialOne(
              text: student['message'],
              tail: true,
              isSender: false,
              color: PrimaryColor,
              textStyle: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    String userId = widget.userId;
    String name = widget.name;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    Query dbRef = FirebaseDatabase.instance.ref().child('Messages').child(uid.toString()).child(userId);
    DatabaseReference reference = FirebaseDatabase.instance.ref().child('Messages').child(uid.toString()).child(userId);

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin?.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                icon: android?.smallIcon,
                // other properties...
              ),
            ));
      }
    });
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title:  Row(
            children: <Widget>[
              Image.asset('assets/images/firebase_logo.png',height: 40,width: 30,),
              Padding(
                padding: EdgeInsets.all(24.0),
                child:Text(name),
              )
            ],
          ),

        ),
        body:isLoading ?Stack(
            children: [
              SingleChildScrollView(
                  child:Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height -100,
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
              MessageBar(
                onSend: (_) => createData((_),userId,name,"text"),
      messageBarColor: kPrimaryLightColor,
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
                     onTap:() => uploadPic(userId,name),
                    ),
                  ),
                ],
              ),
            ]
        ): Center(child:CircularProgressIndicator())
    );

  }
  void createData(String Message, String UserId, String Receiver,String type) async {
    late FirebaseMessaging messaging;
    var uid;
    var Receiver_token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("UID");
    messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    print("FCM token +\n"+fcmToken.toString());
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('User').child(UserId).child("token");
    databaseReference.once().then((DatabaseEvent snapshot) {
      Receiver_token = snapshot.snapshot.value;
      sendPushMessage(Message,"New Message",Receiver_token);
    });


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    late DatabaseReference dbRef;
    dbRef = FirebaseDatabase.instance.ref().child('Messages').child(uid).child(UserId);
    Map<String, dynamic> students = {
      'name': Receiver,
      'message': Message,
      'isSent':true,
      'isSender':true,
      'isDelivered':true,
      'isSeen':false,
      'userId':uid,
      'datatype':type
    };

    dbRef.push().set(students);

    late DatabaseReference dbRef1;
    dbRef1 = FirebaseDatabase.instance.ref().child('Messages').child(UserId).child(uid);
    Map<String, dynamic> students1 = {
      'name': uid,
      'message': Message,
      'isSent':true,
      'isSender':false,
      'isDelivered':true,
      'isSeen':false,
      'userId':UserId,
      'datatype':type
    };

    dbRef1.push().set(students1);

    // }
  }

  void sendPushMessage(String body, String title, final token) async {
    print(token);
    var serverKey =
        "AAAAXle6h78:APA91bGlT4LrDoDKud9cz3YR6LbaYkD2VLVNRnQsKxJoHI2ItRClczywfZAF9ccj2a2AAMrcPKlAXqGq-SCXNkk2x9GskZgbz8Zn_JeQBzMZZhc3rByBMHYsVXkD6nWdLho_cO9osDcU";
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');

    } catch (e) {
      print("error push notification");
    }
  }
  void uploadPic(String UserId, String Receiver) async {


    ImagePicker imagePicker = ImagePicker();
    XFile? file =
    await imagePicker.pickImage(source: ImageSource.gallery);
    print('${file?.path}');

    if (file == null) return;
    //Import dart:core
    String uniqueFileName =
    DateTime.now().millisecondsSinceEpoch.toString();


    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages =
    referenceRoot.child('images');

    //Create a reference for the image to be stored
    Reference referenceImageToUpload =
    referenceDirImages.child("Random");

    //Handle errors/success
    try {
      //Store the file
      await referenceImageToUpload.putFile(File(file!.path));
      //Success: get the download URL

      imageUrl = await referenceImageToUpload.getDownloadURL();

      print(imageUrl);
      createData(imageUrl, UserId, Receiver, "image");
    } catch (error) {
      //Some error occurred
    }
  }




 }