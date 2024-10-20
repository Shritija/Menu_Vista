import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'MenuPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'LoginPage.dart';
import 'OrderHistoryPage.dart';
import 'MenuPage.dart';
import 'ProfilePage.dart';
import 'AboutUsPage.dart';

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
  String? userEmail;
  String? userDocumentId;
  List<String> favoriteRestaurantIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }


  // Function to load user favorites from Firestore
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's email
      userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        // Query the user's document based on the email
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Get the user's document ID
          userDocumentId = userSnapshot.docs.first.id;

          // Fetch the user's favorite restaurants from the document
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocumentId)
              .get();

          if (userDoc.exists) {
            // Get the list of favorite restaurant IDs
            favoriteRestaurantIds = List<String>.from(userDoc['favorites'] ?? []);

            // Fetch the favorite restaurants from the restaurant collection
            if (favoriteRestaurantIds.isNotEmpty) {
              QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
                  .collection('restaurant')
                  .where(FieldPath.documentId, whereIn: favoriteRestaurantIds)
                  .get();

              List<Map<String, dynamic>> favorites = favoriteSnapshot.docs.map((doc) {
                return {
                  'Rid': doc.id,
                  'name': doc['Rname'],
                  'address': doc['address'],
                  'isFavorite': true, // Mark as favorite
                };
              }).toList();

              setState(() {
                _favorites = favorites;
                // Display favorites immediately below the search bar
                _restaurants = _favorites; // Set the restaurants to favorites
              });
            } else {
              // If no favorites, ensure the list is empty
              setState(() {
                _favorites = [];
                _restaurants = [];
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          'Rid': doc.id,
          'name': doc['Rname'],
          'address': doc['address'],
          'isFavorite': favoriteRestaurantIds.contains(doc.id), // Check if it's a favorite
        };
      }).toList();

      _originalRestaurants = List<Map<String, dynamic>>.from(restaurants);

      restaurants.removeWhere((r) => _favorites.any((fav) => fav['Rid'] == r['Rid']));
      List<Map<String, dynamic>> combinedList = _favorites + restaurants;

      setState(() {
        _restaurants = combinedList;
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
  void toggleFavorite(Map<String, dynamic> restaurant) async {
    setState(() {
      restaurant['isFavorite'] = !restaurant['isFavorite'];
    });

    try {
      if (restaurant['isFavorite']) {
        // Add to favorites
        setState(() {
          _favorites.add(restaurant);
          _restaurants.remove(restaurant);
          _restaurants.insert(0, restaurant); // Add to the top
        });
        favoriteRestaurantIds.add(restaurant['Rid']);
      } else {
        // Remove from favorites
        setState(() {
          _favorites.removeWhere((fav) => fav['Rid'] == restaurant['Rid']);
          _restaurants.remove(restaurant);
        });
        favoriteRestaurantIds.remove(restaurant['Rid']);
      }

      // Update the user's favorites in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocumentId)
          .update({'favorites': favoriteRestaurantIds});
    } catch (e) {
      print('Error updating favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFCFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1B3C3D),
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.settings, color: Colors.white),
          color: Color(0xFFEAFCFA),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'order_history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Order History',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'about_us',
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'About Us',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: (String value) async {
    String email = FirebaseAuth.instance.currentUser?.email ?? '';

    if (value == 'profile') {
    if (email.isNotEmpty) {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
    String documentId = userSnapshot.docs.first.id;
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ProfilePage(documentId: documentId),
    ),
    );
    } else {
    print('User document not found.');
    }
    } else {
    print('No user is currently logged in.');
    }
    } else if (value == 'order_history') {
    if (email.isNotEmpty) {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
    String documentId = userSnapshot.docs.first.id;
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => OrderHistoryPage(documentId: documentId),
    ),
    );
    } else {
    print('User document not found.');
    }
    }
    } else if (value == 'logout') {
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    (route) => false,
    );
    } else if (value == 'about_us') {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => AboutUsPage(),
    ),
    );
    }
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
              // No action currently
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isNotEmpty) {
                  searchRestaurants(value);
                } else {
                  // Reset the restaurant list to show all favorites if no search query
                  setState(() {
                    _restaurants = _favorites; // Show only favorites when search is cleared
                    _searchPerformed = false;
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
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _restaurants.isEmpty && _searchPerformed
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/notfound.png',
                      height: 220,
                      width: 220,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Restaurant Not Found',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  children: _restaurants.map((restaurant) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPage(
                              Rid: restaurant['Rid'],
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  toggleFavorite(restaurant);
                                },
                              ),
                            ],
                          ),
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
    );
  }
}

