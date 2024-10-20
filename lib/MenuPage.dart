import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'OrderHistoryPage.dart';
import 'LoginPage.dart';
import 'RestaurantListPage.dart';
import 'ProfilePage.dart';
import 'AboutUsPage.dart';
import 'ItemPage.dart';
import 'CartPage.dart';

class MenuPage extends StatefulWidget {
  final String Rid;

  MenuPage({required this.Rid});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isVeg = true;
  String vegStatus = 'Veg';
  String selectedMealType = '';
  String searchQuery = '';
  String documentId='';
  String email = FirebaseAuth.instance.currentUser?.email ?? '';
  Map<String, bool> mealSelections = {
    'Breakfast': false,
    'Lunch': false,
    'Snacks': false,
    'Dinner': false,
  };
  Map<String, List<Map<String, dynamic>>> menuData = {};
  Map<String, String> selectedSizes = {};  // Track selected size per item
  Map<String, num> selectedPrices = {};    // Track selected price per item
  Future<void> fetchDocumentId() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          documentId = userSnapshot.docs.first.id;
        });
      }
    } catch (error) {
      print('Error fetching documentId: $error');
    }
  }
  Future<void> checkAndCreateCartIfNotExists() async {
    // Get the current user's email
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      print('No user is logged in.');
      return;
    }

    String userEmail = user.email!;

    // Get the user's document ID from the 'users' collection using the email field
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      print('User with email $userEmail not found in the users collection.');
      return;
    }

    String userDocId = userSnapshot.docs.first.id;
    DocumentSnapshot cartDoc = await FirebaseFirestore.instance
        .collection('cart')
        .doc(userDocId)
        .get();

    if (!cartDoc.exists) {
      await FirebaseFirestore.instance.collection('cart').doc(userDocId).set({
      });
      print('Cart created for user with document ID: $userDocId');
    } else {
      print('Cart already exists for user with document ID: $userDocId');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMenuData();
    checkAndCreateCartIfNotExists();
    if (email.isNotEmpty) {
      fetchDocumentId(); // Call to fetch documentId on widget initialization
    }
  }

  Future<void> fetchMenuData() async {
    try {
      final restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.Rid) // Use the passed Rid
          .get();

      print('Fetching restaurant with Rid: ${widget.Rid}');
      if (restaurantQuery.exists) {
        final mealTypesRef = restaurantQuery.reference.collection('menuItems').doc('MealTypes');

        final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

        for (var mealType in mealTypes) {
          try {
            final mealCollectionSnapshot = await mealTypesRef.collection(mealType).get();
            if (mealCollectionSnapshot.docs.isNotEmpty) {
              setState(() {
                mealSelections[capitalize(mealType)] = true;
                menuData[capitalize(mealType)] = mealCollectionSnapshot.docs
                    .map((doc) {
                  Map<String, dynamic> itemData = {
                    'itemname': doc['itemname'],
                    'itemimage': doc['itemimage'],
                    'description': doc['description'],
                    'isveg': doc['isveg'],
                    'documentId': doc.id, 
                    'view': doc['view'] ?? 'deleted',// Store documentId for navigation
                  };

                  // Check and include only available sizes
                  if (doc.data().containsKey('small') && doc['small'] != null) {
                    itemData['small'] = doc['small'];
                  }
                  if (doc.data().containsKey('medium') && doc['medium'] != null) {
                    itemData['medium'] = doc['medium'];
                  }
                  if (doc.data().containsKey('large') && doc['large'] != null) {
                    itemData['large'] = doc['large'];
                  }

                  return itemData;
                })
                    .where((item) => isVeg ? item['isveg'] == true : item['isveg'] == false)
                    .where((item) => item['view'] == 'show') 
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
  Future<void> performSearch(String query) async {
    setState(() {
      searchQuery = query;
    });

    try {
      final restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.Rid)  // Ensure we search in the correct restaurant
          .get();

      print('Searching in restaurant with Rid: ${widget.Rid}');
      if (restaurantQuery.exists) {
        final mealTypesRef = restaurantQuery.reference.collection('menuItems').doc('MealTypes');

        // Clear current search results
        menuData = {};

        // List of meal types to search
        final mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];

        for (var mealType in mealTypes) {
          try {
            final mealCollectionSnapshot = await mealTypesRef.collection(mealType)
                .where('itemname', isGreaterThanOrEqualTo: query)
                .where('itemname', isLessThanOrEqualTo: query + '\uf8ff')  // Perform search
                .get();

            if (mealCollectionSnapshot.docs.isNotEmpty) {
              setState(() {
                mealSelections[capitalize(mealType)] = true;
                menuData[capitalize(mealType)] = mealCollectionSnapshot.docs.map((doc) {
                  Map<String, dynamic> itemData = {
                    'itemname': doc['itemname'],
                    'itemimage': doc['itemimage'],
                    'description': doc['description'],
                    'isveg': doc['isveg'],
                    'documentId': doc.id,
                  };
                  if (doc.data().containsKey('small') && doc['small'] != null) {
                    itemData['small'] = doc['small'];
                  }
                  if (doc.data().containsKey('medium') && doc['medium'] != null) {
                    itemData['medium'] = doc['medium'];
                  }
                  if (doc.data().containsKey('large') && doc['large'] != null) {
                    itemData['large'] = doc['large'];
                  }

                  return itemData;
                }).toList();
              });
            } else {
              setState(() {
                menuData[capitalize(mealType)] = [];
              });
            }
          } catch (e) {
            print('Error searching $mealType collection: $e');
          }
        }
      }
    } catch (e) {
      print('Error searching for items: $e');
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
                  onChanged: (value) {
                    performSearch(value);  // Call the search method
                  },
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.black, // Set the focused border color to black
                        width: 2.0,
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
                      .map((entry) => Row(
                    children: [
                      _buildMealButton(entry.key),
                      SizedBox(width: 1), // Add spacing between buttons
                    ],
                  )
                  ).toList(),
                ),

                SizedBox(height: 10),

                // Veg/Non-Veg Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligns everything to the left
                  children: [
                    Column(
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
                        SizedBox(height: 8), // Add some space between the text and the switch
                        Switch(
                          value: isVeg,
                          onChanged: (value) {
                            setState(() {
                              isVeg = value;
                              vegStatus = isVeg ? 'Veg' : 'Non-Veg';
                              fetchMenuData();// Fetch data again based on new selection
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red[300],
                          inactiveTrackColor: Colors.red,
                        ),
                      ],
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
              // Back Button with Navigator.push and MaterialPageRoute
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1B3C3D),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Colors.black12, // Border color
                      width: 1,          // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(5, 5),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(5.0),
                  child: IconButton(
                    iconSize: 20.0,
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RestaurantListPage()), // Replace with the correct page
                      );
                    },
                  ),
                ),
              ),

              // Shopping Cart Button with Navigator.push and MaterialPageRoute
              Expanded(
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
                  padding: EdgeInsets.all(10.0),
                  child: IconButton(
                    iconSize: 30.0,
                    icon: Image.asset('assets/images/shoppingcarticon.png'),
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage(
                          userId: documentId,           // Pass the documentId as userId
                          restaurantId: widget.Rid,
                          itemId: null,      // Include other required parameters as needed
                          selectedSize: null,
                          price: 0,
                          extraInstructions: null,
                        )), // Replace with the correct page
                      );
                    },
                   ),
                ),
              ),
            ],
          ),
        )



    );
  }

  Widget _buildMealButton(String mealType) {
    bool isSelected = selectedMealType == mealType;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        minimumSize: Size(20, 40),
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
        mediumPrice: item['medium'],
        largePrice: item['large'],
        documentId: item['documentId'],
      );
    }).toList();
  }

  Widget _buildMenuItem({
    required String imageUrl,
    required String name,
    required String description,
    required num? smallPrice,
    required num? mediumPrice,
    required num? largePrice,
    required String documentId,
  }) {
    // Truncate the description if it's too long
    String truncatedDescription = description.length > 50
        ? description.substring(0, 50) + '...'
        : description;

    return GestureDetector(
      onTap: () {
        // Navigate to the ItemPage and pass Rid and documentId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemPage(
              restaurantId: widget.Rid, // Use the Rid from the current MenuPage
              itemId: documentId,       // Pass the documentId of the selected item
            ),
          ),
        );
      },
      child: Container(
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
            Row(
              children: [
                SizedBox(
                  height: 100,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl, // Use the imageUrl passed from the menu item
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        truncatedDescription, // Display truncated description
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (smallPrice != null) _buildSizeButton('Small', smallPrice, documentId),
                              if (mediumPrice != null) _buildSizeButton('Medium', mediumPrice, documentId),
                              if (largePrice != null) _buildSizeButton('Large', largePrice, documentId),
                            ],
                          ),
                          // Display the selected price for this specific item
                          if (selectedPrices.containsKey(documentId))
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF1B3C3D),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Rs ${selectedPrices[documentId]}',
                                style: TextStyle(
                                  fontFamily: 'Oswald',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
    );
  }


  Widget _buildSizeButton(String label, num price, String documentId) {
    bool isSelected = selectedSizes[documentId] == label; // Check if this size is selected for this item

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSizes[documentId] = label;  // Update selected size for this specific item
          selectedPrices[documentId] = price; // Update the price for this specific item
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3CC2C6) : Color(0xFF1B3C3D), // Change color based on selection
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontFamily: 'Oswald', // Use bold Oswald font
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
      ),
    );
  }
}