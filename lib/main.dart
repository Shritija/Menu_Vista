import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_vista/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
        '/menu': (context) => MenuPage( Rid: ModalRoute.of(context)!.settings.arguments as String),
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

                          // Example restaurant ID (replace with your logic)
                         // String restaurantId = 'PR5Gs3rUuEvPK6HvCZcl';
                          //String itemId = '2001';

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
  List<Map<String, dynamic>> _originalRestaurants = [];
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
          'Rid': doc['Rid'], // Adding Rid
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
                        // Navigate to MenuPage with Rid
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPage(
                              Rid: restaurant['Rid'], // Passing Rid to MenuPage
                            ),
                          ),
                        );
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
                                color: restaurant['isFavorite']
                                    ? Colors.yellow
                                    : Colors.grey,
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
      bottomNavigationBar: Container(
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
                //child: IconButton (
                 // iconSize: 20.0, // Same smaller icon size
                  //icon: Image.asset(
                  //  'assets/images/bottommenuicon.png', // Add your image path here
                  //),
                 // onPressed: () {

                 // },
              //  ),
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
  final String Rid;

  MenuPage({required this.Rid});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isVeg = true;
  bool isLiked=true;
  String vegStatus = 'Veg';
  String selectedMealType = '';
  Map<String, bool> mealSelections = {
    'Breakfast': false,
    'Lunch': false,
    'Snacks': false,
    'Dinner': false,
  };
  Map<String, List<Map<String, dynamic>>> menuData = {};

  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  Future<void> fetchMenuData() async {
    try {
      final restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurant')
          .where('Rid', isEqualTo: widget.Rid)
          .get();
      print('Fetching restaurant with Rid: ${widget.Rid}');
      if (restaurantQuery.docs.isNotEmpty) {
        final restaurantDoc = restaurantQuery.docs.first;

        final mealTypesRef = restaurantDoc.reference.collection('menuItems').doc('MealTypes');

        final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

        for (var mealType in mealTypes) {
          try {
            final mealCollectionSnapshot = await mealTypesRef.collection(mealType).get();
            if (mealCollectionSnapshot.docs.isNotEmpty) {
              setState(() {
                mealSelections[capitalize(mealType)] = true;
                menuData[capitalize(mealType)] = mealCollectionSnapshot.docs
                    .map((doc) => {
                  'itemname': doc['itemname'],
                  'itemimage': doc['itemimage'],
                  'description': doc['description'],
                  'isveg': doc['isveg'],
                  'small': doc['small'],
                  'medium': doc['medium']// Small price as number
                })
                    .where((item) => isVeg ? item['isveg'] == true : item['isveg'] == false)
                    .toList();
              });
            } else {
              setState(() {
                mealSelections[capitalize(mealType)] = false;
              });
            }
          } catch (e) {
            print('Error fetching $mealType collection: $e');
            setState(() {
              mealSelections[capitalize(mealType)] = false;
            });
          }
        }
      } else {
        print('No document found with Rid: ${widget.Rid}');
      }
    } catch (e) {
      print('Error fetching menu data: $e');
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
            height: 100,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: mealSelections.entries
                    .where((entry) => entry.value)
                    .map((entry) => _buildMealButton(entry.key))
                    .toList(),
              ),
              SizedBox(height: 10),

              // Veg/Non-Veg Toggle
              Row (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Veg/Non-Veg',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Switch(
                    value: isVeg,
                    onChanged: (value) {
                      setState(() {
                        isVeg = value;
                        vegStatus = isVeg ? 'Veg' : 'Non-Veg';
                        fetchMenuData(); // Fetch data again based on new selection
                      });
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red[300],
                    inactiveTrackColor: Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Display selected meal type items
              ..._buildMealItems(selectedMealType),
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
            //Flexible(
              //child: IconButton(
                //iconSize: 20.0,
                //icon: Image.asset(
                  //'assets/images/bottommenuicon.png',
                //),
               // onPressed: () {
                 // Navigator.pushNamed(context, '/menu');
               // },
             // ),
            //),
          ],
        ),
      ),
    );
  }

  Widget _buildMealButton(String mealType) {
    bool isSelected = selectedMealType == mealType;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        minimumSize: Size(20,40),
      ),
      onPressed: () {
        setState(() {
          selectedMealType = mealType;
        });
      },
      child: Text(
        mealType,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  List<Widget> _buildMealItems(String mealType) {
    if (mealType.isEmpty || !menuData.containsKey(mealType)) {
      return [];
    }

    final items = menuData[mealType] ?? [];
    return items.map((item) {
      return _buildMenuItem(
        imageUrl: item['itemimage'],
        name: item['itemname'],
        description: item['description'],
        smallPrice: item['small'],
        mediumPrice: item['medium']// Fetch small price as a number
      );
    }).toList();
  }

  Widget _buildMenuItem({
    required String imageUrl,
    required String name,
    required String description,
    required num smallPrice,
    required num mediumPrice// Accept small price as a number
  }) {
    bool isLiked = false; // State for heart icon
    return Container (
      
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(8.0),
      width: 500,
      height: 125,
      decoration: BoxDecoration(
        color: Color(0xFFFFDE59),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 2.0)],
      ),
      child: Stack(
          children: [
      Row (
      children: [
      //ClipRRect(
     // borderRadius: BorderRadius.circular(15),
     // child: Image.network(imageUrl, height:5, width:5, fit: BoxFit.cover),
    //),
          SizedBox(
            height: 100, // Adjust the height
            width: 50,  // Adjust the width
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // This will ensure the image fills the available space
              ),
            ),
          ),
      SizedBox(width: 5),
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(name, style: TextStyle(fontFamily: 'Oswald', fontSize: 16, fontWeight: FontWeight.bold)),
        Text(description, style: TextStyle(fontSize: 12)),
        SizedBox(height: 10),
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Row(
        children: [
        _buildSizeButton('Small'), // Pass small price
        SizedBox(width: 1),
        _buildSizeButton('Medium'), // Implement similar for Medium
        SizedBox(width: 1),
        _buildSizeButton('Large'),// Implement similar for Large
                  ],
        ),
        // Display small price at the bottom right
        Container(
        padding: EdgeInsets.symmetric(vertical:8, horizontal: 8),
        decoration: BoxDecoration(
        color: Color(0xFF1B3C3D),
        borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min, // Make the row take only the necessary space
        children: [
        Text(
        'Rs $smallPrice',
        style: TextStyle(
        fontFamily: 'Oswald',
        fontSize: 10,
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
    // Positioned for the heart icon at the top-right corner
    ],
    ),
    );
  }
  Widget _buildSizeButton(String size) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF1B3C3D),
        padding: EdgeInsets.symmetric(vertical:5, horizontal:5), // Adjust padding for smaller button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // Modify the size here
        ),
        minimumSize: Size(50,25), // Set a smaller minimum size
      ),
      onPressed: () {
        // Action for button press
      },
      child: Text(
        '$size',
        style: TextStyle(color: Colors.white, fontSize: 8),
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

class CustomisePage extends StatelessWidget {
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

/*
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
*/

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
        .doc('MealTypes') // Assuming MealTypes is a single doc, you can adjust if needed
        .collection('snacks')
        .doc(widget.itemId)
        .get();

    if (snapshot.exists) {
      setState(() {
        itemData = snapshot.data() as Map<String, dynamic>;
        price = itemData!['medium']; // Set initial price to medium
      });
    }
  }

  // Update price based on selected size
  void _updatePrice(String size) {
    setState(() {
      selectedSize = size; // Update selected size
      // Update price based on selected size
      if (size == 'Small') {
        price = itemData!['small'];
      } else if (size == 'Medium') {
        price = itemData!['medium'];
      } else if (size == 'Large') {
        price = itemData!['large'];
      }
    });
  }

  // Function to add to cart (implementation can vary)
  void _addToCart() {
    // Add the selected item to the cart
    // You can implement your add to cart logic here
    print('Added to cart: ${itemData!['itemname']} - Size: $selectedSize - Price: Rs $price');
    // Show confirmation (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${itemData!['itemname']} added to cart! Size: $selectedSize', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
        backgroundColor: Color(0xFFFFDE59),
      ),
    );
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Center(
              child: Container(
                padding: const EdgeInsets.all(0.0),
                width: 500,
                height: 250,
                child: Image.asset(
                  'assets/images/fries.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 10),

            // Item name in bold
            Text(
              itemData!['itemname'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Box for description, size selection and buttons
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1B3C3D),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description header
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),

                  // Item description with smaller font
                  Text(
                    itemData!['description'],
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)), // Smaller font for description
                  ),
                  SizedBox(height: 10),

                  // Size selection buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _sizeOption('Small'),
                      _sizeOption('Medium'),
                      _sizeOption('Large'),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Price display
                  Center(
                    child: Text(
                      'Price: Rs $price',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Customization button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomisePage(),
                              ),
                            );
                          },
                          child: Text(
                            'Customize',
                            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDE59),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Rating and Reviews Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewPage(restaurantId: widget.restaurantId, itemId: widget.itemId),
                              ),
                            );
                          },
                          child: Text(
                            'Ratings',
                            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDE59),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: () {
                      _addToCart(); // Directly add to cart
                    },
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDE59),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 142),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                    ),
                  ),
                ],
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

  // Widget to display the size options
  Widget _sizeOption(String size) {
    bool isSelected = selectedSize == size; // Check if this size is selected
    return GestureDetector(
      onTap: () {
        _updatePrice(size); // Update price when the option is tapped
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isSelected ? Color.fromARGB(255, 161, 140, 57) : Color(0xFFFFDE59), // Change to orange if selected, yellow otherwise
        ),
        width: 100, // Increased width
        child: Center(
          child: Text(
            size,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black), // Change text color based on selection
          ),
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
  String reviewText = '';
  int rating = 0;
  String username = 'Anonymous'; // Default username, can be dynamic if needed.
  double averageRating = 0.0; // To store the average rating.

  @override
  void initState() {
    super.initState();
    _calculateAverageRating();
    _fetchUsername(); // Fetch username on initialization.
  }

  void _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user

    if (user != null) {
      setState(() {
        username = user.displayName ?? user.email ?? 'Anonymous'; // Get the user's display name, email, or fallback to 'Anonymous'
      });
    }
  }

  // Calculate the average rating for the item.
  void _calculateAverageRating() async {
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.itemId)
        .collection('userreviews')
        .get();

    if (reviewSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      reviewSnapshot.docs.forEach((doc) {
        var reviewData = doc.data() as Map<String, dynamic>;
        totalRating += reviewData['rating'];
      });

      setState(() {
        averageRating = totalRating / reviewSnapshot.size;
      });
    }
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurant')
            .doc(widget.restaurantId)
            .collection('menuItems')
            .doc('MealTypes')
            .collection('snacks')
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/fries.png',
                        fit: BoxFit.cover,
                        width: double.infinity, // Fit the image to the full width of the screen.
                      ),
                      SizedBox(height: 16),
                      Text(item['itemname'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(item['description'], style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),
                      // Display the average rating as stars
                      Row(
                        children: [
                          Text('Average Rating: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          SizedBox(width: 8),
                          Text(averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      
                      // Reviews Box with Dark Background
                      Container( // Dark background for customer reviews section
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(135, 20, 63, 68),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(8),
                        child: _buildReviewsList(), // Customer reviews list
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Review Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Your Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.white, // Change background color to white
                      child: TextField(
                        maxLines: 2, // Make the review input smaller
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
                    ),
                    SizedBox(height: 8),
                    _buildRatingBar(),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _submitReview,
                      child: Text('Submit Review', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDE59),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 142),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                    ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.itemId)
          .collection('userreviews')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return Text('No reviews yet', style: TextStyle(color: Colors.white)); // Change text color to white for visibility.
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Row(
                children: [
                  Text(review['username'], style: TextStyle(color: Colors.white)), // Change text color to white.
                  SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    )),
                  ),
                ],
              ),
              subtitle: Text(review['review'], style: TextStyle(color: Colors.white)), // Change text color to white.
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
      // Create a new review document with a unique ID
      FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.itemId)
          .collection('userreviews')
          .add({ // Use `add()` to automatically generate a unique document ID
        'username': username, // Use the dynamically fetched username
        'review': reviewText,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        // Successfully added review
        setState(() {
          reviewText = '';
          rating = 0;
        });

        // Recalculate average rating after submitting the review.
        _calculateAverageRating();
      }).catchError((error) {
        // Handle any errors that occur during submission
        print("Failed to add review: $error");
      });
    }
  }
}

