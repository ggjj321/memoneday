import 'package:flutter/material.dart';
import 'package:memoneday/task.dart';
import 'package:memoneday/DB.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

int taskNum = 0;
var wardList = [];

Future<void> main() async {
  tz.initializeTimeZones();
  var now = DateTime.now();
  print(now);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyStatefulWidget();
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class GetUserName extends StatelessWidget {
  final int documentId;

  GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: this.documentId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          var docs = snapshot.data!.docs;
          print(docs.length);
          return Text("Full Name: ${docs[0]['message']}");
        }

        return Text("loading");
      },
    );
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final myController = TextEditingController();
  int _counter = 0;
  String? _selectedTime;
  late List<String> _selectedlist, _selectTimelist;

  Future<void> _showtime() async {
    final TimeOfDay? result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (result != null) {
      setState(() {
        _selectedTime = result.format(context);
        _selectedlist = _selectedTime!.split(" ");
        _selectTimelist = _selectedlist[0].split(":");
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   _asyncMethod();
    // });
    // Start listening to changes.
    myController.addListener(_printLatestValue);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode, //id
            notification.title, // title
            notification.body, // body
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title as String),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body as String)],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification(messasage, idx) {
    print(messasage);
    print(idx);
    DateTime now = DateTime.now();
    int hour = now.hour, minute = now.minute;
    int selechour = int.parse(_selectTimelist[0]),
        seleminute = int.parse(_selectTimelist[1]);
    if (_selectedlist[1] == 'PM' && selechour != 12) selechour += 12;
    if (_selectedlist[1] == 'AM' && selechour == 12)
      selechour = 0; //24-hour clock

    if (minute > seleminute) {
      seleminute += 60;
      selechour -= 1;
    }

    minute = seleminute - minute;

    if (hour > selechour) // 隔天
      hour = 24 - (hour - selechour);
    else
      hour = selechour - hour;
    print(hour);
    print(minute);

    flutterLocalNotificationsPlugin.zonedSchedule(
        idx,
        "記得喔",
        messasage,
        tz.TZDateTime.now(tz.local).add(Duration(hours: hour, minutes: minute)),
        NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id, channel.name, channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  _asyncMethod() async {
    taskNum = await TaskDB.getCount();
    for (int i = 0; i < taskNum; i++) {
      wardList.add(await TaskDB.getonedata(i));
    }
  }

  void _printLatestValue() {
    print('Second text field: ${myController.text}');
  }

  String? _readMessage(idx) {
    dynamic text = '';
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: idx)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        text = doc["message"];
      });
    });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text('備忘錄'),
      ),
      body: StreamBuilder(
          stream: users.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text('Loading'));
            }
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              children: List.generate(taskNum, (idx) {
                final thiscontroller = new TextEditingController();

                // var thistext =  _readMessage(idx);
                // print('init: $thistext');

                return Card(
                  elevation: 10.0,
                  color: Colors.tealAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Container(
                      alignment: Alignment.topCenter,
                      width: 100,
                      height: 100,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 150,
                            height: 60,
                            child: TextField(
                              controller: thiscontroller,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              textAlign: TextAlign.start,
                              decoration: new InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                suffix: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () async {
                                      users
                                          .doc('message$idx')
                                          .set(
                                            {
                                              'message': thiscontroller.text,
                                              'id': idx,
                                            },
                                            SetOptions(merge: true),
                                          )
                                          .then((value) => print(
                                              "'full_name' & 'age' merged with existing data!"))
                                          .catchError((error) => print(
                                              "Failed to merge data: $error"));
                                      // thistext = _readMessage(idx);
                                      // print(idx);
                                      // print(thistext);
                                      //print(thiscontroller.text);
                                      // FirebaseFirestore.instance
                                      //     .collection('users')
                                      //     .where('id', isEqualTo: idx)
                                      //     .get()
                                      //     .then((QuerySnapshot querySnapshot) {
                                      //   querySnapshot.docs.forEach((doc) {
                                      //     print('**');
                                      //     print(doc["message"]);
                                      //   });
                                      // });
                                      setState(() {});
                                    }),
                              ),
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .where('id', isEqualTo: idx)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Something went wrong");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                var docs = snapshot.data!.docs;
                                return Text("${docs[0]['message']}");
                              }

                              return Text("loading");
                            },
                          ),
                          // Text(
                          //   // '${FirebaseFirestore.instance
                          //   //     .collection('users')
                          //   //     .where('age', isGreaterThan: 20)
                          //   //     .get()
                          //   // }'
                          //   '$thistext',
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 40,
                          //   ),
                          // ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await TaskDB.deleteData(idx);
                                      taskNum -= 1;
                                      wardList.removeAt(idx);
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () {
                                        showNotification(wardList[idx], idx);
                                      }),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: IconButton(
                                    icon: Icon(Icons.lock_clock),
                                    onPressed: _showtime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                );
              }),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            taskNum += 1;
            wardList.add('');
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
