import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_vista/MenuPage.dart';
import 'PaymentPage.dart';
import 'LoginPage.dart';
import 'OrderHistoryPage.dart';
import 'AboutUsPage.dart';
import 'ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CartPage extends StatefulWidget {
  final String? userId; // Accept userId as a nullable parameter
  final String restaurantId; // Accept restaurantId as a nullable parameter
  final String? itemId; // Accept itemId as a nullable parameter
  final String? selectedSize; // Accept selectedSize as a nullable parameter
  final int? price; // Accept price as a nullable parameter
  final String? extraInstructions; // Accept extraInstructions as a nullable parameter

  CartPage({
    required this.userId,
    required this.restaurantId,
    required this.itemId,
    required this.selectedSize,
    required this.price,
    required this.extraInstructions,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late DocumentReference userCartRef; // Reference to user's cart document
  late CollectionReference itemsCollection; // Collection reference for restaurant-specific items

  final CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');

  @override
  void initState() {
    super.initState();
    userCartRef = cartCollection.doc(widget.userId);
    itemsCollection = userCartRef.collection(widget.restaurantId); // Create a collection with restaurantId
    _addItemToCart(); // Call method to add item to cart
  }

  void _addItemToCart() async {
    // Check if the user's cart document exists, if not create it
    if (!(await userCartRef.get()).exists) {
      await userCartRef.set({'restaurantId': widget.restaurantId});
    }
    if (widget.itemId != null) {
      String itemName = await _fetchItemName();
      await itemsCollection.doc(widget.itemId).set({
        'price': widget.price,
        'selectedSize': widget.selectedSize,
        'itemName': await _fetchItemName(),
        'extraInstructions': widget.extraInstructions,
        'quantity': 1, // Initialize quantity to 1
      });
    }
  }

  Future<String> _fetchItemName() async {
    // List of subcollection names to search through
    if (widget.itemId == null) {
      return 'Unknown Item';
    }
    List<String> subcollections = ['snacks', 'breakfast', 'lunch', 'dinner'];

    for (String subcollection in subcollections) {
      var itemSnapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .doc('MealTypes')
          .collection(subcollection) // Dynamically access each subcollection
          .doc(widget.itemId)
          .get();

      if (itemSnapshot.exists) {
        return itemSnapshot.data()?['itemname'] ?? 'Unknown Item';
      }
    }

    // Return 'Unknown Item' if the item is not found in any subcollection
    return 'Unknown Item';
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
                  value: 'order_history',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Order History',
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
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(documentId: documentId),
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
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderHistoryPage(documentId: documentId),
                      ),
                    );
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
              onPressed: () {},
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: itemsCollection.snapshots(), // Listen to the specific restaurantId subcollection
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Empty-cart-1-512.png', // Replace with your image path
                      height: 300, // Adjust height as needed
                      width: 300, // Adjust width as needed
                      fit: BoxFit.cover, // Adjust the box fit as needed
                    ),
                    SizedBox(height: 16), // Add some space between the image and text
                    Text(
                      'Your cart is currently empty',
                      style: TextStyle(fontSize: 20), // Customize text style if needed
                    ),
                  ],
                ),
              );
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

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(cartItem['itemName']), // Display the item name from Firestore
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: Rs ${cartItem['price']}'),
                              SizedBox(height: 4.0),
                              Text('Size: ${cartItem['selectedSize']}'),
                              SizedBox(height: 4.0),
                              Text('Extra Instructions: ${cartItem['extraInstructions']}'),
                            ],
                          ),
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
                  ),
                ),
                _billDetails(cartItems),
                _proceedToPayButton(cartItems),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          color: Color(0xFF1B3C3D),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Back Button with Navigator.push and MaterialPageRoute
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
                  padding: EdgeInsets.all(5.0),
                  child: IconButton(
                    iconSize: 20.0,
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous page
                    },
                  ),
                ),
              ),

              // Shopping Cart Button with Navigator.push and MaterialPageRoute
              Expanded(
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
                  padding: EdgeInsets.all(10.0),
                  child: IconButton(
                    iconSize: 30.0,
                    icon: Image.asset('assets/images/bottommenuicon.png'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuPage(// Pass the documentId as userId
                          Rid: widget.restaurantId,
                        )), // Replace with the correct page
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  void _updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity > 0) {
      itemsCollection.doc(cartItemId).update({'quantity': newQuantity});
    } else {
      itemsCollection.doc(cartItemId).delete();
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
        // Calculate the total amount based on the cart items
        double totalAmount = cartItems.fold(0.0, (sum, item) {
          var data = item.data() as Map<String, dynamic>;
          return sum + (data['price'] * data['quantity']);
        });

        // Navigate to the PaymentPage, passing userId, restaurantId, and totalAmount
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              userId: widget.userId,         // Send the userId
              restaurantId: widget.restaurantId, // Send the restaurantId
              totalAmount: totalAmount,      // Send the totalAmount
            ),
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