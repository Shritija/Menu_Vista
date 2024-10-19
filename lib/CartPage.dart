import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PaymentPage.dart';

// CartPage class updated to be StatefulWidget
class CartPage extends StatefulWidget {
  final String itemId;  // Accept itemId as a parameter
  final String restaurantId; // Also accept restaurantId as a parameter

  CartPage({required this.itemId, required this.restaurantId});  // Constructor to initialize itemId and restaurantId

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[900],
        title: Text('Foodico', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {}, // Handle settings action
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {}, // Handle restaurant menu action
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is currently empty'));
          }

          final cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index].data() as Map<String, dynamic>;
                    var cartItemId = cartItems[index].id;

                    // Fetch the actual item name using the passed widget.itemId
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('restaurant')
                          .doc(widget.restaurantId)
                          .collection('menuItems')
                          .doc('MealTypes') // Assuming MealTypes is a single doc, adjust if needed
                          .collection('snacks')
                          .doc(widget.itemId)
                          .get(),
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (itemSnapshot.hasError || !itemSnapshot.hasData || !itemSnapshot.data!.exists) {
                          return Center(child: Text('Error loading item data'));
                        }

                        // Extract item data
                        var itemData = itemSnapshot.data!.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(itemData['itemname']), // Display the item name from Firestore
                            subtitle: Text('Price: Rs ${cartItem['price']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    _updateQuantity(cartItemId, cartItem['quantity'] - 1);
                                  },
                                ),
                                Text('${cartItem['quantity']}'),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _updateQuantity(cartItemId, cartItem['quantity'] + 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _billDetails(cartItems),
              _proceedToPayButton(cartItems),
            ],
          );
        },
      ),
    );
  }

  void _updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity > 0) {
      cartCollection.doc(cartItemId).update({'quantity': newQuantity});
    } else {
      cartCollection.doc(cartItemId).delete();
    }
  }

  Widget _billDetails(List<QueryDocumentSnapshot> cartItems) {
    double totalAmount = cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });

    double gst = totalAmount * 0.18;
    double finalAmount = totalAmount + gst;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _billDetailRow('Item total', 'Rs ${totalAmount.toStringAsFixed(2)}'),
          _billDetailRow('GST (18%)', 'Rs ${gst.toStringAsFixed(2)}'),
          Divider(color: Colors.black),
          _billDetailRow('Total to Pay', 'Rs ${finalAmount.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _billDetailRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _proceedToPayButton(List<QueryDocumentSnapshot> cartItems) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[600],
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(cartItems: cartItems),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Proceed To Pay', style: TextStyle(color: Colors.black, fontSize: 18)),
        ],
      ),
    );
  }
}