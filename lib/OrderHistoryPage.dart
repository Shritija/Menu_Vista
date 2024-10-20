import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OrderHistoryPage extends StatelessWidget {
  final String? documentId;

  OrderHistoryPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3C3D),
        title: Center(
          child: Image.asset(
            'assets/images/MenuVistaicon.png',
            height: 50,
            width: 200,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFEAFCFA),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('customerId', isEqualTo: documentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];

                // Extracting order details
                var orderId = order['orderId'] ?? 'Unknown';
                var orderType = order['orderType'] ?? 'Unknown';
                var orderStatus = order['orderstatus'] ?? 'Unknown';
                var finalAmount = order['finalAmount'] ?? 0;
                var gst = order['gst'] ?? 0;
                var totalAmount = order['totalAmount'] ?? 0;
                var paymentStatus = order['paymentStatus'] ?? 'Unknown';
                var paymentId = order['paymentId'] ?? 'Unknown';
                var timestamp = order['timestamp'] != null
                    ? DateFormat('dd MMMM yyyy, hh:mm a').format(order['timestamp'].toDate())
                    : 'Unknown';

                // Handling items array
                var items = order['items'] ?? [];
                List<Widget> itemWidgets = [];

                for (var item in items) {
                  var itemName = item['itemName'] ?? 'Unknown Item';
                  var quantity = item['quantity'] ?? 0;
                  var price = item['price'] ?? 0;
                  var selectedSize = item['selectedSize'] ?? 'Unknown Size';
                  var itemInstructions = item['extraInstructions'] ?? 'None';

                  itemWidgets.add(
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '$itemName ($selectedSize) - Quantity: $quantity, Price: Rs $price\nInstructions: $itemInstructions',
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                Color statusColor;
                if (orderStatus.toLowerCase() == 'done') {
                  statusColor = Colors.lightGreenAccent;
                } else if (orderStatus.toLowerCase() == 'pending') {
                  statusColor = Colors.redAccent;
                } else {
                  statusColor = Colors.grey; // Default for other statuses
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xFF1B3C3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        'Order Number: $orderId',
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          ...itemWidgets, // Display all the items
                          const SizedBox(height: 8),
                          Text(
                            'Order Type: $orderType',
                            style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Order Date: $timestamp',
                            style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Amount: Rs $totalAmount (Including GST: Rs $gst)',
                            style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Final Amount: Rs $finalAmount',
                            style: const TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Order Status: $orderStatus',
                              style: const TextStyle(
                                fontFamily: 'Oswald',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1B3C3D),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}