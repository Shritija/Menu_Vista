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
          'Rid': doc.id, // Adding Rid
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the vertical padding as needed
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