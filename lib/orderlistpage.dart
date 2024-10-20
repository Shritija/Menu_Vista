import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_vista/menueditpage.dart';
import 'package:intl/intl.dart'; 
import 'restaurantProfilePage.dart';
import 'orderdetails.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AboutUsPage.dart';


class OrderListPage extends StatefulWidget {
  final String restaurantId; // Add restaurantId as a parameter

  OrderListPage({required this.restaurantId}); // Update the constructor

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@override
void initState() {
  super.initState();
  _initializeNotifications();
  _listenForNewOrders();
}

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _listenForNewOrders() {
    FirebaseFirestore.instance
        .collection('orders')
        .where('orderstatus', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _showNotification(snapshot.docs.length);
      }
    });
  }

  Future<void> _showNotification(int orderCount) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'order_channel', // channel ID
      'New Orders', // channel name
      channelDescription: 'Notification channel for new orders',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('order_sound'), // Add your sound file in android/app/src/main/res/raw/order_sound.mp3
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Order', // Notification title
      '$orderCount new orders received', // Notification body
      platformChannelSpecifics,
      payload: 'order',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFCFA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF1B3C3D),
          leading: PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.white),
            color: Color(0xFFEAFCFA),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about_us',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'About Us',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (String value) async {
              String email = FirebaseAuth.instance.currentUser?.email ?? '';

              if (value == 'profile') {
                if (email.isNotEmpty) {
                  QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('restaurant')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => restaurantProfilePage(documentId: widget.restaurantId)//documentId: documentId),
                      ),
                    );
                  } else {
                    print('User document not found.');
                  }
                } else {
                  print('No user is currently logged in.');
                }
              } else if (value == 'order_history') {
                if (email.isNotEmpty) {
                  QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('restaurant')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => OrderHistoryPage(),//documentId: documentId),
                    //   ),
                    // );
                  } else {
                    print('User document not found.');
                  }
                }
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              } else if (value == 'about_us') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsPage(),
                  ),
                );
              }
            },
          ),
        title: Center(
          child: Image.asset(
            'assets/images/MenuVistaicon.png',
            height: 50,
            width: 200,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/topmenuicon.png',
              height: 50,
              width: 50,
            ),
            onPressed: () {
              // Currently does nothing, it's a blank space
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('orderstatus', isEqualTo: 'Pending') // Fetch only pending orders
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // Show a message if there are no pending orders
            return Center(child: Text("No orders yet.", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)));
          }
          _listenForNewOrders;
          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((order) {
              return Card(
                color: Color(0xFFcfd8dc),
                child: ListTile(
                  title: Text("Order id: ${order['orderId']}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0)
                    )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Id: ${order['customerId']}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0))),
                      Text("Order Type: ${order['orderType']}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0))),
                      Text("Time: ${DateFormat('hh:mm a, dd MMM yyyy').format(order['timestamp'].toDate())}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0))),
                    SizedBox(height: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Color(0xFF1B3C3D), // Dark green color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(80, 30), 
                            // Set width and height (width, height)
                       ),
                       onPressed: () {
                        // Use the document ID directly
                        String orderId = order.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => orderDetailsPage(orderId, widget.restaurantId),
                          ),
                        );
                      },
                      child: Text("View Order", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: Container (
        color: Color(0xFF1B3C3D),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                      color: Colors.black12, // Border color
                      width: 1,          // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(5, 5),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                padding: EdgeInsets.all(1.0),
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/home_white.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderListPage(restaurantId: widget.restaurantId),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Menu Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                      color: Colors.black12, // Border color
                      width: 1,          // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(5, 5),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                padding: EdgeInsets.all(1.0),
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/edit.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuEditPage(Rid: widget.restaurantId),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}