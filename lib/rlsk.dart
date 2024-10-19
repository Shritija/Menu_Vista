import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For managing timer for error message removal
import 'underconstructionpage.dart';
import 'umpsk.dart';

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