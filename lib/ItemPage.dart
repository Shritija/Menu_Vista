import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'RestaurantListPage.dart';
import 'OrderHistoryPage.dart';
import 'AboutUsPage.dart';
import 'CartPage.dart';
import 'ProfilePage.dart';
import 'ReviewPage.dart';



class ItemPage extends StatefulWidget {
  final String restaurantId;
  final String itemId;

  ItemPage({required this.restaurantId, required this.itemId});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  Map<String, dynamic>? itemData;
  String selectedSize = ' ';
  int price = 0;
  String extrainstructions = '';
  String? userId;
  String documentId = ' ';
  List<String> availableSizes = [];
  final List<String> mealTypes = ['breakfast', 'lunch', 'snacks', 'dinner'];
  String email = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
    _fetchUserId();
    if (email.isNotEmpty) {
      fetchDocumentId(); // Call to fetch documentId on widget initialization
    }
  }

  void _fetchItemDetails() async {
    DocumentSnapshot restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(widget.restaurantId)
        .get();

    if (restaurantSnapshot.exists) {
      DocumentSnapshot mealTypesSnapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .doc('MealTypes')
          .get();

      if (mealTypesSnapshot.exists) {
        for (String mealType in mealTypes) {
          CollectionReference mealCollection = FirebaseFirestore.instance
              .collection('restaurant')
              .doc(widget.restaurantId)
              .collection('menuItems')
              .doc('MealTypes')
              .collection(mealType);

          DocumentSnapshot itemSnapshot = await mealCollection
              .doc(widget.itemId)
              .get();

          if (itemSnapshot.exists) {
            setState(() {
              itemData = itemSnapshot.data() as Map<String, dynamic>;

              availableSizes = ['small', 'medium', 'large']
                  .where((size) => itemData?.containsKey(size) ?? false)
                  .toList();

              if (availableSizes.isNotEmpty) {
                selectedSize = availableSizes.contains('medium')
                    ? 'Medium'
                    : _capitalize(availableSizes[0]);

                price = itemData?[selectedSize.toLowerCase()] ?? 0;
              }
            });
            break;
          }
        }
      }
    }
  }
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
  void _fetchUserId() async {
    String email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          userId = userSnapshot.docs.first.id; // Store the user document ID
        });
      } else {
        print('User document not found.');
      }
    } else {
      print('No user is currently logged in.');
    }
  }

  void _updatePrice(String size) {
    setState(() {
      selectedSize = size;
      price = itemData![size.toLowerCase()];
    });
  }

  String _capitalize(String text) {
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    if (itemData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1B1D21),// Set the AppBar color
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // White back arrow
            onPressed: () {
              Navigator.pop(context); // Handle back navigation
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/image_processing20200705-25128-1a0u0wj.gif', // Replace with your image path
                height: 400, // Adjust the height as needed
                width: 400, // Adjust the width as needed
                fit: BoxFit.cover, // Fit image within the box
              ),
              SizedBox(height: 16), // Add space between the image and text
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Oswald', // Use Oswald font
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ],
          ),
        ),
        backgroundColor:Color(0xFF1B1D21), // Set background color to match the app theme
      );
    }

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
              onPressed: () {},
            ),
          ],
        ),

        body: SingleChildScrollView( // Wrap the body in SingleChildScrollView
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image in a rounded rectangle container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  width: 500,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    itemData!['itemimage'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Entire section inside a container with background color 0xFF1B3C3D
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Centered and bold item name with white color
                    Text(
                      itemData!['itemname'],
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),

                    // Size selection buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: availableSizes
                          .map((size) => _sizeOption(_capitalize(size)))
                          .toList(),
                    ),
                    SizedBox(height: 10),

                    // Price display
                    Center(
                      child: Text(
                        'Price: Rs $price',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Centered Ingredients header with larger font
                    Center(
                      child: Text(
                        'Ingredients',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Item description
                    Text(
                      itemData!['ingredients'],
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 20),

                    // Customization and Rating buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xFF1B3C3D), // Dialog box color
                                    title: Text(
                                      'Add Extra Instructions',
                                      style: TextStyle(color: Colors.white), // Title text color
                                    ),
                                    content: TextField(
                                      onChanged: (value) {
                                        extrainstructions = value; // Save input to extrainstructions
                                      },
                                      maxLines: 3, // Text area effect
                                      decoration: InputDecoration(
                                        hintText: 'Type any additional instructions here',
                                        hintStyle: TextStyle(color: Colors.white), // Hint text color
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1), // Text field background
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.black, width: 2), // Focused border color
                                        ),
                                      ),
                                      style: TextStyle(color: Colors.black), // Input text color
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold, // Bold white text
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFFFFDE59), // Button color
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold, // Bold white text
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFFFFDE59), // Button color
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Customize',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
                    SizedBox(height: 20),

                    // Centered and larger "Add to Cart" button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPage(
                                restaurantId: widget.restaurantId,
                                itemId: widget.itemId,
                                userId: userId!,
                                extraInstructions: extrainstructions,
                                selectedSize: selectedSize,
                                price: price,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDE59),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                        ),
                      ),
                    ),
                  ],
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
                      Navigator.pop(context); // Go back to the previous page
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
                          restaurantId: widget.restaurantId,
                          itemId: ' ',      // Include other required parameters as needed
                          selectedSize: ' ',
                          price: 0,
                          extraInstructions: ' ',
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

  Widget _sizeOption(String size) {
    return GestureDetector(
      onTap: () => _updatePrice(size),
      child: Container(
        decoration: BoxDecoration(
          color: selectedSize == size ? Color(0xFFFFDE59) : Color(0xFF1B3C3D),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          size,
          style: TextStyle(
            color: selectedSize == size ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
