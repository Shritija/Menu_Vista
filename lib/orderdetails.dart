import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orderlistpage.dart';
import 'menueditpage.dart';
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
      return Scaffold(
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
              Text("Order ID: ${data['orderId'] ?? 'N/A'}"),
              Text("Customer ID: ${data['customerId'] ?? 'N/A'}"),
              Text("Order Type: ${data['orderType'] ?? 'N/A'}"),
              Text("Time: ${data['orderTime'] ?? 'N/A'}"),
              if (data['orderType'] == 'Dine In') 
                Text("Table No: ${data['tableNo'] ?? 'N/A'}"),
              Text("Order Items:"),
              // Directly print 'items' as a String
              Text(data['items'] ?? 'No items available'),
              Text("Extra Instruction: ${data['extrainstructions'] ?? 'N/A'}"),
              Text("Order Status: ${data['orderstatus'] ?? 'N/A'}"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Cancel action
                      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                        'orderstatus': 'Cancelled',
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: restaurantId)),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Done action
                      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                        'orderstatus': 'Done',
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: restaurantId)),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Done"),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Color(0xFF1B3C3D),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: IconButton(
                  iconSize: 20.0,
                  icon: Image.asset('assets/images/home_white.png'),
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
              Flexible(
                child: IconButton(
                  iconSize: 20.0,
                  icon: Image.asset('assets/images/edit.png'),
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
            ],
          ),
        ),
      );
    },
  );
}
