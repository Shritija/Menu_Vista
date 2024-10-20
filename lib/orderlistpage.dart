import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_vista/menueditpage.dart';
import 'package:intl/intl.dart'; 
import 'restaurantProfilePage.dart';
import 'orderdetails.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderListPage extends StatefulWidget {
  final String restaurantId; // Add restaurantId as a parameter

  OrderListPage({required this.restaurantId}); // Update the constructor

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {

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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AboutUsPage(),
                //   ),
                // );
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
            .where('orderstatus', isEqualTo: 'pending') // Fetch only pending orders
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // Show a message if there are no pending orders
            return Center(child: Text("No orders yet."));
          }

          return ListView(
            children: snapshot.data!.docs.map((order) {
              return Card(
                child: ListTile(
                  title: Text("Order id: ${order['orderId']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Id: ${order['customerId']}"),
                      Text("Order Type: ${order['orderType']}"),
                      Text("Time: ${DateFormat('hh:mm a, dd MMM yyyy').format(order['time'].toDate())}"),
                    ],
                  ),
                  trailing: ElevatedButton(
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
                    child: Text("View Order"),
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
            // Profile Button
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(1, 1), // Smaller shadow
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: IconButton(
                  iconSize: 20.0, // Smaller icon size to fit better
                  icon: Image.asset(
                    'assets/images/profileicon.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => restaurantProfilePage(documentId: widget.restaurantId),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Shopping Cart Button
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
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
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
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