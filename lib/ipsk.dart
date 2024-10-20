import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'underconstructionpage.dart';
import 'cpsk.dart';
import 'rpsk.dart';
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

