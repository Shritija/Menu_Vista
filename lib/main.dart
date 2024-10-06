import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_vista/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For managing timer for error message removal




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
        '/restaurant_list': (context) => RestaurantListPage(),
        '/menu': (context) => MenuPage(),
        '/profile': (context) => ProfilePage(),
        '/cart': (context) => ShoppingCartPage(),
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
  Timer? _timer; // Timer instance

  @override
  void dispose() {
    // Cancel the timer if the widget is disposed
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });

    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer to clear the error message after 1 minute
    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        errorMessage = ''; // Clear the error message
      });
    });
  }

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
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10.0),
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

                        try {
                          // Sign in with Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(email: email, password: password);

                          setState(() {
                            errorMessage = '';
                          });
                          // Navigate to the RestaurantMenuPage after successful login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantListPage(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            showError('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            showError('Wrong password provided.');
                          } else {
                            showError('An unexpected error occurred: ${e.message}');
                          }
                        } catch (e) {
                          // Handle any other errors
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





class RestaurantListPage extends StatefulWidget {
  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _originalRestaurants = []; // List to store original order
  bool _isLoading = false;
  String _searchQuery = '';
  bool _searchPerformed = false;

  // Firestore query function to search for restaurants
  Future<void> searchRestaurants(String query) async {
    setState(() {
      _isLoading = true;
      _searchPerformed = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .where('Rname', isGreaterThanOrEqualTo: query)
          .where('Rname', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      List<Map<String, dynamic>> restaurants = snapshot.docs.map((doc) {
        return {
          'name': doc['Rname'],
          'address': doc['address'],
          'isFavorite': false, // Initially, no restaurant is favorited
        };
      }).toList();

      // Store the original order of restaurants
      _originalRestaurants = List<Map<String, dynamic>>.from(restaurants);

      restaurants.removeWhere((r) => _favorites.any((fav) => fav['name'] == r['name']));
      List<Map<String, dynamic>> combinedList = _favorites + restaurants;

      setState(() {
        _restaurants = combinedList; // Update the restaurant list with favorites on top
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching restaurants: $e');
      setState(() {
        _isLoading = false;
        _restaurants = [];
      });
    }
  }

  // Function to toggle the favorite status of a restaurant
  void toggleFavorite(Map<String, dynamic> restaurant) {
    setState(() {
      restaurant['isFavorite'] = !restaurant['isFavorite']; // Toggle favorite state

      if (restaurant['isFavorite']) {
        _favorites.add(restaurant); // Add to favorites
        _restaurants.remove(restaurant); // Remove from the regular list
        _restaurants.insert(0, restaurant); // Insert at the top of the list
      } else {
        _favorites.removeWhere((fav) => fav['name'] == restaurant['name']);
        _restaurants.remove(restaurant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFCFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1B3C3D),
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UnderConstructionPage(),
              ),
            );
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
            onPressed: () {
              // Currently does nothing, it's a blank space
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Box
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Update the search query
                });
                if (value.isNotEmpty) {
                  searchRestaurants(value); // Call the search function
                } else {
                  setState(() {
                    _restaurants = _favorites; // Only show favorites if search is empty
                    _searchPerformed = false; // Reset the search indicator
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Type Restaurant Name...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set the border color to black
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set the focused border color to black
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set the enabled border color to black
                    width: 1.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            // Scrollable list of restaurants
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _restaurants.isEmpty && _searchPerformed
                  ? Center(child: Text('Not Available'))
                  : SingleChildScrollView(
                child: Column(
                  children: _restaurants.map((restaurant) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to restaurant page
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1B3C3D),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant['name'],
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  restaurant['address'],
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.star,
                                color: restaurant['isFavorite'] ? Colors.yellow : Colors.grey,
                              ),
                              onPressed: () {
                                toggleFavorite(restaurant); // Toggle favorite state
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container (
        color: Color(0xFF1B3C3D),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Profile Button
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1B3C3D),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(1, 1), // Smaller shadow
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: IconButton(
                  iconSize: 20.0, // Smaller icon size to fit better
                  icon: Image.asset(
                    'assets/images/profileicon.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
            ),
            // Shopping Cart Button
            Flexible(
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
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/shoppingcarticon.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ),
            ),
            // Menu Button
            Flexible(
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
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/bottommenuicon.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/menu');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class UnderConstructionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Under Construction'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Under Construction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isVeg = true; // For Veg/Non-Veg toggle
  bool isLiked = false; // For the heart (like/unlike) functionality
  String vegStatus = 'Veg'; // Veg/Non-Veg status
  Map<String, bool> mealSelections = {
    'Breakfast': false,
    'Lunch': false,
    'Snacks': false,
    'Dinner': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFCFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1B3C3D),
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UnderConstructionPage(),
              ),
            );
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
            onPressed: () {
              // Does nothing for now
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search burger, beverage etc...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Meal category buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMealButton('Breakfast'),
                  _buildMealButton('Lunch'),
                  _buildMealButton('Snacks'),
                  _buildMealButton('Dinner'),
                ],
              ),

              SizedBox(height: 10),

              // Veg/Non-Veg Toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns content inside the column to the left
                      children: [
                        Text(
                          'Veg/Non-Veg',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Wrap the Switch in a Container to add a border
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Black border
                            borderRadius: BorderRadius.circular(20), // Optional: Add rounded corners
                          ),
                          child: Switch(
                            value: isVeg,
                            onChanged: (value) {
                              setState(() {
                                isVeg = value;
                                vegStatus = isVeg ? 'Veg' : 'Non-Veg';
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red[300],
                            inactiveTrackColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )


                ],
              ),

              SizedBox(height: 10),

              // Food item button (Fries)
              Container (
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Positioned for the heart icon at the top-right corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        iconSize: 30.0,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite,
                          color: isLiked ? Colors.blueGrey : Color(0xFF1B3C3D),
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                    ),
                    // Content of the item (fries image, text, price, size buttons, etc.)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 0),
                        // Image on the left inside rounded rectangle
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black, width: 0),
                                ),
                                child: Image.asset(
                                  'assets/images/fries.png', // Replace this with your actual image path
                                  height: 130, // Adjusted height for larger image
                                  width: 100, // Adjusted width for larger image
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5),

                        // Text details
                        Expanded (
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title inside a rectangle
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Peri Peri Fries',
                                  style: TextStyle(
                                    fontFamily: 'Oswald',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Crunchy Fries topped with tangy tomato sauce',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),

                              // Size selection buttons and price
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildSizeButton('Medium'),
                                      SizedBox(width: 5),
                                      _buildSizeButton('Small'),
                                      SizedBox(width: 5),
                                      _buildSizeButton('Large'),
                                    ],
                                  ),
                                  // Price inside rounded rectangle
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical:5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1B3C3D),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min, // Make the row take only the necessary space
                                      children: [
                                        Text(
                                          'Rs 120',
                                          style: TextStyle(
                                            fontFamily: 'Oswald',
                                            fontSize:8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFF1B3C3D),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Profile Button
            Flexible(
              child: IconButton(
                iconSize: 20.0,
                icon: Image.asset(
                  'assets/images/profileicon.png',
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
            // Shopping Cart Button
            Flexible(
              child: IconButton(
                iconSize: 20.0,
                icon: Image.asset(
                  'assets/images/shoppingcarticon.png',
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
            // Menu Button
            Flexible(
              child: IconButton(
                iconSize: 20.0,
                icon: Image.asset(
                  'assets/images/bottommenuicon.png',
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/menu');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for building meal category buttons with toggle effect
  Widget _buildMealButton(String mealType) {
    bool isSelected = mealSelections[mealType] ?? false;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust padding here
        minimumSize: Size(50,50), // Set minimum size for width and height
      ),
      onPressed: () {
        setState(() {
          // Toggle selection state
          mealSelections.forEach((key, value) {
            mealSelections[key] = false; // Reset others
          });
          mealSelections[mealType] = !isSelected; // Toggle current
        });
      },
      child: Text(
        mealType,
        style: TextStyle(
          color: Colors.white, // White text
          fontSize: 14, // You can adjust font size if needed
        ),
      ),
    );
  }


  // Widget for size buttons (Medium, Small, Large) filled with color 1B3C3D
  Widget _buildSizeButton(String size) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF1B3C3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: Color(0xFF1B3C3D)),
        padding: EdgeInsets.symmetric(vertical:5, horizontal:10), // Adjust padding here
        minimumSize: Size(2,2), // Set minimum size for width and height
      ),
      onPressed: () {
        // Size selection action
      },
      child: Text(
        size,
        style: TextStyle(
          color: Colors.white, // White text
          fontSize: 8,
          fontWeight: FontWeight.bold, // You can adjust font size if needed
        ),
      ),
    );
  }
}


class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Under Construction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class ShoppingCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Under Construction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
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
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
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
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 222, 89),
                            width: 2.0,
                          ),
                        ),
                        labelText: 'Enter your Name',
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
                    SizedBox(height: 20),

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
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 222, 89),
                            width: 2.0,
                          ),
                        ),
                        labelText: 'Enter your Email',
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
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 222, 89),
                            width: 2.0,
                          ),
                        ),
                        labelText: 'Enter your Password',
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
}



