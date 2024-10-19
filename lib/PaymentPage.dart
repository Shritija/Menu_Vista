import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;

  PaymentPage({required this.cartItems});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  double totalAmount = 0.0;
  double gst = 0.0;
  double finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Register the Razorpay event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Calculate the total amount, GST, and final amount
    totalAmount = widget.cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
    gst = totalAmount * 0.18;
    finalAmount = totalAmount + gst;
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all event handlers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.teal[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  var cartItem = widget.cartItems[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(cartItem['itemname']),
                    subtitle: Text('Quantity: ${cartItem['quantity']}'),
                    trailing: Text('Rs ${cartItem['price']}'),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            _paymentSummary(),
            _paymentMethods(),
          ],
        ),
      ),
    );
  }

  Widget _paymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryRow('Item total', 'Rs ${totalAmount.toStringAsFixed(2)}'),
        _summaryRow('GST (18%)', 'Rs ${gst.toStringAsFixed(2)}'),
        Divider(color: Colors.black),
        _summaryRow('Total to Pay', 'Rs ${finalAmount.toStringAsFixed(2)}', isBold: true),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false}) {
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

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Pay with Razorpay'),
          onTap: () {
            _openRazorpayCheckout();
          },
        ),
      ],
    );
  }

  void _openRazorpayCheckout() {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY',  // Replace with your Razorpay Key
      'amount': (finalAmount * 100).toInt(), // Razorpay amount is in paise
      'name': 'Foodico Restaurant',
      'description': 'Payment for your food order',
      'prefill': {
        'contact': '1234567890', // Replace with actual contact
        'email': 'test@example.com',  // Replace with actual email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('Payment ID: ${response.paymentId}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Error: ${response.code}\nMessage: ${response.message}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('External Wallet Selected'),
        content: Text('Wallet: ${response.walletName}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}