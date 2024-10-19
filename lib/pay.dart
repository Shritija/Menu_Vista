import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For managing timer for error message removal
import 'package:upi_pay/upi_pay.dart'; // Import this for date formatting


class PaymentPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;

  PaymentPage({required this.cartItems});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedUpiApp;
  String? selectedPaymentMethod;

  // Total amount and final amount including GST calculation
  late double totalAmount;
  late double finalAmount;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
    double gst = totalAmount * 0.18;
    finalAmount = totalAmount + gst;
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Options Header
              Text(
                'Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${widget.cartItems.length} Items  :  Total Rs ${finalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Pay by an UPI App
              Container(
                color: Colors.yellow[100],
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay by an UPI App',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/google_pay.png', // Add your Google Pay icon asset here
                              height: 40,
                              width: 40,
                            ),
                            SizedBox(width: 10),
                            Text('Google Pay', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Radio<String>(
                          value: 'google_pay',
                          groupValue: selectedUpiApp,
                          onChanged: (String? value) {
                            setState(() {
                              selectedUpiApp = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {
                        // Handle Add New UPI ID
                      },
                      icon: Icon(Icons.add, color: Colors.red),
                      label: Text(
                        'Add New UPI ID',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // More Payment Options
              Text(
                'More Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _paymentOptionTile(
                context,
                icon: Icons.account_balance_wallet,
                color: Colors.purple,
                title: 'Wallets',
              ),
              _paymentOptionTile(
                context,
                icon: Icons.credit_card,
                color: Colors.orange,
                title: 'Netbanking',
              ),
              _paymentOptionTile(
                context,
                icon: Icons.money,
                color: Colors.green,
                title: 'Cash',
              ),
              _paymentOptionTile(
                context,
                icon: Icons.payment,
                color: Colors.yellow,
                title: 'Debit or Credit Card',
              ),
              SizedBox(height: 30),

              // Proceed Button
              ElevatedButton(
                onPressed: selectedUpiApp == 'google_pay'
                    ? () => _makePayment(finalAmount)
                    : null, // Disable button if no UPI app is selected
                child: Text('Proceed to Pay Rs ${finalAmount.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionTile(BuildContext context, {required IconData icon, required Color color, required String title}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 36),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Radio<String>(
        value: title,
        groupValue: selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value;
          });
        },
      ),
    );
  }

  Future<void> _makePayment(double amount) async {
    try {
      final transactionRef = await UpiPay.initiateTransaction(
        amount: amount.toStringAsFixed(2),
        app: UpiApplication.googlePay,
        receiverUpiAddress: 'merchant@upi', // Replace with actual UPI ID
        receiverName: 'Merchant Name',
        transactionRef: 'T1234',
        transactionNote: 'Payment for items',
      );
      print('Payment initiated: $transactionRef');
    } catch (e) {
      print('Payment failed: $e');
    }
  }
}