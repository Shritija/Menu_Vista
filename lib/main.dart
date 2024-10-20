import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_vista/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orderlistpage.dart';
import 'menueditpage.dart';
import 'pay.dart';
import 'umpsk.dart';
import 'profpic.dart';
import 'scsk.dart';
import 'fpsk.dart';
import 'supsk.dart';
import 'rlsk.dart';
import 'lgsk.dart';
import 'LoginPage.dart';
import 'RestaurantListPage.dart';
import 'MenuPage.dart';
import 'CartPage.dart';
import 'ForgotPasswordPage.dart';
import 'ItemPage.dart';
import 'PaymentPage.dart';
import 'ProfilePage.dart';
import 'RestaurantSignUpPage.dart';
import 'ReviewPage.dart';
import 'SignUpPage.dart';


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
      // Use onGenerateRoute for dynamic routing
      onGenerateRoute: (settings) {
          case '/forgot_password':
            return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/restaurant_list':
            return MaterialPageRoute(builder: (context) => RestaurantListPage());
          case '/menu':
            final Rid = settings.arguments as String; // Retrieve the Rid argument
            return MaterialPageRoute(
              builder: (context) => MenuPage(Rid: Rid), // Pass Rid to MenuPage
            );
          case '/profile':
            final documentId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (context) => ProfilePage(documentId: documentId),
            );
          case '/cart':
            final args = settings.arguments as Map<String, String>; // Expect a Map for cart
            return MaterialPageRoute(
              builder: (context) => CartPage(
                   restaurantId: args['restaurantId']!, // Get restaurantId
                   itemId: args['itemId']!,
                  userId: args['userId']!,
                  extraInstructions: args['extraInstructions']!,
                  selectedSize: args['selectedSize']!,
                  price: args['price'] as int,
        ),
            );
          case '/item':
            final itemArgs = settings.arguments as Map<String, String>; // Expect a Map for item
            return MaterialPageRoute(
              builder: (context) => ItemPage(
                restaurantId: itemArgs['restaurantId']!, // Get restaurantId
                itemId: itemArgs['itemId']!, // Get itemId
              ),
            );
          case '/review':
            final reviewArgs = settings.arguments as Map<String, String>; // Expect a Map for review
            return MaterialPageRoute(
              builder: (context) => ReviewPage(
                restaurantId: reviewArgs['restaurantId']!, // Get restaurantId
                itemId: reviewArgs['itemId']!, // Get itemId
              ),
            );
          case '/restaurantsignup':
            return MaterialPageRoute(builder: (context) => RestaurantSignUpPage());
          default:
            return null; // Return null for unknown routes
        }
      },
    );
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool rememberMe = false;
//   String errorMessage = '';
//   Timer? _timer;
//   bool isRestaurantLogin = false; // Toggle for restaurant/user login

//   @override
//   void dispose() {
//     _timer?.cancel();
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   void showError(String message) {
//     setState(() {
//       errorMessage = message;
//     });

//     _timer?.cancel();

//     _timer = Timer(Duration(seconds: 5), () {
//       setState(() {
//         errorMessage = '';
//       });
//     });
//   }

//   Future<bool> checkEmailInFirestore(String email, String collection) async {
//     var collectionRef = FirebaseFirestore.instance.collection(collection);
//     var querySnapshot = await collectionRef.where('email', isEqualTo: email).get();
//     return querySnapshot.docs.isNotEmpty;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/loginpage3.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/images/unnamed.png',
//                       height: 300,
//                       width: 300,
//                     ),
//                     TextField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Enter your Email',
//                         labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//                         floatingLabelStyle: TextStyle(
//                           color: Color.fromARGB(255, 255, 222, 89),
//                           shadows: [
//                             Shadow(
//                               color: Colors.black,
//                               offset: Offset(2.0, 2.0),
//                               blurRadius: 1.0,
//                             )
//                           ],
//                         ),
//                         hintText: 'Email',
//                         filled: true,
//                         fillColor: Color.fromARGB(255, 206, 206, 206),
//                         prefixIcon: Icon(Icons.email, color: Colors.black),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(255, 255, 222, 89),
//                             width: 2.0,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: TextStyle(
//                         fontFamily: 'Oswald',
//                         color: Colors.black,
//                         fontSize: 18,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     TextField(
//                       controller: passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         labelText: 'Enter your Password',
//                         labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//                         floatingLabelStyle: TextStyle(
//                           color: Color.fromARGB(255, 255, 222, 89),
//                           shadows: [
//                             Shadow(
//                               color: Colors.black,
//                               offset: Offset(2.0, 2.0),
//                               blurRadius: 1.0,
//                             )
//                           ],
//                         ),
//                         hintText: 'Password',
//                         filled: true,
//                         fillColor: Color.fromARGB(255, 206, 206, 206),
//                         prefixIcon: Icon(Icons.lock, color: Colors.black),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(255, 255, 222, 89),
//                             width: 2.0,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: TextStyle(
//                         fontFamily: 'Oswald',
//                         color: Colors.black,
//                         fontSize: 18,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Restaurant toggle button on the left
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Color(0xFFD9D9D9),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             child: TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   isRestaurantLogin = !isRestaurantLogin;
//                                 });
//                               },
//                               child: Text(
//                                 isRestaurantLogin ? 'Restaurant' : 'User',
//                                 style: TextStyle(
//                                   fontFamily: 'Oswald',
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                             padding: EdgeInsets.all(8.0),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         // Forgot password button on the right
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Color(0xFFD9D9D9),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             child: TextButton(
//                               onPressed: () {
//                                 Navigator.pushNamed(
//                                     context, '/forgot_password');
//                               },
//                               child: Text(
//                                 'Forgot Password?',
//                                 style: TextStyle(
//                                   fontFamily: 'Oswald',
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                             padding: EdgeInsets.all(8.0),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () async {
//                           String email = emailController.text.trim();
//                           String password = passwordController.text.trim();
//                           String collection = isRestaurantLogin ? 'restaurant' : 'users';
//                           try {
//                             // Authenticate using FirebaseAuth
//                             UserCredential userCredential = await FirebaseAuth.instance
//                                 .signInWithEmailAndPassword(email: email, password: password);
//                             bool emailExists = await checkEmailInFirestore(email, collection);
//                             if (emailExists) {
//                               setState(() {
//                                 errorMessage = '';
//                               });
//                               // Check if it's a restaurant login
//                               if (isRestaurantLogin) {
//                                 // Fetch restaurant documentId from Firestore
//                                 var collectionRef = FirebaseFirestore.instance.collection('restaurant');
//                                 var querySnapshot = await collectionRef.where('email', isEqualTo: email).get();

//                                 if (querySnapshot.docs.isNotEmpty) {
//                                   String documentId = querySnapshot.docs.first.id;

//                                   // Redirect to OrdersPage with the documentId
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => OrderListPage(restaurantId: documentId),
//                                     ),
//                                   );
//                                 } 
//                                 else {
//                                   showError('Restaurant not found.');
//                                 }
//                               } 
//                               else {
//                                 // Redirect to Restaurant List Page for user login
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => RestaurantListPage(),
//                                   ),
//                                 );
//                               }
//                             } 
//                             else {
//                               showError('Email not found in the $collection collection.');
//                             }
//                           } 
//                           on FirebaseAuthException catch (e) 
//                           {
//                             if (e.code == 'user-not-found') {
//                                 showError('No user found for that email.');
//                               } 
//                             else if (e.code == 'wrong-password') {
//                                 showError('Wrong password provided.');
//                               } 
//                             else {
//                                 showError('An unexpected error occurred: ${e.message}');
//                               }
//                           } 
//                           catch (e) 
//                           {
//                             showError('An unexpected error occurred: ${e.toString()}');
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFFFDE59),
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 50, vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text(
//                         'Log In',
//                         style: TextStyle(
//                           fontFamily: 'Oswald',
//                           color: Colors.white,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     if (errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     SizedBox(height: 5),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Do Not have an Account?',
//                           style: TextStyle(
//                             fontFamily: 'Oswald',
//                             color: Colors.white70,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/signup');
//                           },
//                           child: Text(
//                             'Sign up',
//                             style: TextStyle(
//                               fontFamily: 'Oswald',
//                               color: Colors.redAccent,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                               decoration: TextDecoration.underline,
//                               decorationColor: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class RestaurantListPage extends StatefulWidget {
//   @override
//   _RestaurantListPageState createState() => _RestaurantListPageState();
// }

// class _RestaurantListPageState extends State<RestaurantListPage> {
//   List<Map<String, dynamic>> _restaurants = [];
//   List<Map<String, dynamic>> _favorites = [];
//   List<Map<String, dynamic>> _originalRestaurants = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   bool _searchPerformed = false;

//   // Firestore query function to search for restaurants
//   Future<void> searchRestaurants(String query) async {
//     setState(() {
//       _isLoading = true;
//       _searchPerformed = true;
//     });

//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('restaurant')
//           .where('Rname', isGreaterThanOrEqualTo: query)
//           .where('Rname', isLessThanOrEqualTo: query + '\uf8ff')
//           .get();

//       List<Map<String, dynamic>> restaurants = snapshot.docs.map((doc) {
//         return {
//           'Rid': doc['Rid'], // Adding Rid
//           'name': doc['Rname'],
//           'address': doc['address'],
//           'isFavorite': false, // Initially, no restaurant is favorited
//         };
//       }).toList();

//       // Store the original order of restaurants
//       _originalRestaurants = List<Map<String, dynamic>>.from(restaurants);

//       restaurants.removeWhere((r) => _favorites.any((fav) => fav['name'] == r['name']));
//       List<Map<String, dynamic>> combinedList = _favorites + restaurants;

//       setState(() {
//         _restaurants = combinedList; // Update the restaurant list with favorites on top
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error searching restaurants: $e');
//       setState(() {
//         _isLoading = false;
//         _restaurants = [];
//       });
//     }
//   }

//   // Function to toggle the favorite status of a restaurant
//   void toggleFavorite(Map<String, dynamic> restaurant) {
//     setState(() {
//       restaurant['isFavorite'] = !restaurant['isFavorite']; // Toggle favorite state

//       if (restaurant['isFavorite']) {
//         _favorites.add(restaurant); // Add to favorites
//         _restaurants.remove(restaurant); // Remove from the regular list
//         _restaurants.insert(0, restaurant); // Insert at the top of the list
//       } else {
//         _favorites.removeWhere((fav) => fav['name'] == restaurant['name']);
//         _restaurants.remove(restaurant);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFEAFCFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UnderConstructionPage(),
//               ),
//             );
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Currently does nothing, it's a blank space
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search Box
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value; // Update the search query
//                 });
//                 if (value.isNotEmpty) {
//                   searchRestaurants(value); // Call the search function
//                 } else {
//                   setState(() {
//                     _restaurants = _favorites; // Only show favorites if search is empty
//                     _searchPerformed = false; // Reset the search indicator
//                   });
//                 }
//               },
//               decoration: InputDecoration(
//                 hintText: 'Type Restaurant Name...',
//                 prefixIcon: Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: BorderSide(
//                     color: Colors.black, // Set the border color to black
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: BorderSide(
//                     color: Colors.black, // Set the focused border color to black
//                     width: 2.0,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   borderSide: BorderSide(
//                     color: Colors.black, // Set the enabled border color to black
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),
//             // Scrollable list of restaurants
//             Expanded(
//               child: _isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : _restaurants.isEmpty && _searchPerformed
//                   ? Center(child: Text('Not Available'))
//                   : SingleChildScrollView(
//                 child: Column(
//                   children: _restaurants.map((restaurant) {
//                     return GestureDetector(
//                       onTap: () {
//                         // Navigate to MenuPage with Rid
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MenuPage(
//                               Rid: restaurant['Rid'], // Passing Rid to MenuPage
//                             ),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Color(0xFF1B3C3D),
//                           borderRadius: BorderRadius.circular(10.0),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 5.0,
//                               spreadRadius: 2.0,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   restaurant['name'],
//                                   style: TextStyle(
//                                     fontFamily: 'Oswald',
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Text(
//                                   restaurant['address'],
//                                   style: TextStyle(
//                                     fontFamily: 'Oswald',
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 Icons.star,
//                                 color: restaurant['isFavorite']
//                                     ? Colors.yellow
//                                     : Colors.grey,
//                               ),
//                               onPressed: () {
//                                 toggleFavorite(restaurant); // Toggle favorite state
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: Color(0xFF1B3C3D),
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Profile Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1), // Smaller shadow
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Smaller icon size to fit better
//                   icon: Image.asset(
//                     'assets/images/profileicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/profile');
//                   },
//                 ),
//               ),
//             ),
//             // Shopping Cart Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/shoppingcarticon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/cart');
//                   },
//                 ),
//               ),
//             ),
//             // Menu Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 //child: IconButton (
//                  // iconSize: 20.0, // Same smaller icon size
//                   //icon: Image.asset(
//                   //  'assets/images/bottommenuicon.png', // Add your image path here
//                   //),
//                  // onPressed: () {

//                  // },
//               //  ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class UnderConstructionPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Under Construction'),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Text(
//           'Under Construction',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }
// }
// class MenuPage extends StatefulWidget {
//   final String Rid;

//   MenuPage({required this.Rid});

//   @override
//   _MenuPageState createState() => _MenuPageState();
// }

// class _MenuPageState extends State<MenuPage> {
//   bool isVeg = true;
//   String vegStatus = 'Veg';
//   String selectedMealType = '';
//   String searchQuery = '';
//   Map<String, bool> mealSelections = {
//     'Breakfast': false,
//     'Lunch': false,
//     'Snacks': false,
//     'Dinner': false,
//   };
//   Map<String, List<Map<String, dynamic>>> menuData = {};
//   Map<String, String> selectedSizes = {};  // Track selected size per item
//   Map<String, num> selectedPrices = {};    // Track selected price per item

//   @override
//   void initState() {
//     super.initState();
//     fetchMenuData();
//   }

//   Future<void> fetchMenuData() async {
//     try {
//       final restaurantQuery = await FirebaseFirestore.instance
//           .collection('restaurant')
//           .doc(widget.Rid) // Use the passed Rid
//           .get();

//       print('Fetching restaurant with Rid: ${widget.Rid}');
//       if (restaurantQuery.exists) {
//         final mealTypesRef = restaurantQuery.reference.collection('menuItems').doc('MealTypes');

//         final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

//         for (var mealType in mealTypes) {
//           try {
//             final mealCollectionSnapshot = await mealTypesRef.collection(mealType).get();
//             if (mealCollectionSnapshot.docs.isNotEmpty) {
//               setState(() {
//                 mealSelections[capitalize(mealType)] = true;
//                 menuData[capitalize(mealType)] = mealCollectionSnapshot.docs
//                     .map((doc) {
//                   Map<String, dynamic> itemData = {
//                     'itemname': doc['itemname'],
//                     'itemimage': doc['itemimage'],
//                     'description': doc['description'],
//                     'isveg': doc['isveg'],
//                     'documentId': doc.id, // Store documentId for navigation
//                   };

//                   // Check and include only available sizes
//                   if (doc.data().containsKey('small') && doc['small'] != null) {
//                     itemData['small'] = doc['small'];
//                   }
//                   if (doc.data().containsKey('medium') && doc['medium'] != null) {
//                     itemData['medium'] = doc['medium'];
//                   }
//                   if (doc.data().containsKey('large') && doc['large'] != null) {
//                     itemData['large'] = doc['large'];
//                   }

//                   return itemData;
//                 })
//                     .where((item) => isVeg ? item['isveg'] == true : item['isveg'] == false)
//                     .toList();
//               });
//             } else {
//               setState(() {
//                 mealSelections[capitalize(mealType)] = false;
//               });
//             }
//           } catch (e) {
//             print('Error fetching $mealType collection: $e');
//             setState(() {
//               mealSelections[capitalize(mealType)] = false;
//             });
//           }
//         }
//       } else {
//         print('No document found with Rid: ${widget.Rid}');
//       }
//     } catch (e) {
//       print('Error fetching menu data: $e');
//     }
//   }
//   Future<void> performSearch(String query) async {
//     setState(() {
//       searchQuery = query;
//     });

//     try {
//       final restaurantQuery = await FirebaseFirestore.instance
//           .collection('restaurant')
//           .doc(widget.Rid)  // Ensure we search in the correct restaurant
//           .get();

//       print('Searching in restaurant with Rid: ${widget.Rid}');
//       if (restaurantQuery.exists) {
//         final mealTypesRef = restaurantQuery.reference.collection('menuItems').doc('MealTypes');

//         // Clear current search results
//         menuData = {};

//         // List of meal types to search
//         final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

//         for (var mealType in mealTypes) {
//           try {
//             final mealCollectionSnapshot = await mealTypesRef.collection(mealType)
//                 .where('itemname', isGreaterThanOrEqualTo: query)
//                 .where('itemname', isLessThanOrEqualTo: query + '\uf8ff')  // Perform search
//                 .get();

//             if (mealCollectionSnapshot.docs.isNotEmpty) {
//               setState(() {
//                 mealSelections[capitalize(mealType)] = true;
//                 menuData[capitalize(mealType)] = mealCollectionSnapshot.docs.map((doc) {
//                   Map<String, dynamic> itemData = {
//                     'itemname': doc['itemname'],
//                     'itemimage': doc['itemimage'],
//                     'description': doc['description'],
//                     'isveg': doc['isveg'],
//                     'documentId': doc.id,
//                   };
//                   if (doc.data().containsKey('small') && doc['small'] != null) {
//                     itemData['small'] = doc['small'];
//                   }
//                   if (doc.data().containsKey('medium') && doc['medium'] != null) {
//                     itemData['medium'] = doc['medium'];
//                   }
//                   if (doc.data().containsKey('large') && doc['large'] != null) {
//                     itemData['large'] = doc['large'];
//                   }

//                   return itemData;
//                 }).toList();
//               });
//             } else {
//               setState(() {
//                 menuData[capitalize(mealType)] = [];
//               });
//             }
//           } catch (e) {
//             print('Error searching $mealType collection: $e');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error searching for items: $e');
//     }
//   }


//   String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFEAFCFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: PopupMenuButton<String>(
//           icon: Icon(Icons.settings, color: Colors.white),
//           color: Color(0xFFEAFCFA), // Background color for the dropdown
//           itemBuilder: (BuildContext context) {
//             return [
//               PopupMenuItem<String>(
//                 value: 'profile',
//                 child: Row(
//                   children: [
//                     Icon(Icons.person, color: Colors.black),
//                     SizedBox(width: 8),
//                     Text(
//                       'Profile',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'about_us',
//                 child: Row(
//                   children: [
//                     Icon(Icons.info, color: Colors.black),
//                     SizedBox(width: 8),
//                     Text(
//                       'About Us',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: Colors.black),
//                     SizedBox(width: 8),
//                     Text(
//                       'Logout',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//             ];
//           },
//           onSelected: (String value) async {
//             if (value == 'profile') {
//               // Fetch user details from Firestore using the email from the authenticated user
//               String email = FirebaseAuth.instance.currentUser?.email ?? ''; // Get the current user's email
//               print('Current logged-in user email: $email');

//               if (email.isNotEmpty) {
//                 // Search for the user document in the 'users' collection
//                 QuerySnapshot userSnapshot = await FirebaseFirestore.instance
//                     .collection('users')
//                     .where('email', isEqualTo: email)
//                     .get();

//                 if (userSnapshot.docs.isNotEmpty) {
//                   DocumentSnapshot userDocument = userSnapshot.docs.first;

//                   // Get the document ID
//                   String documentId = userDocument.id;

//                   // Navigate to ProfilePage and pass the document ID
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       //builder: (context) => ProfilePage(documentId: documentId),
//                       builder: (context) => ProfilePage(),
//                     ),
//                   );
//                 } else {
//                   // Handle the case where the user document does not exist
//                   print('User document not found.');
//                 }
//               } else {
//                 print('No user is currently logged in.');
//               }
//             } else if (value == 'logout') {
//               // Navigate back to the LoginPage
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//                     (route) => false,
//               );
//             } else if (value == 'about_us') {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => UnderConstructionPage(),
//                 ),
//               );
//             }
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Does nothing for now
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Search bar
//               TextField(
//                 onChanged: (value) {
//                   performSearch(value);  // Call the search method
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search burger, beverage etc...',
//                   prefixIcon: Icon(Icons.search),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     borderSide: BorderSide(
//                       color: Colors.black,
//                       width: 1.0,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // Meal category buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: mealSelections.entries
//                     .where((entry) => entry.value)
//                     .map((entry) => _buildMealButton(entry.key))
//                     .toList(),
//               ),
//               SizedBox(height: 10),

//               // Veg/Non-Veg Toggle
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Veg/Non-Veg',
//                     style: TextStyle(
//                       fontFamily: 'Oswald',
//                       fontSize: 12,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Switch(
//                     value: isVeg,
//                     onChanged: (value) {
//                       setState(() {
//                         isVeg = value;
//                         vegStatus = isVeg ? 'Veg' : 'Non-Veg';
//                         fetchMenuData(); // Fetch data again based on new selection
//                       });
//                     },
//                     activeColor: Colors.green,
//                     inactiveThumbColor: Colors.red[300],
//                     inactiveTrackColor: Colors.red,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),

//               // Display selected meal type items
//               ..._buildMealItems(selectedMealType),
//             ],
//           ),
//         ),
//       ),
//         bottomNavigationBar: Container(
//           color: Color(0xFF1B3C3D),
//           height: 50,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               // Back Button with Navigator.push and MaterialPageRoute
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Color(0xFF1B3C3D),
//                     borderRadius: BorderRadius.circular(2),
//                     border: Border.all(
//                       color: Colors.black12, // Border color
//                       width: 1,          // Border width
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black45,
//                         offset: Offset(5, 5),
//                         blurRadius: 1.0,
//                       ),
//                     ],
//                   ),
//                   padding: EdgeInsets.all(5.0),
//                   child: IconButton(
//                     iconSize: 20.0,
//                     icon: Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => RestaurantListPage()), // Replace with the correct page
//                       );
//                     },
//                   ),
//                 ),
//               ),

//               // Shopping Cart Button with Navigator.push and MaterialPageRoute
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Color(0xFF1B3C3D),
//                     borderRadius: BorderRadius.circular(2),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black45,
//                         offset: Offset(1, 1),
//                         blurRadius: 1.0,
//                       ),
//                     ],
//                   ),
//                   padding: EdgeInsets.all(10.0),
//                   //child: IconButton(
//                   //  iconSize: 30.0,
//                   //  icon: Image.asset('assets/images/shoppingcarticon.png'),
//                     /*onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => CartPage()), // Replace with the correct page
//                       );
//                     },*/
//                  // ),
//                 ),
//               ),
//             ],
//           ),
//         )



//     );
//   }

//   Widget _buildMealButton(String mealType) {
//     bool isSelected = selectedMealType == mealType;
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         minimumSize: Size(20, 40),
//       ),
//       onPressed: () {
//         setState(() {
//           selectedMealType = mealType;
//         });
//       },
//       child: Text(
//         mealType,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildMealItems(String mealType) {
//     if (mealType.isEmpty || !menuData.containsKey(mealType)) {
//       return [];
//     }

//     final items = menuData[mealType] ?? [];
//     return items.map((item) {
//       return _buildMenuItem(
//         imageUrl: item['itemimage'],
//         name: item['itemname'],
//         description: item['description'],
//         smallPrice: item['small'],
//         mediumPrice: item['medium'],
//         largePrice: item['large'],
//         documentId: item['documentId'],
//       );
//     }).toList();
//   }

//   Widget _buildMenuItem({
//     required String imageUrl,
//     required String name,
//     required String description,
//     required num? smallPrice,
//     required num? mediumPrice,
//     required num? largePrice,
//     required String documentId,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the ItemPage and pass Rid and documentId
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ItemPage(
//               restaurantId: widget.Rid, // Use the Rid from the current MenuPage
//               itemId: documentId,       // Pass the documentId of the selected item
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 10.0),
//         padding: EdgeInsets.all(8.0),
//         width: 500,
//         height: 125,
//         decoration: BoxDecoration(
//           color: Color(0xFFFFDE59),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 2.0)],
//         ),
//         child: Stack(
//           children: [
//             Row(
//               children: [
//                 SizedBox(
//                   height: 100,
//                   width: 50,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.network(
//                       imageUrl, // Use the imageUrl passed from the menu item
//                       fit: BoxFit.cover,
//                     ),

//                   ),
//                 ),
//                 SizedBox(width: 5),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(name, style: TextStyle(fontFamily: 'Oswald', fontSize: 16, fontWeight: FontWeight.bold)),
//                       Text(description, style: TextStyle(fontSize: 12)),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               if (smallPrice != null) _buildSizeButton('Small', smallPrice, documentId),
//                               if (mediumPrice != null) _buildSizeButton('Medium', mediumPrice, documentId),
//                               if (largePrice != null) _buildSizeButton('Large', largePrice, documentId),
//                             ],
//                           ),
//                           // Display the selected price for this specific item
//                           if (selectedPrices.containsKey(documentId))
//                             Container(
//                               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF1B3C3D),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 'Rs ${selectedPrices[documentId]}',
//                                 style: TextStyle(
//                                   fontFamily: 'Oswald',
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSizeButton(String label, num price, String documentId) {
//     bool isSelected = selectedSizes[documentId] == label; // Check if this size is selected for this item

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedSizes[documentId] = label;  // Update selected size for this specific item
//           selectedPrices[documentId] = price; // Update the price for this specific item
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 4.0),
//         padding: EdgeInsets.all(4.0),
//         decoration: BoxDecoration(
//           color: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D), // Change color based on selection
//           borderRadius: BorderRadius.circular(4.0),
//           border: Border.all(color: Colors.grey),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: Colors.white, // Set text color to white
//             fontFamily: 'Oswald', // Use bold Oswald font
//             fontWeight: FontWeight.bold, // Make text bold
//           ),
//         ),
//       ),
//     );
//   }
// }


// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Text(
//           'Under Construction',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ShoppingCartPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shopping Cart'),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Text(
//           'Under Construction',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomisePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shopping Cart'),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Text(
//           'Under Construction',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ForgotPasswordPage extends StatefulWidget {
//   @override
//   _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final TextEditingController emailController = TextEditingController();
//   String message = '';

//   Future<void> sendPasswordResetEmail() async {
//     String email = emailController.text.trim();

//     try {
//       // Check if the email is registered
//       List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
//       print("$email");
//       print("$signInMethods");
//       if (signInMethods.isNotEmpty) {
//         setState(() {
//           message = 'No user found for that email.';
//         });
//         return;

//         // ignore: dead_code
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('This email is not registered.'), backgroundColor: Colors.red),
//         );
//         return;
//       }

//       // If the email is registered, send the password reset email
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//       setState(() {
//         message = 'Password reset link sent to $email. Please check your inbox.';
//       });
//       // Show a SnackBar notification for success and navigate back to login page
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Password reset link sent to $email'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Wait for 2 seconds, then pop back to the login page
//       Future.delayed(Duration(seconds: 2), () {
//         Navigator.pop(context);
//       });
//     } catch (e) {
//       setState(() {
//         message = 'Error occurred: ${e.toString()}';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('This email is not registered.'), backgroundColor: Colors.red),
//       );
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 27, 60, 61),
//       appBar: AppBar(
//         title: Text('Forgot Password', style: TextStyle(fontFamily: 'Oswald', color: Colors.white)),
//         iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 222, 89)),
//         backgroundColor: Color.fromARGB(255, 0, 0, 0),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Image.asset(
//               'assets/images/unnamed.png', // Replace with your logo file path
//               height: 250,
//               width: 250,
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your email',
//                 labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//                 floatingLabelStyle: TextStyle(
//                   color: Color.fromARGB(255, 255, 222, 89),
//                   shadows: [
//                     Shadow(
//                       color: Colors.black,
//                       offset: Offset(2.0, 2.0),
//                       blurRadius: 1.0,
//                     )
//                   ],
//                 ),
//                 hintText: 'Email',
//                 filled: true,
//                 fillColor: Color.fromARGB(255, 206, 206, 206),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(255, 255, 222, 89),
//                     width: 2.0,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: sendPasswordResetEmail,
//               child: Text('Send Password Reset Link', style: TextStyle(
//                 color: const Color.fromARGB(255, 0, 0, 0),
//                 fontFamily: 'Oswald',
//                 fontWeight: FontWeight.bold,
//               )),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromARGB(255, 255, 222, 89),
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               message,
//               style: TextStyle(color: message.contains('Error') ? Colors.red : Colors.green),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   String errorMessage = '';

//   Future<void> signUp() async {
//     String name = nameController.text;
//     String email = emailController.text;
//     String password = passwordController.text;

//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name': name,
//         'email': email,
//       });

//       setState(() {
//         errorMessage = '';
//       });

//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         setState(() {
//           errorMessage = 'The password provided is too weak.';
//         });
//       } else if (e.code == 'email-already-in-use') {
//         setState(() {
//           errorMessage = 'The account already exists for that email.';
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Something went wrong: ${e.message}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'An error occurred: ${e.toString()}';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Sign Up',
//           style: TextStyle(
//             fontFamily: 'Oswald',
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: IconThemeData(color: Color(0xFFFFDE59)),
//         backgroundColor: Colors.black,
//       ),
//       backgroundColor: Color(0xFF1b3c3d),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 30),
//               Center(
//                 child: Image.asset(
//                   'assets/images/unnamed.png',
//                   height: 150,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Name Input Field
//                     Text(
//                       'Name',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: nameController,
//                       style: TextStyle(color: Colors.black),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Color(0xFFCECECE),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(255, 255, 222, 89),
//                             width: 2.0,
//                           ),
//                         ),
//                         labelText: 'Enter your Name',
//                         labelStyle: TextStyle(color: Colors.black),
//                         floatingLabelStyle: TextStyle(
//                           color: Color(0xFFFFDE59),
//                           shadows: [
//                             Shadow(
//                               color: Colors.black,
//                               offset: Offset(2.0, 2.0),
//                               blurRadius: 1.0,
//                             )
//                           ],
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // Email Input Field
//                     Text(
//                       'Email',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: emailController,
//                       style: TextStyle(color: Colors.black),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Color(0xFFCECECE),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(255, 255, 222, 89),
//                             width: 2.0,
//                           ),
//                         ),
//                         labelText: 'Enter your Email',
//                         labelStyle: TextStyle(color: Colors.black),
//                         floatingLabelStyle: TextStyle(
//                           color: Color(0xFFFFDE59),
//                           shadows: [
//                             Shadow(
//                               color: Colors.black,
//                               offset: Offset(2.0, 2.0),
//                               blurRadius: 1.0,
//                             )
//                           ],
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // Password Input Field
//                     Text(
//                       'Password',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: passwordController,
//                       obscureText: true,
//                       style: TextStyle(color: Colors.black),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Color(0xFFCECECE),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Color.fromARGB(255, 255, 222, 89),
//                             width: 2.0,
//                           ),
//                         ),
//                         labelText: 'Enter your Password',
//                         labelStyle: TextStyle(color: Colors.black),
//                         floatingLabelStyle: TextStyle(
//                           color: Color(0xFFFFDE59),
//                           shadows: [
//                             Shadow(
//                               color: Colors.black,
//                               offset: Offset(2.0, 2.0),
//                               blurRadius: 1.0,
//                             )
//                           ],
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),

//                     // Sign Up Button
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: signUp,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFFFFDE59),
//                           foregroundColor: Colors.black,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'Create Account',
//                           style: TextStyle(
//                             fontFamily: 'Oswald',
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Error Message Display
//                     if (errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Center(
//                           child: Text(
//                             errorMessage,
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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

// class ItemPage extends StatefulWidget {
//   final String restaurantId;
//   final String itemId;

//   ItemPage({required this.restaurantId, required this.itemId});

//   @override
//   _ItemPageState createState() => _ItemPageState();
// }

// class _ItemPageState extends State<ItemPage> {
//   Map<String, dynamic>? itemData; // To store fetched item details
//   String selectedSize = 'Medium';
//   int price = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchItemDetails();
//   }

//   // Fetch item details from Firestore
//   void _fetchItemDetails() async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('restaurant')
//         .doc(widget.restaurantId)
//         .collection('menuItems')
//         .doc('MealTypes') // Assuming MealTypes is a single doc, you can adjust if needed
//         .collection('snacks')
//         .doc(widget.itemId)
//         .get();

//     if (snapshot.exists) {
//       setState(() {
//         itemData = snapshot.data() as Map<String, dynamic>;
//         price = itemData!['medium']; // Set initial price to medium
//       });
//     }
//   }

//   // Update price based on selected size
//   void _updatePrice(String size) {
//     setState(() {
//       selectedSize = size; // Update selected size
//       // Update price based on selected size
//       if (size == 'Small') {
//         price = itemData!['small'];
//       } else if (size == 'Medium') {
//         price = itemData!['medium'];
//       } else if (size == 'Large') {
//         price = itemData!['large'];
//       }
//     });
//   }

//   // Function to add to cart (implementation can vary)
//   void _addToCart() {
//     // Add the selected item to the cart
//     // You can implement your add to cart logic here
//     print('Added to cart: ${itemData!['itemname']} - Size: $selectedSize - Price: Rs $price');
//     // Show confirmation (optional)
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${itemData!['itemname']} added to cart! Size: $selectedSize', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
//         backgroundColor: Color(0xFFFFDE59),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (itemData == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Loading...'),
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       backgroundColor: Color(0xFFEAFCFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UnderConstructionPage(),
//               ),
//             );
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Currently does nothing, it's a blank space
//             },
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Item image
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(0.0),
//                 width: 500,
//                 height: 250,
//                 child: Image.asset(
//                   'assets/images/fries.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             SizedBox(height: 10),

//             // Item name in bold
//             Text(
//               itemData!['itemname'],
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),

//             // Box for description, size selection and buttons
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Color(0xFF1B3C3D),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     blurRadius: 5,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Description header
//                   Text(
//                     'Description',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                   SizedBox(height: 5),

//                   // Item description with smaller font
//                   Text(
//                     itemData!['description'],
//                     style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)), // Smaller font for description
//                   ),
//                   SizedBox(height: 10),

//                   // Size selection buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _sizeOption('Small'),
//                       _sizeOption('Medium'),
//                       _sizeOption('Large'),
//                     ],
//                   ),
//                   SizedBox(height: 10),

//                   // Price display
//                   Center(
//                     child: Text(
//                       'Price: Rs $price',
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255)),
//                     ),
//                   ),
//                   SizedBox(height: 10),

//                   // Customization button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => CustomisePage(),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             'Customize',
//                             style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFFFFDE59),
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       // Rating and Reviews Button
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ReviewPage(restaurantId: widget.restaurantId, itemId: widget.itemId),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             'Ratings',
//                             style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFFFFDE59),
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   // Add to Cart Button
//                   ElevatedButton(
//                     onPressed: () {
//                       _addToCart(); // Directly add to cart
//                     },
//                     child: Text(
//                       'Add to Cart',
//                       style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFFFDE59),
//                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 142),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container (
//         color: Color(0xFF1B3C3D),
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Profile Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1), // Smaller shadow
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Smaller icon size to fit better
//                   icon: Image.asset(
//                     'assets/images/profileicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/profile');
//                   },
//                 ),
//               ),
//             ),
//             // Shopping Cart Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/shoppingcarticon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/cart');
//                   },
//                 ),
//               ),
//             ),
//             // Menu Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/bottommenuicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/menu');
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget to display the size options
//   Widget _sizeOption(String size) {
//     bool isSelected = selectedSize == size; // Check if this size is selected
//     return GestureDetector(
//       onTap: () {
//         _updatePrice(size); // Update price when the option is tapped
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         margin: EdgeInsets.only(right: 8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           color: isSelected ? Color.fromARGB(255, 161, 140, 57) : Color(0xFFFFDE59), // Change to orange if selected, yellow otherwise
//         ),
//         width: 100, // Increased width
//         child: Center(
//           child: Text(
//             size,
//             style: TextStyle(color: isSelected ? Colors.white : Colors.black), // Change text color based on selection
//           ),
//         ),
//       ),
//     );
//   }
// }





// class ReviewPage extends StatefulWidget {
//   final String restaurantId;
//   final String itemId;

//   ReviewPage({required this.restaurantId, required this.itemId});

//   @override
//   _ReviewPageState createState() => _ReviewPageState();
// }

// class _ReviewPageState extends State<ReviewPage> {
//   String reviewText = '';
//   int rating = 0;
//   String username = 'Anonymous'; // Default username, can be dynamic if needed.
//   double averageRating = 0.0; // To store the average rating.

//   @override
//   void initState() {
//     super.initState();
//     _calculateAverageRating();
//     _fetchUsername(); // Fetch username on initialization.
//   }

//   void _fetchUsername() async {
//     User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user

//     if (user != null) {
//       setState(() {
//         username = user.displayName ?? user.email ?? 'Anonymous'; // Get the user's display name, email, or fallback to 'Anonymous'
//       });
//     }
//   }

//   // Calculate the average rating for the item.
//   void _calculateAverageRating() async {
//     QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
//         .collection('reviews')
//         .doc(widget.itemId)
//         .collection('userreviews')
//         .get();

//     if (reviewSnapshot.docs.isNotEmpty) {
//       double totalRating = 0;
//       reviewSnapshot.docs.forEach((doc) {
//         var reviewData = doc.data() as Map<String, dynamic>;
//         totalRating += reviewData['rating'];
//       });

//       setState(() {
//         averageRating = totalRating / reviewSnapshot.size;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFEAFCFA),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UnderConstructionPage(),
//               ),
//             );
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Currently does nothing, it's a blank space
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('restaurant')
//             .doc(widget.restaurantId)
//             .collection('menuItems')
//             .doc('MealTypes')
//             .collection('snacks')
//             .doc(widget.itemId)
//             .get(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.data!.exists) {
//             return Center(child: Text('Item not found.'));
//           }

//           var item = snapshot.data!.data() as Map<String, dynamic>?;

//           if (item == null) {
//             return Center(child: Text('No data available for this item.'));
//           }

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Image.asset(
//                         'assets/images/fries.png',
//                         fit: BoxFit.cover,
//                         width: double.infinity, // Fit the image to the full width of the screen.
//                       ),
//                       SizedBox(height: 16),
//                       Text(item['itemname'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 8),
//                       Text(item['description'], style: TextStyle(fontSize: 16)),
//                       SizedBox(height: 16),
//                       // Display the average rating as stars
//                       Row(
//                         children: [
//                           Text('Average Rating: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                           Row(
//                             children: List.generate(5, (index) {
//                               return Icon(
//                                 index < averageRating ? Icons.star : Icons.star_border,
//                                 color: Colors.amber,
//                               );
//                             }),
//                           ),
//                           SizedBox(width: 8),
//                           Text(averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      
//                       // Reviews Box with Dark Background
//                       Container( // Dark background for customer reviews section
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(135, 20, 63, 68),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: EdgeInsets.all(8),
//                         child: _buildReviewsList(), // Customer reviews list
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Submit Review Section
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Add Your Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Container(
//                       color: Colors.white, // Change background color to white
//                       child: TextField(
//                         maxLines: 2, // Make the review input smaller
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Write a review',
//                         ),
//                         onChanged: (text) {
//                           setState(() {
//                             reviewText = text;
//                           });
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     _buildRatingBar(),
//                     SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: _submitReview,
//                       child: Text('Submit Review', style: TextStyle(color: Colors.black)),
//                       style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFFFDE59),
//                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 142),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
//                     ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: Container (
//         color: Color(0xFF1B3C3D),
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Profile Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1), // Smaller shadow
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Smaller icon size to fit better
//                   icon: Image.asset(
//                     'assets/images/profileicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/profile');
//                   },
//                 ),
//               ),
//             ),
//             // Shopping Cart Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/shoppingcarticon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/cart');
//                   },
//                 ),
//               ),
//             ),
//             // Menu Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/bottommenuicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/menu');
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//     );
//   }

//   Widget _buildReviewsList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('reviews')
//           .doc(widget.itemId)
//           .collection('userreviews')
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         var reviews = snapshot.data!.docs;

//         if (reviews.isEmpty) {
//           return Text('No reviews yet', style: TextStyle(color: Colors.white)); // Change text color to white for visibility.
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: reviews.length,
//           itemBuilder: (context, index) {
//             var review = reviews[index].data() as Map<String, dynamic>;
//             return ListTile(
//               title: Row(
//                 children: [
//                   Text(review['username'], style: TextStyle(color: Colors.white)), // Change text color to white.
//                   SizedBox(width: 8),
//                   Row(
//                     children: List.generate(5, (i) => Icon(
//                       i < review['rating'] ? Icons.star : Icons.star_border,
//                       color: Colors.amber,
//                       size: 16,
//                     )),
//                   ),
//                 ],
//               ),
//               subtitle: Text(review['review'], style: TextStyle(color: Colors.white)), // Change text color to white.
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildRatingBar() {
//     return Row(
//       children: List.generate(5, (index) {
//         return IconButton(
//           icon: Icon(
//             index < rating ? Icons.star : Icons.star_border,
//             color: Colors.amber,
//           ),
//           onPressed: () {
//             setState(() {
//               rating = index + 1;
//             });
//           },
//         );
//       }),
//     );
//   }

//   void _submitReview() {
//     if (reviewText.isNotEmpty && rating > 0) {
//       // Create a new review document with a unique ID
//       FirebaseFirestore.instance
//           .collection('reviews')
//           .doc(widget.itemId)
//           .collection('userreviews')
//           .add({ // Use `add()` to automatically generate a unique document ID
//         'username': username, // Use the dynamically fetched username
//         'review': reviewText,
//         'rating': rating,
//         'timestamp': FieldValue.serverTimestamp(),
//       }).then((_) {
//         // Successfully added review
//         setState(() {
//           reviewText = '';
//           rating = 0;
//         });

//         // Recalculate average rating after submitting the review.
//         _calculateAverageRating();
//       }).catchError((error) {
//         // Handle any errors that occur during submission
//         print("Failed to add review: $error");
//       });
//     }
//   }
// }




// CartPage class updated to be StatefulWidget
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
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
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is currently empty'));
          }

          final cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index].data() as Map<String, dynamic>;
                    var cartItemId = cartItems[index].id;

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(cartItem['name']),
                        subtitle: Text('Price: Rs ${cartItem['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateQuantity(cartItemId, cartItem['quantity'] - 1);
                              },
                            ),
                            Text('${cartItem['quantity']}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(cartItemId, cartItem['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _billDetails(cartItems),
              _proceedToPayButton(cartItems),
            ],
          );
        },
      ),
    );
  }

  void _updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity > 0) {
      cartCollection.doc(cartItemId).update({'quantity': newQuantity});
    } else {
      cartCollection.doc(cartItemId).delete();
    }
  }

  Widget _billDetails(List<QueryDocumentSnapshot> cartItems) {
    double totalAmount = cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });

    double gst = totalAmount * 0.18;
    double finalAmount = totalAmount + gst;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _billDetailRow('Item total', 'Rs ${totalAmount.toStringAsFixed(2)}'),
          _billDetailRow('GST (18%)', 'Rs ${gst.toStringAsFixed(2)}'),
          Divider(color: Colors.black),
          _billDetailRow('Total to Pay', 'Rs ${finalAmount.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _billDetailRow(String title, String value, {bool isBold = false}) {
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

  Widget _proceedToPayButton(List<QueryDocumentSnapshot> cartItems) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[600],
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(cartItems: cartItems),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Proceed To Pay', style: TextStyle(color: Colors.black, fontSize: 18)),
        ],
=======
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
>>>>>>> 3428e1b8d0fcbf1d4ed023a819d86e0a1996b5c8
      ),
    );
  }
}
<<<<<<< HEAD



// PaymentPage class which uses the Payment class
// class PaymentPage extends StatefulWidget {
//   final List<QueryDocumentSnapshot> cartItems;

//   PaymentPage({required this.cartItems});

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   String? selectedUpiApp;
//   String? selectedPaymentMethod;

//   // Total amount and final amount including GST calculation
//   late double totalAmount;
//   late double finalAmount;

//   @override
//   void initState() {
//     super.initState();
//     totalAmount = widget.cartItems.fold(0.0, (sum, item) {
//       return sum + (item['price'] * item['quantity']);
//     });
//     double gst = totalAmount * 0.18;
//     finalAmount = totalAmount + gst;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal[900],
//         title: Text('Foodico', style: TextStyle(fontSize: 24)),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.settings),
//           onPressed: () {}, // Handle settings action
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.restaurant_menu),
//             onPressed: () {}, // Handle restaurant menu action
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Payment Options Header
//               Text(
//                 'Payment Options',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 '${widget.cartItems.length} Items  :  Total Rs ${finalAmount.toStringAsFixed(2)}',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 20),

//               // Pay by an UPI App
//               Container(
//                 color: Colors.yellow[100],
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Pay by an UPI App',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Image.asset(
//                               'assets/images/google_pay.png', // Add your Google Pay icon asset here
//                               height: 40,
//                               width: 40,
//                             ),
//                             SizedBox(width: 10),
//                             Text('Google Pay', style: TextStyle(fontSize: 16)),
//                           ],
//                         ),
//                         Radio<String>(
//                           value: 'google_pay',
//                           groupValue: selectedUpiApp,
//                           onChanged: (String? value) {
//                             setState(() {
//                               selectedUpiApp = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     TextButton.icon(
//                       onPressed: () {
//                         // Handle Add New UPI ID
//                       },
//                       icon: Icon(Icons.add, color: Colors.red),
//                       label: Text(
//                         'Add New UPI ID',
//                         style: TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),

//               // More Payment Options
//               Text(
//                 'More Payment Options',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               _paymentOptionTile(
//                 context,
//                 icon: Icons.account_balance_wallet,
//                 color: Colors.purple,
//                 title: 'Wallets',
//               ),
//               _paymentOptionTile(
//                 context,
//                 icon: Icons.credit_card,
//                 color: Colors.orange,
//                 title: 'Netbanking',
//               ),
//               _paymentOptionTile(
//                 context,
//                 icon: Icons.money,
//                 color: Colors.green,
//                 title: 'Cash',
//               ),
//               _paymentOptionTile(
//                 context,
//                 icon: Icons.payment,
//                 color: Colors.yellow,
//                 title: 'Debit or Credit Card',
//               ),
//               SizedBox(height: 30),

//               // Proceed Button
//               ElevatedButton(
//                 onPressed: selectedUpiApp == 'google_pay'
//                     ? () => _makePayment(finalAmount)
//                     : null, // Disable button if no UPI app is selected
//                 child: Text('Proceed to Pay Rs ${finalAmount.toStringAsFixed(2)}'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _paymentOptionTile(BuildContext context, {required IconData icon, required Color color, required String title}) {
//     return ListTile(
//       leading: Icon(icon, color: color, size: 36),
//       title: Text(title, style: TextStyle(fontSize: 16)),
//       trailing: Radio<String>(
//         value: title,
//         groupValue: selectedPaymentMethod,
//         onChanged: (String? value) {
//           setState(() {
//             selectedPaymentMethod = value;
//           });
//         },
//       ),
//     );
//   }

//   Future<void> _makePayment(double amount) async {
//     try {
//       final transactionRef = await UpiPay.initiateTransaction(
//         amount: amount.toStringAsFixed(2),
//         app: UpiApplication.googlePay,
//         receiverUpiAddress: 'merchant@upi', // Replace with actual UPI ID
//         receiverName: 'Merchant Name',
//         transactionRef: 'T1234',
//         transactionNote: 'Payment for items',
//       );
//       print('Payment initiated: $transactionRef');
//     } catch (e) {
//       print('Payment failed: $e');
//     }
//   }
// }
// Import your MenuEditPage

// class OrderListPage extends StatefulWidget {
//   final String restaurantId; // Add restaurantId as a parameter

//   OrderListPage({required this.restaurantId}); // Update the constructor

//   @override
//   _OrderListPageState createState() => _OrderListPageState();
// }

// class _OrderListPageState extends State<OrderListPage> {
//   int _currentIndex = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UnderConstructionPage(),
//               ),
//             );
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Currently does nothing, it's a blank space
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('orders')
//             .where('orderstatus', isEqualTo: 'pending') // Fetch only pending orders
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             // Show a message if there are no pending orders
//             return Center(child: Text("No orders yet."));
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((order) {
//               return Card(
//                 child: ListTile(
//                   title: Text("Order id: ${order['orderId']}"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Customer Id: ${order['customerId']}"),
//                       Text("Order Type: ${order['orderType']}"),
//                       Text("Time: ${DateFormat('hh:mm a, dd MMM yyyy').format(order['time'].toDate())}"),
//                     ],
//                   ),
//                   trailing: ElevatedButton(
//                     onPressed: () {
//                       // Use the document ID directly
//                       String orderId = order.id;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => orderDetailsPage(orderId),
//                         ),
//                       );
//                     },
//                     child: Text("View Order"),
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//       bottomNavigationBar: Container (
//         color: Color(0xFF1B3C3D),
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Profile Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1), // Smaller shadow
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Smaller icon size to fit better
//                   icon: Image.asset(
//                     'assets/images/profileicon.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => restaurantProfilePage(restaurantId: "PR5Gs3rUuEvPK6HvCZcl"),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             // Shopping Cart Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/home_white.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/orderlist');
//                   },
//                 ),
//               ),
//             ),
//             // Menu Button
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color(0xFF1B3C3D),
//                   borderRadius: BorderRadius.circular(2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black45,
//                       offset: Offset(1, 1),
//                       blurRadius: 1.0,
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   iconSize: 20.0, // Same smaller icon size
//                   icon: Image.asset(
//                     'assets/images/edit.png', // Add your image path here
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/editmenu');
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MenuEditPage extends StatefulWidget {
//   final String Rid;
//   MenuEditPage({required this.Rid});

//   @override
//   _MenuEditPageState createState() => _MenuEditPageState();
// }

// class _MenuEditPageState extends State<MenuEditPage> {
//   bool isVeg = true;
//   String selectedMealType = '';
//   bool isLoading = true; // Added to show a loading state
//   Map<String, bool> mealSelections = {
//     'Breakfast': false,
//     'Lunch': false,
//     'Snacks': false,
//     'Dinner': false,
//   };
//   Map<String, List<Map<String, dynamic>>> menuData = {};

//   @override
//   void initState() {
//     super.initState();
//     fetchMenuData();
//   }

//   Future<void> fetchMenuData({bool preserveSelectedMealType = false}) async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//     try {
//       final restaurantQuery = await FirebaseFirestore.instance
//           .collection('restaurant')
//           .doc(widget.Rid)
//           .get();
//       if (restaurantQuery.exists) {
//         final mealTypesRef = restaurantQuery.reference.collection('menuItems').doc('MealTypes');

//         final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

//         for (var mealType in mealTypes) {
//           try {
//             final mealCollectionSnapshot = await mealTypesRef.collection(mealType).get();
//             if (mealCollectionSnapshot.docs.isNotEmpty) {
//               setState(() {
//                 mealSelections[capitalize(mealType)] = true;
//                 menuData[capitalize(mealType)] = mealCollectionSnapshot.docs
//                     .map((doc) => {
//                           'itemname': doc['itemname'],
//                           'itemimage': doc['itemimage']?.isNotEmpty == true 
//                               ? doc['itemimage'] 
//                               : "https://th.bing.com/th/id/OIP.xMGhvTUooiLk2wpYCa7R1QHaHa?w=170&h=180&c=7&r=0&o=5&pid=1.7", // Fallback image URL
//                           'description': doc['description'],
//                           'isveg': doc['isveg'],
//                           'small': doc['small'],
//                           'medium': doc['medium']
//                         })
//                     .where((item) => isVeg ? item['isveg'] == true : item['isveg'] == false)
//                     .toList();
//               });
//             } else {
//               setState(() {
//                 mealSelections[capitalize(mealType)] = false;
//               });
//             }
//           } catch (e) {
//             print('Error fetching $mealType collection: $e');
//             setState(() {
//               mealSelections[capitalize(mealType)] = false;
//             });
//           }
//         }

//         // Set the first available meal type as the default selected, only if not preserving
//         if (!preserveSelectedMealType) {
//           selectedMealType = mealSelections.entries.firstWhere((entry) => entry.value, orElse: () => MapEntry('', false)).key;
//         }
//       } else {
//         print('No document found with Rid: ${widget.Rid}');
//       }
//     } catch (e) {
//       print('Error fetching menu data: $e');
//     } finally {
//       setState(() {
//         isLoading = false; // Loading finished
//       });
//     }
//   }


//   String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color(0xFF1B3C3D),
//         leading: IconButton(
//           icon: Icon(Icons.settings, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UnderConstructionPage(),
//               ),
//             );
//           },
//         ),
//         title: Center(
//           child: Image.asset(
//             'assets/images/MenuVistaicon.png',
//             height: 50,
//             width: 200,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/images/topmenuicon.png',
//               height: 50,
//               width: 50,
//             ),
//             onPressed: () {
//               // Currently does nothing, it's a blank space
//             },
//           ),
//         ],
//       ),
//       body: isLoading ? Center(child: CircularProgressIndicator()) : _buildContent(),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             // Search bar
//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Search the item to be edited/deleted",
//                 prefixIcon: Icon(Icons.search),
//               ),
//             ),
//             SizedBox(height: 10),

//             // Meal category buttons using Wrap
//             _buildMealTypeButtons(
//               mealSelections.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
//             ),
//             SizedBox(height: 10),

//             // Veg/Non-Veg Toggle
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Veg/Non-Veg',
//                   style: TextStyle(
//                     fontFamily: 'Oswald',
//                     fontSize: 12,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Switch(
//                   value: isVeg,
//                   onChanged: (value) {
//                     setState(() {
//                       isVeg = value;
//                       fetchMenuData(preserveSelectedMealType: true); // Fetch data again based on new selection
//                     });
//                   },
//                   activeColor: Colors.green,
//                   inactiveThumbColor: Colors.red[300],
//                   inactiveTrackColor: Colors.red,
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),

//             // Display menu items
//             ..._buildMealItems(selectedMealType),

//             // Add Item Button aligned just above the bottom navigation bar
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 20.0, bottom: 60.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => addItemPage("PR5Gs3rUuEvPK6HvCZcl"),
//                       ),
//                     );
//                   },
//                   child: Text("Add Item"),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       color: Color(0xFF1B3C3D),
//       height: 50,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // Profile Button
//           Flexible(
//             child: IconButton(
//               iconSize: 20.0,
//               icon: Image.asset(
//                 'assets/images/profileicon.png',
//               ),
//               onPressed: () {
//                 Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => restaurantProfilePage(restaurantId: "PR5Gs3rUuEvPK6HvCZcl"),
//                       ),
//                     );
//               },
//             ),
//           ),
//           // Home Button
//           Flexible(
//             child: IconButton(
//               iconSize: 20.0,
//               icon: Image.asset(
//                 'assets/images/home_white.png',
//               ),
//               onPressed: () {
//                 Navigator.pushNamed(context, '/orderlist');
//               },
//             ),
//           ),
//           // Edit Menu Button
//           Flexible(
//             child: IconButton(
//               iconSize: 20.0,
//               icon: Image.asset(
//                 'assets/images/edit.png',
//               ),
//               onPressed: () {
//                 Navigator.pushNamed(context, '/editmenu');
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMealTypeButtons(List<String> mealTypes) {
//     return Wrap(
//       spacing: 8.0, // Horizontal space between buttons
//       runSpacing: 8.0, // Vertical space between rows if buttons overflow
//       children: mealTypes.map((mealType) {
//         return _buildMealButton(mealType);
//       }).toList(),
//     );
//   }

//   Widget _buildMealButton(String mealType) {
//     bool isSelected = selectedMealType == mealType;
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         minimumSize: Size(20, 40),
//       ),
//       onPressed: () {
//         setState(() {
//           selectedMealType = mealType;
//         });
//       },
//       child: Text(
//         mealType,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildMealItems(String mealType) {
//     if (mealType.isEmpty || !menuData.containsKey(mealType)) {
//       return [];
//     }

//     final items = menuData[mealType] ?? [];
//     return items.map((item) {
//       return Card(
//         child: Container(
//           height: 120, // Fixed height for the card
//           child: ListTile(
//             leading: SizedBox(
//               height: 100, // Adjust the height
//               width: 50,  // Adjust the width
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: Image.network(
//                   item['itemimage'] ?? 'https://th.bing.com/th/id/OIP.xMGhvTUooiLk2wpYCa7R1QHaHa?w=170&h=180&c=7&r=0&o=5&pid=1.7',
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Image.network(
//                       'https://th.bing.com/th/id/OIP.xMGhvTUooiLk2wpYCa7R1QHaHa?w=170&h=180&c=7&r=0&o=5&pid=1.7',
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//             ),
//             title: Text(
//               item['itemname'],
//               maxLines: 1, // Show only one line
//               overflow: TextOverflow.ellipsis, // Truncate the text if it exceeds one line
//             ),
//             subtitle: Text(
//               item['description'],
//               maxLines: 2, // Show only two lines
//               overflow: TextOverflow.ellipsis, // Truncate the text if it exceeds two lines
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.edit),
//                   onPressed: () {
//                     // Handle edit item action
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     // Handle delete item action
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }


// } 


//ctrl+/
// class restaurantProfilePage extends StatefulWidget {
//   final String restaurantId;

//   restaurantProfilePage({required this.restaurantId});

//   @override
//   _restaurantProfilePageState createState() => _restaurantProfilePageState();
// }

// class _restaurantProfilePageState extends State<restaurantProfilePage> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _contactController;
//   late TextEditingController _addressController;
//   String? imageUrl;
//   File? _imageFile;
//   bool _isUpdated = false;
//   String? _editableField;

//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _emailController = TextEditingController();
//     _contactController = TextEditingController();
//     _addressController = TextEditingController();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     var restaurantSnapshot = await FirebaseFirestore.instance
//         .collection('restaurant')
//         .doc(widget.restaurantId)
//         .get();

//     if (restaurantSnapshot.exists) {
//       setData(restaurantSnapshot);
//     }
//   }

//   void setData(DocumentSnapshot snapshot) {
//     var data = snapshot.data() as Map<String, dynamic>;
//     setState(() {
//       _nameController.text = data['Rname'] ?? '';
//       _emailController.text = data['email'] ?? '';
//       _contactController.text = data['contact'] ?? '';
//       _addressController.text = data['address'] ?? '';
//       imageUrl = data['imageUrl'];
//     });
//   }

//   Future<void> updateData() async {
//     var updatedData = {
//       'Rname': _nameController.text.isNotEmpty ? _nameController.text : null,
//       'email': _emailController.text.isNotEmpty ? _emailController.text : null,
//       'contact': _contactController.text.isNotEmpty ? _contactController.text : null,
//       'address': _addressController.text.isNotEmpty ? _addressController.text : null,
//       'imageUrl': imageUrl,
//     };

//     updatedData.removeWhere((key, value) => value == null);

//     await FirebaseFirestore.instance
//         .collection('restaurant')
//         .doc(widget.restaurantId)
//         .update(updatedData);
//   }

//   Future<void> _pickAndUploadImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _isUpdated = true; // Mark that the image has been updated
//       });

//       try {
//         String fileName = '${widget.restaurantId}.jpg';
//         UploadTask uploadTask = FirebaseStorage.instance
//             .ref()
//             .child('restaurant_images/$fileName')
//             .putFile(_imageFile!);

//         TaskSnapshot snapshot = await uploadTask;
//         String downloadUrl = await snapshot.ref.getDownloadURL();

//         // Save image URL to Firestore
//         await FirebaseFirestore.instance
//             .collection('restaurant')
//             .doc(widget.restaurantId)
//             .update({'imageUrl': downloadUrl});

//         setState(() {
//           imageUrl = downloadUrl;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Image Uploaded Successfully")),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to upload image: $e")),
//         );
//       }
//     }
//   }

//   void _checkForUpdates() {
//     if (_isUpdated) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Save Changes'),
//             content: Text('You have unsaved changes. Do you want to save them?'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _isUpdated = false; // Reset the flag
//                   });
//                 },
//                 child: Text('No'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   await updateData();
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _isUpdated = false; // Reset the flag after saving
//                   });
//                 },
//                 child: Text('Yes'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _checkForUpdates();
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/images/MenuVistaicon.png', height: 50, width: 200),
//             ],
//           ),
//           automaticallyImplyLeading: false, // Remove the back icon from the AppBar
//           backgroundColor: Color(0xFF1B3C3D),
//         ),
//         backgroundColor: Color(0xFFEAFDFA),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _imageFile != null
//                         ? FileImage(_imageFile!)
//                         : imageUrl != null
//                             ? NetworkImage(imageUrl!)
//                             : AssetImage('assets/images/profileicon.png') as ImageProvider,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: GestureDetector(
//                       onTap: _pickAndUploadImage,
//                       child: Icon(Icons.add_circle, color: Color(0xFF1B3C3D)),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               buildEditableField('Restaurant Name', 'Enter restaurant name', _nameController, 'Rname'),
//               buildEditableField('Email Address', 'Enter email', _emailController, 'email'),
//               buildEditableField('Contact Number', 'Enter contact', _contactController, 'contact'),
//               buildEditableField('Address', 'Enter address', _addressController, 'address'),
//               if (_isUpdated)
//                 ElevatedButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: Text('Save Changes'),
//                           content: Text('Do you want to save the changes?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 setState(() {
//                                   _isUpdated = false; // Reset the flag
//                                 });
//                               },
//                               child: Text('No'),
//                             ),
//                             TextButton(
//                               onPressed: () async {
//                                 await updateData();
//                                 Navigator.of(context).pop();
//                                 setState(() {
//                                   _isUpdated = false; // Reset the flag after saving
//                                 });
//                               },
//                               child: Text('Yes'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF1B3C3D),
//                   ),
//                   child: Text(
//                     'Update Profile',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: Color(0xFF1B3C3D),
//           child: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               _checkForUpdates();
//               Navigator.pop(context); // Navigate back
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildEditableField(
//       String label,
//       String hintText,
//       TextEditingController controller,
//       String fieldKey,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: buildInputField(label, hintText, controller, fieldKey),
//         ),
//         IconButton(
//           icon: Icon(Icons.edit, color: Color(0xFF1B3C3D)),
//           onPressed: () {
//             setState(() {
//               _editableField = fieldKey; // Set the currently editable field
//               _isUpdated = true; // Mark that changes have been made
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget buildInputField(
//       String label,
//       String hintText,
//       TextEditingController controller,
//       String fieldKey,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         TextField(
//           controller: controller,
//           enabled: _editableField == fieldKey,
//           style: TextStyle(color: Colors.black),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Color(0xFFCECECE),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: Color(0xFF1B3C3D),
//                 width: 2.0,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

//  Widget orderDetailsPage(String orderId) { 
//   return FutureBuilder<DocumentSnapshot>(
//     future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(child: CircularProgressIndicator());
//       }
//       if (snapshot.hasError) {
//         return Center(child: Text("Error: ${snapshot.error}"));
//       }
//       var data = snapshot.data?.data() as Map<String, dynamic>;
//       return Scaffold(
//         appBar: AppBar(
//           title: Text("Order Details"),
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Order ID: ${data['orderId'] ?? 'N/A'}"),
//               Text("Customer ID: ${data['customerId'] ?? 'N/A'}"),
//               Text("Order Type: ${data['orderType'] ?? 'N/A'}"),
//               Text("Time: ${data['orderTime'] ?? 'N/A'}"),
//               if (data['orderType'] == 'Dine In') 
//                 Text("Table No: ${data['tableNo'] ?? 'N/A'}"),
//               Text("Order Items:"),
//               // Directly print 'items' as a String
//               Text(data['items'] ?? 'No items available'),
//               Text("Extra Instruction: ${data['extrainstructions'] ?? 'N/A'}"),
//               Text("Order Status: ${data['orderstatus'] ?? 'N/A'}"),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Cancel action
//                       await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
//                         'orderstatus': 'Cancelled',
//                       });
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: "PR5Gs3rUuEvPK6HvCZcl")),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     child: Text("Cancel"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Done action
//                       await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
//                         'orderstatus': 'Done',
//                       });
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(builder: (context) => OrderListPage(restaurantId: "PR5Gs3rUuEvPK6HvCZcl")),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                     child: Text("Done"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }



// class addItemPage extends StatefulWidget {  
//   final String restaurantId;

//   addItemPage(this.restaurantId);

//   @override
//   _addItemPageState createState() => _addItemPageState();
// }

// class _addItemPageState extends State<addItemPage> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController ingredientController = TextEditingController();
//   TextEditingController customMealTypeController = TextEditingController();
//   TextEditingController singlePriceController = TextEditingController();
//   TextEditingController largePriceController = TextEditingController();
//   TextEditingController mediumPriceController = TextEditingController();
//   TextEditingController smallPriceController = TextEditingController();
  
//   bool isVeg = true;
//   bool hasVariableSizes = false;
//   String selectedMealType = 'snacks';
//   List<String> mealTypes = ['breakfast', 'snacks', 'cool refreshers', 'desserts', 'main course', 'Others'];
//   String itemImage = ""; // Variable to hold the image URL

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Item"),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   // Add image upload action
//                 },
//                 child: Container(
//                   height: 150,
//                   width: double.infinity,
//                   color: Colors.grey[300],
//                   child: Center(
//                     child: Icon(Icons.add_a_photo, size: 50),
//                   ),
//                 ),
//               ),
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Item Name'),
//               ),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(labelText: 'Item Description'),
//               ),
//               TextField(
//                 controller: ingredientController,
//                 decoration: InputDecoration(labelText: 'Ingredient Description'),
//               ),
//               Row(
//                 children: [
//                   Text("Type: "),
//                   Radio(
//                     value: true,
//                     groupValue: isVeg,
//                     onChanged: (value) {
//                       setState(() {
//                         isVeg = value!;
//                       });
//                     },
//                   ),
//                   Text("Veg"),
//                   Radio(
//                     value: false,
//                     groupValue: isVeg,
//                     onChanged: (value) {
//                       setState(() {
//                         isVeg = value!;
//                       });
//                     },
//                   ),
//                   Text("Non-Veg"),
//                 ],
//               ),
//               SizedBox(height: 20),
//               DropdownButton<String>(
//                 value: selectedMealType,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedMealType = newValue!;
//                   });
//                 },
//                 items: mealTypes.map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               if (selectedMealType == 'Others')
//                 TextField(
//                   controller: customMealTypeController,
//                   decoration: InputDecoration(labelText: 'Enter Custom Meal Type'),
//                 ),
//               SwitchListTile(
//                 title: Text("Available in Variable Sizes?"),
//                 value: hasVariableSizes,
//                 onChanged: (bool value) {
//                   setState(() {
//                     hasVariableSizes = value;
//                   });
//                 },
//               ),
//               if (hasVariableSizes) ...[
//                 TextField(
//                   controller: largePriceController,
//                   decoration: InputDecoration(labelText: 'Large Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 TextField(
//                   controller: mediumPriceController,
//                   decoration: InputDecoration(labelText: 'Medium Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 TextField(
//                   controller: smallPriceController,
//                   decoration: InputDecoration(labelText: 'Small Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//               ] else
//                 TextField(
//                   controller: singlePriceController,
//                   decoration: InputDecoration(labelText: 'Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Determine the collection path
//                   String mealTypeToStore = selectedMealType == 'Others'
//                       ? customMealTypeController.text
//                       : selectedMealType;

//                   FirebaseFirestore.instance
//                       .collection('restaurant')
//                       .doc(widget.restaurantId)
//                       .collection('menuItems')
//                       .doc('MealTypes')
//                       .collection(mealTypeToStore)
//                       .add({
//                     'itemname': nameController.text,
//                     'description': descriptionController.text,
//                     'ingredients': ingredientController.text,
//                     'isveg': isVeg,
//                     'view': 'show',
//                     'itemimage': itemImage.isNotEmpty 
//                         ? itemImage 
//                         : "https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg", // Default image URL
//                     if (hasVariableSizes) ...{
//                       'large': double.tryParse(largePriceController.text) ?? 0.0, // Changed to number
//                       'medium': double.tryParse(mediumPriceController.text) ?? 0.0, // Changed to number
//                       'small': double.tryParse(smallPriceController.text) ?? 0.0, // Changed to number
//                     } else
//                       'price': double.tryParse(singlePriceController.text) ?? 0.0, // Keep as number
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 child: Text("Done"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




/*Widget startpage() {
  String restid ="PR5Gs3rUuEvPK6HvCZcl";
}*/

=======
>>>>>>> 3428e1b8d0fcbf1d4ed023a819d86e0a1996b5c8
