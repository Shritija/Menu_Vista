import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'main.dart';
import 'RestaurantListPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  String errorMessage = '';
  Timer? _timer;
  bool isRestaurantLogin = false; // Toggle for restaurant/user login

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });

    _timer?.cancel();

    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        errorMessage = '';
      });
    });
  }

  Future<bool> checkEmailInFirestore(String email, String collection) async {
    var collectionRef = FirebaseFirestore.instance.collection(collection);
    var querySnapshot = await collectionRef.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginpage3.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/unnamed.png',
                      height: 300,
                      width: 300,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Enter your Email',
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
                        prefixIcon: Icon(Icons.email, color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 222, 89),
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Enter your Password',
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
                        hintText: 'Password',
                        filled: true,
                        fillColor: Color.fromARGB(255, 206, 206, 206),
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 222, 89),
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Restaurant toggle button on the left
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isRestaurantLogin = !isRestaurantLogin;
                                });
                              },
                              child: Text(
                                isRestaurantLogin ? 'Restaurant' : 'User',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Forgot password button on the right
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/forgot_password');
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        String collection = isRestaurantLogin ? 'restaurant' : 'users';

                        try {
                          // Authenticate using FirebaseAuth
                          UserCredential userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(email: email, password: password);

                          bool emailExists = await checkEmailInFirestore(email, collection);

                          if (emailExists) {
                            setState(() {
                              errorMessage = '';
                            });

                            // Check if it's a restaurant login or user login
                            if (isRestaurantLogin) {
                              // Redirect to "Under Construction" page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnderConstructionPage(),
                                ),
                              );
                            } else {
                              // Redirect to Restaurant List Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantListPage(),
                                ),
                              );
                            }
                          } else {
                            showError('Email not found in the $collection collection.');
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            showError('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            showError('Wrong password provided.');
                          } else {
                            showError('An unexpected error occurred: ${e.message}');
                          }
                        } catch (e) {
                          showError('An unexpected error occurred: ${e.toString()}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFDE59),
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Do Not have an Account?',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}