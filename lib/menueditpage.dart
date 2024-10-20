import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orderlistpage.dart';
import 'dart:async'; // For managing timer for error message removal
import 'restaurantProfilePage.dart';
import 'additempage.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edititempage.dart';

class MenuEditPage extends StatefulWidget {
  final String Rid;
  MenuEditPage({required this.Rid});

  @override
  _MenuEditPageState createState() => _MenuEditPageState();
}

class _MenuEditPageState extends State<MenuEditPage> {
  bool isVeg = true;
  String selectedMealType = '';
  String searchQuery = '';
  bool isLoading = true; // Added to show a loading state
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

  Future<void> fetchMenuData({bool preserveSelectedMealType = false}) async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final restaurantQuery = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.Rid)
          .get();

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
                    .map((doc) => {
                  'itemId': doc.id,
                  'itemname': doc['itemname'] ?? 'Unknown item', // Handle null itemname
                  'itemimage': (doc['itemimage'] != null && doc['itemimage'].isNotEmpty)
                      ? doc['itemimage']
                      : "https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg", // Handle null or empty itemimage
                  'description': doc['description'] ?? 'No description available', // Handle null description
                  'ingredients': doc['ingredients'] ?? 'No ingredients specified', // Handle null ingredients
                  'isveg': doc['isveg'] ?? false, // Handle null isveg, default to false
                  'small': doc.data().containsKey('small') && doc['small'] != null
                      ? doc['small']
                      : 'N/A', // Handle missing or null small size
                  'medium': doc.data().containsKey('medium') && doc['medium'] != null
                      ? doc['medium']
                      : 'N/A', // Handle missing or null medium size
                  'large': doc.data().containsKey('large') && doc['large'] != null
                      ? doc['large']
                      : 'N/A', // Handle missing or null large size
                  'view': doc['view'] ?? 'deleted', // Handle null view, default to 'hidden'
                })
                    .where((item) {
                  print("Item name: ${item['itemname']}, View: ${item['view']}, Veg: ${item['isveg']}");
                  return isVeg ? item['isveg'] == true : item['isveg'] == false;
                })
                    .where((item) => item['view'] == 'show') // Filter by visible items
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

        // Optionally preserve selected meal type
        // if (!preserveSelectedMealType) {
        //   selectedMealType = mealSelections.entries
        //       .firstWhere((entry) => entry.value, orElse: () => MapEntry('', false))
        //       .key;
        // }
      } else {
        print('No document found with Rid: ${widget.Rid}');
      }
    } catch (e) {
      print('Error fetching menu data: $e');
    } finally {
      setState(() {
        isLoading = false; // Loading finished
      });
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
                    'itemname': doc['itemname'] ?? 'Unknown item', // Add default values
                    'itemimage': (doc['itemimage'] != null && doc['itemimage'].isNotEmpty)
                        ? doc['itemimage']
                        : "https://th.bing.com/th/id/OIP.xMGhvTUooiLk2wpYCa7R1QHaHa?w=170&h=180&c=7&r=0&o=5&pid=1.7",
                    'description': doc['description'] ?? 'No description available',
                    'isveg': doc['isveg'] ?? false,
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
                      .collection('restaurant')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => restaurantProfilePage(documentId: widget.Rid)//documentId: documentId),
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
                      .collection('restaurant')
                      .where('email', isEqualTo: email)
                      .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    String documentId = userSnapshot.docs.first.id;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => OrderHistoryPage(),//documentId: documentId),
                    //   ),
                    // );
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AboutUsPage(),
                //   ),
                // );
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
      body: isLoading ? Center(child: CircularProgressIndicator()) : _buildContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
 
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            TextField(
                  onChanged: (value) {
                    performSearch(value);  // Call the search method
                  },
                  decoration: InputDecoration(
                    hintText: 'Search the item to be edited/deleted....',
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

            // Meal category buttons using Wrap
            _buildMealTypeButtons(
              mealSelections.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
            ),
            SizedBox(height: 10),

            // Veg/Non-Veg Toggle
            Row(
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
                      fetchMenuData(preserveSelectedMealType: true); // Fetch data again based on new selection
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red[300],
                  inactiveTrackColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Display menu items
            ..._buildMealItems(selectedMealType),

            // Add Item Button aligned just above the bottom navigation bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 60.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Color(0xFF1B3C3D), // Dark green color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(100, 40), 
                            // Set width and height (width, height)
                    ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemPage(widget.Rid),
                      ),
                    );
                  },
                  child: Text("Add Item", style: TextStyle(fontFamily: 'Oswald',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
        color: Color(0xFF1B3C3D),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
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
                padding: EdgeInsets.all(1.0),
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/home_white.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderListPage(restaurantId: widget.Rid),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Menu Button
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
                padding: EdgeInsets.all(1.0),
                child: IconButton(
                  iconSize: 20.0, // Same smaller icon size
                  icon: Image.asset(
                    'assets/images/edit.png', // Add your image path here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuEditPage(Rid: widget.Rid),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMealTypeButtons(List<String> mealTypes) {
    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 8.0, // Vertical space between rows if buttons overflow
      children: mealTypes.map((mealType) {
        return _buildMealButton(mealType);
      }).toList(),
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
    print('$items');
    print('$mealType');
    return items.map((item) {
      final String documentId = item['itemId']; // Assuming item contains itemId field
      return Card(
        elevation: 5,
        color: Color(0xFFFFE36C), // Yellow background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Container(
          height: 150, // Fixed height for the card
          padding: EdgeInsets.all(8.0), // Add padding inside the card
          child: Row(
            children: [
              // Image section
              SizedBox(
                height: 120, // Adjust the height
                width: 120, // Adjust the width
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['itemimage'] ?? 'https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Text and button section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['itemname']?? 'Unknown item',
                      maxLines: 1, // Show only one line
                      overflow: TextOverflow.ellipsis, // Truncate the text if it exceeds one line
                      style: TextStyle(
                        fontFamily: 'Oswald', // Use Oswald font
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      item['description'] ?? 'No description available',
                      maxLines: 2, // Show only two lines
                      overflow: TextOverflow.ellipsis, // Truncate the text if it exceeds two lines
                      style: TextStyle(
                        fontFamily: 'Oswald', // Use Oswald font
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        // Edit button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Color(0xFF1B3C3D), // Dark green color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(80, 30), // Set width and height (width, height)
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMenuItemPage(
                                  Rid: widget.Rid, 
                                  mealType: mealType,
                                  itemData: item, 
                                  itemId: documentId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              fontFamily: 'Oswald', // Use Oswald font
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Delete button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            backgroundColor: Colors.red, // Red color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.black),
                            ),
                            minimumSize: Size(80, 30), // Set width and height (width, height)
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('restaurant')
                                  .doc(widget.Rid)
                                  .collection('menuItems')
                                  .doc('MealTypes')
                                  .collection(mealType.toLowerCase())
                                  .doc(item['itemId'])
                                  .update({'view': 'deleted'});

                              // Refresh the menu data
                              fetchMenuData(preserveSelectedMealType: true);
                            } catch (e) {
                              print('Failed to update view field: $e');
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              fontFamily: 'Oswald', // Use Oswald font
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
        ),
      );
    }).toList();
  }
} 