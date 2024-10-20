import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'AboutUsPage.dart';
import 'LoginPage.dart';
import 'OrderHistoryPage.dart';
import 'ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MenuPage.dart';

class PaymentPage extends StatefulWidget {
  final String? userId;
  final String restaurantId;
  final double totalAmount; // Total amount passed from CartPage

  const PaymentPage({
    Key? key,
    required this.userId,
    required this.restaurantId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  double gst = 0.0;
  double finalAmount = 0.0;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String diningOption = 'Dine In'; // Default option for dining type

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Register the Razorpay event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Calculate GST and final amount
    gst = widget.totalAmount * 0.18; // Assuming 18% GST
    finalAmount = widget.totalAmount + gst;

    // Fetch the user's cart items
    _fetchCartItems();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all event handlers
    super.dispose();
  }

  Future<void> _fetchCartItems() async {
    try {
      // Fetch the cart document using the userId
      DocumentSnapshot userCart = await FirebaseFirestore.instance
          .collection('cart')
          .doc(widget.userId)
          .get();

      if (userCart.exists) {
        // Get the restaurant's subcollection based on restaurantId
        QuerySnapshot restaurantCart = await FirebaseFirestore.instance
            .collection('cart')
            .doc(widget.userId)
            .collection(widget.restaurantId)
            .get();

        // Extract each item from the restaurant's subcollection and add it to cartItems list
        setState(() {
          cartItems = restaurantCart.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showMessage('Error', 'No cart found for this user.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage('Error', 'Failed to load cart items.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFCFA),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1B3C3D),
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: const Color(0xFFEAFCFA),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Profile', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'order_history',
                  child: Row(
                    children: const [
                      Icon(Icons.history, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Order History', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about_us',
                  child: Row(
                    children: const [
                      Icon(Icons.info, color: Colors.black),
                      SizedBox(width: 8),
                      Text('About Us', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.black)),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var cartItem = cartItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3C3D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem['itemName'] ?? 'Unknown Item',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Quantity: ${cartItem['quantity'] ?? 0}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          'Rs ${cartItem['price']?.toString() ?? '0.00'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _paymentSummary(),
            _paymentMethods(),
          ],
        ),
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
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDiningOption(context),
        child: const Icon(Icons.restaurant_menu),
      ),
    );
  }

  Widget _paymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryRow('Item Total', 'Rs ${widget.totalAmount.toStringAsFixed(2)}'),
        _summaryRow('GST (18%)', 'Rs ${gst.toStringAsFixed(2)}'),
        const Divider(color: Colors.black),
        _summaryRow('Total to Pay', 'Rs ${finalAmount.toStringAsFixed(2)}', isBold: true),
        _summaryRow('Dining Option', diningOption), // Display selected dining option
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Pay with Razorpay'),
          onTap: _openRazorpayCheckout,
        ),
      ],
    );
  }

  void _openRazorpayCheckout() {
    var options = {
      'key': 'rzp_test_ZeSLXbwx3muqHX', // Replace with your Razorpay key
      'amount': (finalAmount * 100).toInt(), // Amount in paise
      'name': 'Foodico Restaurant',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '1234567890', // Replace with actual contact
        'email': 'test@example.com', // Replace with actual email
      },
      'external': {
        'wallets': ['paytm'],
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String orderId = FirebaseFirestore.instance.collection('orders').doc().id; // Generate order ID

    // Create the order in Firestore
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'customerId': widget.userId,
      'items': cartItems, // Use the fetched cartItems
      'totalAmount': widget.totalAmount,
      'gst': gst,
      'finalAmount': finalAmount,
      'paymentStatus': 'Successful',
      'orderstatus': 'Pending',
      'paymentId': response.paymentId,
      'orderType': diningOption, // Store the dining option
      'timestamp': Timestamp.now(),
    });

    // Delete the cart subcollection
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(widget.userId)
        .collection(widget.restaurantId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    // Redirect to the RestaurantListPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => OrderHistoryPage(documentId: widget.restaurantId)),
            (Route<dynamic> route) => false,
      );
    _showMessage('Payment Successful', 'Payment ID: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showMessage('Payment Failed', 'Error: ${response.message}');
    // Redirect back to the PaymentPage in case of failure
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(
        userId: widget.userId,
        restaurantId: widget.restaurantId,
        totalAmount: widget.totalAmount,
      )),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage('Wallet Selected', 'Wallet: ${response.walletName}');
  }

  void _showMessage(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3C3D), // Set the background color
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white, // Title text color set to white
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: Colors.white, // Content text color set to white
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFFFDE59), // Set the OK button color
                fontWeight: FontWeight.bold, // Optional: Make the text bold
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _selectDiningOption(BuildContext context) async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B3C3D),
          title: const Text(
            'Select Dining Option',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), // White border
                  borderRadius: BorderRadius.circular(10), // Rounded corners (optional)
                ),
                child: ListTile(
                  title: const Text(
                    'Dine In',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, 'Dine In'),
                ),
              ),
              const SizedBox(height: 10), // Add spacing between the options
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), // White border
                  borderRadius: BorderRadius.circular(10), // Rounded corners (optional)
                ),
                child: ListTile(
                  title: const Text(
                    'Take Away',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, 'Take Away'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedOption != null) {
      setState(() {
        diningOption = selectedOption;
      });
    }
  }
}