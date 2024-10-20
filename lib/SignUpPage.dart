import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'RestaurantSignUpPage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? gender;
  String errorMessage = '';

  // Password validation method
  bool isPasswordValid(String password) {
    final passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    final regExp = RegExp(passwordPattern);
    return regExp.hasMatch(password);
  }

  Future<bool> isGoogleAccount(String email) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      // Attempt to authenticate silently with Google Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
      return googleUser != null && googleUser.email == email;
    } catch (e) {
      return false; // Return false if the sign-in fails
    }
  }

  Future<void> signUp() async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String contact = contactController.text;
    String address = addressController.text;

    // Check if the email is a Google account
    bool isGoogleEmail = await isGoogleAccount(email);
    if (!isGoogleEmail) {
      setState(() {
        errorMessage = 'Please use a valid Google email address.';
      });
      return;
    }

    // Password validation check
    if (!isPasswordValid(password)) {
      setState(() {
        errorMessage = 'Password must be at least 8 characters long, contain at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'contact': contact,
        'address': address,
        'gender': gender,
      });

      setState(() {
        errorMessage = '';
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          errorMessage = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFFFFDE59)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Text(
              'Restaurant',
              style: TextStyle(color: Color(0xFFFFDE59), fontFamily: 'Oswald'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantSignUpPage()),
              );
            },
          ),
        ],
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
                  'assets/images/unnamed.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input Field
                    buildInputField('Name', 'Enter your Name', nameController),
                    SizedBox(height: 20),

                    // Email Input Field
                    buildInputField('Email', 'Enter your Email', emailController),
                    SizedBox(height: 20),

                    // Contact Number Input Field
                    buildInputField('Contact Number', 'Enter your Contact Number', contactController),
                    SizedBox(height: 20),

                    // Address Input Field
                    buildInputField('Address', 'Enter your Address', addressController),
                    SizedBox(height: 20),

                    // Gender Input Field
                    Text(
                      'Gender',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: gender,
                      dropdownColor: Color(0xFFCECECE),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFCECECE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                          .toList(),
                      hint: Text(
                        'Select Gender',
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Password Input Field
                    buildInputField(
                      'Password',
                      'Enter your Password',
                      passwordController,
                      obscureText: true,
                    ),
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
                          'Create Account',
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
