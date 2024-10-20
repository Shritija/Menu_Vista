import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class RestaurantSignUpPage extends StatefulWidget {
  @override
  _RestaurantSignUpPageState createState() => _RestaurantSignUpPageState();
}

class _RestaurantSignUpPageState extends State<RestaurantSignUpPage> {
  final TextEditingController restaurantNameController = TextEditingController();
  final TextEditingController restaurantEmailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(); // New controller for password
  String errorMessage = '';

  Future<void> signUp() async {
    String restaurantName = restaurantNameController.text;
    String email = restaurantEmailController.text;
    String contact = contactController.text;
    String address = addressController.text;
    String password = passwordController.text; // Get the password from the controller

    // Validate the password before proceeding
    if (!validatePassword(password)) {
      setState(() {
        errorMessage = 'Password must be at least 8 characters long, contain at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character.';
      });
      return;
    }

    // Check if the email is registered with Google
    if (!await isEmailRegistered(email)) {
      setState(() {
        errorMessage = 'Please enter a valid Google account email.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password); // Use the provided password

      await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(userCredential.user!.uid)
          .set({
        'Rname': restaurantName,
        'email': email,
        'contact': contact,
        'address': address,
      });

      setState(() {
        errorMessage = '';
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'The account already exists for that email.';
        });
      } else {
        setState(() {
          errorMessage = 'Something went wrong: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      // Check if Google is one of the sign-in methods
      return signInMethods.contains('google.com');
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while checking the email: ${e.toString()}';
      });
      return false;
    }
  }

  bool validatePassword(String password) {
    // Regular expression to validate the password
    final passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    final regExp = RegExp(passwordPattern);
    return regExp.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant Sign Up',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFFFFDE59)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color(0xFF1b3c3d),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/unnamed.png', // Change image accordingly
                  height: 150,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name Input Field
                    buildInputField(
                        'Restaurant Name', 'Enter your Restaurant Name', restaurantNameController),
                    SizedBox(height: 20),

                    // Restaurant Email Input Field
                    buildInputField('Email', 'Enter your Email', restaurantEmailController),
                    SizedBox(height: 20),

                    // Contact Number Input Field
                    buildInputField('Contact No', 'Enter your Contact Number', contactController),
                    SizedBox(height: 20),

                    // Address Input Field
                    buildInputField('Address', 'Enter your Address', addressController),
                    SizedBox(height: 20),

                    // Password Input Field
                    buildInputField('Password', 'Enter your Password', passwordController, obscureText: true), // New password field
                    SizedBox(height: 30),

                    // Sign Up Button
                    Center(
                      child: ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDE59),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Restaurant Account',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Error Message Display
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
      String label,
      String hintText,
      TextEditingController controller, {
        bool obscureText = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFCECECE),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 222, 89),
                width: 2.0,
              ),
            ),
            labelText: hintText,
            labelStyle: TextStyle(color: Colors.black),
            floatingLabelStyle: TextStyle(
              color: Color(0xFFFFDE59),
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2.0, 2.0),
                  blurRadius: 1.0,
                )
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
