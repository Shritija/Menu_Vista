import 'package:flutter/material.dart';    
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orderlistpage.dart';
import 'menueditpage.dart';
import 'package:intl/intl.dart'; 
import 'restaurantProfilePage.dart';

Widget orderDetailsPage(String orderId, String restaurantId) {
  
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }
      var data = snapshot.data?.data() as Map<String, dynamic>;
      // Get the screen width
      double screenWidth = MediaQuery.of(context).size.width;
      
      return Scaffold(
        backgroundColor: Color(0xFFEAFCFA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF1B3C3D),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
              onPressed: () {},
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth, // Changed to responsive width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFcfd8dc),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Details:",
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Order ID: ${data['orderId'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                    Text("Customer ID: ${data['customerId'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                    Text("Order Type: ${data['orderType'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                     Text("Time: ${DateFormat('hh:mm a, dd MMM yyyy').format(data['timestamp'].toDate()) ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                    if (data['orderType'] == 'Dine In') 
                      Text("Table No: ${data['tableNo'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth , // Changed to responsive width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFcfd8dc),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Items:",
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Check if the items array is not empty or null
                    if (data['items'] != null && data['items'].isNotEmpty)
                      ...List<Widget>.from(data['items'].map<Widget>((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical spacing between items
                          child: Text(
                            "${item['itemName']} (Qty: ${item['quantity']}, Size: ${item['selectedSize']}, Price: ${item['price'].toStringAsFixed(2)} Rs)\nExtra Instructions: ${item['extraInstructions'] ?? 'None'}",
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        );
                      })).toList()
                    else
                      Text(
                        'No items available',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth, // Changed to responsive width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFcfd8dc),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Status: ", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
                    Text("${data['orderstatus'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: screenWidth, // Changed to responsive width
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFcfd8dc),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Status: ", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
                    Text("${data['paymentStatus'] ?? 'N/A'}", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 14,
                    color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                          'orderstatus': 'Cancelled',
                        });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: restaurantId)),
                        );
                      },
                      style: ElevatedButton.styleFrom(elevation: 3,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.black),
                              ),
                              minimumSize: Size(100, 40), ),
                      child: Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Oswald', shadows: [
                            Shadow(
                              color: Colors.grey.withOpacity(0.5), // Shadow color
                              offset: Offset(2, 2), // Offset of the shadow
                              blurRadius: 4, // Blur radius of the shadow
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                        'orderstatus': 'Done',
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: restaurantId)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: Colors.green,
                       shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.black),
                            ),
                            minimumSize: Size(100, 40), 
                    ),
                    child: Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Oswald', shadows: [
                          Shadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            offset: Offset(2, 2), // Offset of the shadow
                            blurRadius: 4, // Blur radius of the shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                 ),
                ],
              ),
            ],
          ),
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
                          builder: (context) => OrderListPage(restaurantId: restaurantId),
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
                          builder: (context) => MenuEditPage(Rid: restaurantId),
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
    },
  );
}