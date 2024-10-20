import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String customerId;
  final List<QueryDocumentSnapshot> cartItems;
  final double totalAmount; // Total amount passed from CartPage

  const PaymentPage({
    Key? key,
    required this.orderId,
    required this.customerId,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
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

    // Calculate GST and final amount
    gst = widget.totalAmount * 0.18; // Assuming 18% GST
    finalAmount = widget.totalAmount + gst;
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
        title: const Text('Payment'),
        backgroundColor: Colors.teal[900],
      ),
      body: Padding(
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
            const SizedBox(height: 10),
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
        _summaryRow('Item Total', 'Rs ${widget.totalAmount.toStringAsFixed(2)}'),
        _summaryRow('GST (18%)', 'Rs ${gst.toStringAsFixed(2)}'),
        const Divider(color: Colors.black),
        _summaryRow('Total to Pay', 'Rs ${finalAmount.toStringAsFixed(2)}', isBold: true),
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
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).set({
      'orderId': widget.orderId,
      'customerId': widget.customerId,
      'items': widget.cartItems.map((item) => item.data()).toList(),
      'totalAmount': widget.totalAmount,
      'gst': gst,
      'finalAmount': finalAmount,
      'paymentStatus': 'Success',
      'paymentId': response.paymentId,
      'timestamp': Timestamp.now(),
    });

    _showMessage('Payment Successful', 'Payment ID: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).set({
      'orderId': widget.orderId,
      'customerId': widget.customerId,
      'items': widget.cartItems.map((item) => item.data()).toList(),
      'totalAmount': widget.totalAmount,
      'gst': gst,
      'finalAmount': finalAmount,
      'paymentStatus': 'Failed',
      'paymentId': null,
      'timestamp': Timestamp.now(),
    });

    _showMessage('Payment Failed', 'Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage('Wallet Selected', 'Wallet: ${response.walletName}');
  }

  void _showMessage(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
