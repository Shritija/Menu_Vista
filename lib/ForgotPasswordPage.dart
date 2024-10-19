import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String message = '';

  Future<void> sendPasswordResetEmail() async {
    String email = emailController.text.trim();

    try {
      // Check if the email is registered
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      print("$email");
      print("$signInMethods");
      if (signInMethods.isNotEmpty) {
        setState(() {
          message = 'No user found for that email.';
        });
        return;

        // ignore: dead_code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This email is not registered.'), backgroundColor: Colors.red),
        );
        return;
      }

      // If the email is registered, send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        message = 'Password reset link sent to $email. Please check your inbox.';
      });
      // Show a SnackBar notification for success and navigate back to login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: Colors.green,
        ),
      );

      // Wait for 2 seconds, then pop back to the login page
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        message = 'Error occurred: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This email is not registered.'), backgroundColor: Colors.red),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 27, 60, 61),
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(fontFamily: 'Oswald', color: Colors.white)),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 222, 89)),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/unnamed.png', // Replace with your logo file path
              height: 250,
              width: 250,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                floatingLabelStyle: TextStyle(
                  color: Color.fromARGB(255, 255, 222, 89),
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                      blurRadius: 1.0,
                    )
                  ],
                ),
                hintText: 'Email',
                filled: true,
                fillColor: Color.fromARGB(255, 206, 206, 206),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 255, 222, 89),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendPasswordResetEmail,
              child: Text('Send Password Reset Link', style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Oswald',
                fontWeight: FontWeight.bold,
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 222, 89),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: message.contains('Error') ? Colors.red : Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
