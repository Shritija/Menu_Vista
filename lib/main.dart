import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_vista/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/*
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
*/
/*
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}

*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBFwOrZUiMrCXz6LWQ0wEfmlt8_qWTgtks",
        appId: "1:722133009908:web:a1f557a260aa0927f5e5a1",
        messagingSenderId: "722133009908",
        projectId: "menuvista-cebae",
        authDomain: "menuvista-cebae.firebaseapp.com",
        storageBucket: "menuvista-cebae.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(MenuVistaApp());
}

class MenuVistaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginpage3.png',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground with the login form elements inside SingleChildScrollView
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Adding the logo at the top
                    Image.asset(
                      'assets/images/unnamed.png', // Replace with your logo file path
                      height: 300,
                      width: 300,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          fontFamily: 'Oswald',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Color(0xFFD9D9D9),
                        prefixIcon: Icon(Icons.email, color: Colors.black),
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
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontFamily: 'Oswald',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Color(0xFFD9D9D9),
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
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
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Switch(
                                  value: rememberMe,
                                  onChanged: (val) {
                                    setState(() {
                                      rememberMe = val;
                                    });
                                  },
                                  activeColor: Colors.black,
                                ),
                                Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8.0),
                          ),
                        ),
                        SizedBox(width: 10),
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
                                  fontSize: 15,
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

                        try {
                          // Sign in with Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(email: email, password: password);

                          setState(() {
                            errorMessage = '';
                          });

                          // Example restaurant ID (replace with your logic)
                          String restaurantId = 'PR5Gs3rUuEvPK6HvCZcl';

                          // Navigate to the RestaurantMenuPage after successful login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantMenuPage(restaurantId: restaurantId),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            setState(() {
                              errorMessage = 'No user found for that email.';
                            });
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              errorMessage = 'Wrong password provided.';
                            });
                          } else {
                            setState(() {
                              errorMessage = 'An unexpected error occurred: ${e.message}';
                            });
                          }
                        } catch (e) {
                          // Handle any other errors
                          setState(() {
                            errorMessage = 'An unexpected error occurred: ${e.toString()}';
                          });
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
                    Text(
                      'Or Sign in with',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Column(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/Google-Symbol.png',
                            height: 60,
                            width: 60,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'GOOGLE',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
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


class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Logged in',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

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
      // Query Firestore for the user's email
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          message = 'No user found for that email.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user found for that email.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Use Firebase Authentication to send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        setState(() {
          message = 'Password reset link sent to $email.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email'),
            backgroundColor: Colors.green,
          ),
        );

        // Simulate a delay and go back to the login page
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error occurred: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
              'assets/images/logo.png', // Replace with your logo file path
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

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> signUp() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After creating the user, store additional information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });

      // Clear previous error message
      setState(() {
        errorMessage = '';
      });

      // Navigate back to login or main menu after successful sign-up
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth errors
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
      // Handle any other unexpected errors
      setState(() {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
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
      ),
      backgroundColor: Color(0xFF1b3c3d),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30), // Space between the top and logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Path to your logo image
                  height: 150, // Image size
                ),
              ),
              SizedBox(height: 30), // Space between the logo and form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input Field
                    Text(
                      'Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFCECECE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Space between input fields

                    // Email Input Field
                    Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFCECECE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password Input Field
                    Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFCECECE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Sign Up Button
                    Center(
                      child: ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDE59),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Create Account'),
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
}


class RestaurantMenuPage extends StatelessWidget {
  final String restaurantId;

  RestaurantMenuPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurant')
            .doc(restaurantId)
            .collection('menuItems')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final menuItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];

              return ListTile(
                title: Text(item['name']),
                subtitle: Text('Rs ${item['mediumPrice']}'),
                leading: Image.network(item['imageUrl']),
                onTap: () {
                  String itemId ='t2PnlkfFIP8c2K2PSw1F';
                  Navigator.push(
                    context,
                    /*MaterialPageRoute(
                      builder: (context) => ItemDetailPage(itemId: itemId),
                    ),*/
                    MaterialPageRoute(
                      builder: (context) => ItemPage(
                        restaurantId: restaurantId,
                        itemId: itemId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ItemPage extends StatefulWidget {
  final String restaurantId;
  final String itemId;

  ItemPage({required this.restaurantId, required this.itemId});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  Map<String, dynamic>? itemData; // To store fetched item details
  String selectedSize = 'Medium';
  int price = 0;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  // Fetch item details from Firestore
  void _fetchItemDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(widget.restaurantId)
        .collection('menuItems')
        .doc(widget.itemId)
        .get();

    if (snapshot.exists) {
      setState(() {
        itemData = snapshot.data() as Map<String, dynamic>;
        price = itemData!['mediumPrice']; // Set initial price to medium
      });
    }
  }

  // Update price based on selected size
  void _updatePrice(String size) {
    setState(() {
      selectedSize = size;
      if (size == 'Small') {
        price = itemData!['smallPrice'];
      } else if (size == 'Medium') {
        price = itemData!['mediumPrice'];
      } else if (size == 'Large') {
        price = itemData!['largePrice'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (itemData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(itemData!['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Center(
              child: Image.network(itemData!['imageUrl'], height: 200),
            ),
            SizedBox(height: 10),

            // Item description
            Text(
              itemData!['description'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),

            // Ingredients
            // Ingredients
            Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              itemData?['ingredients'] != null && itemData!['ingredients'] is List
                  ? itemData!['ingredients'].join(', ')
                  : 'No ingredients available',
            ),


            SizedBox(height: 20),

            // Size selection and price update
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _sizeOption('Small', itemData!),
                _sizeOption('Medium', itemData!),
                _sizeOption('Large', itemData!),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Price: Rs $price',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Add to Cart Button
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add item to cart logic here
                },
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ),

            // Review and Rating Button
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String itemId ='t2PnlkfFIP8c2K2PSw1F';
                  String restaurantId = 'PR5Gs3rUuEvPK6HvCZcl';
                  Navigator.push(
                    context,
                    /*MaterialPageRoute(
                      builder: (context) => ItemDetailPage(itemId: itemId),
                    ),*/
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(restaurantId: restaurantId, itemId: itemId),
                    ),
                  );
                },
                child: Text('Rating and Reviews'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.account_circle, color: Colors.white), onPressed: () {}),
              IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {}),
              IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display the size options
  Widget _sizeOption(String size, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        _updatePrice(size);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: selectedSize == size ? Colors.teal : Colors.grey.shade300,
        ),
        child: Text(
          size,
          style: TextStyle(color: selectedSize == size ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}




class ReviewPage extends StatefulWidget {
  final String restaurantId;
  final String itemId;

  ReviewPage({required this.restaurantId, required this.itemId});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String selectedSize = 'Medium';
  String reviewText = '';
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurant')
            .doc(widget.restaurantId)
            .collection('menuItems')
            .doc(widget.itemId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text('Item not found.'));
          }

          var item = snapshot.data!.data() as Map<String, dynamic>?;

          if (item == null) {
            return Center(child: Text('No data available for this item.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(item['imageUrl']),
                SizedBox(height: 16),
                Text(item['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(item['description'], style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildReviewsList(),
                SizedBox(height: 16),
                Text('Add Your Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Write a review',
                  ),
                  onChanged: (text) {
                    setState(() {
                      reviewText = text;
                    });
                  },
                ),
                SizedBox(height: 8),
                _buildRatingBar(),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Submit Review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .doc(widget.itemId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return Text('No reviews yet');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text('Rating: ${review['rating']}'),
              subtitle: Text(review['review']),
            );
          },
        );
      },
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1;
            });
          },
        );
      }),
    );
  }

  void _submitReview() {
    if (reviewText.isNotEmpty && rating > 0) {
      FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .doc(widget.itemId)
          .collection('reviews')
          .add({
        'rating': rating,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        reviewText = '';
        rating = 0;
      });
    }
  }
}
