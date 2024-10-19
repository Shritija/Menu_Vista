import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'LoginPage.dart';
import 'RestaurantListPage.dart';
import 'OrderHistoryPage.dart';
import 'AboutUsPage.dart';
import 'ProfilePage.dart';
import 'CartPage.dart';


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
  String documentId = ' ';
  String email = FirebaseAuth.instance.currentUser?.email ?? '';
  final List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snacks'];

  final TextEditingController _reviewController = TextEditingController();
  int _tempRating = 0; // Temporary rating before submission.

  @override
  void initState() {
    super.initState();
    _calculateAverageRating();
    _fetchUsername();
    if (email.isNotEmpty) {
      fetchDocumentId(); // Call to fetch documentId on widget initialization
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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

  Future<Map<String, dynamic>?> _fetchMenuItem() async {
    for (String mealType in mealTypes) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .doc('MealTypes')
          .collection(mealType)
          .doc(widget.itemId)
          .get();

      if (snapshot.exists) {
        return snapshot.data(); // Return the data if found
      }
    }
    return null; // Return null if no document found in any subcollection
  }

  void _submitReview() {
    String newReviewText = _reviewController.text.trim();
    int newRating = _tempRating;

    if (newReviewText.isNotEmpty && newRating > 0) {
      // Create a new review document with a unique ID
      FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.itemId)
          .collection('userreviews')
          .add({
        'username': username, // Use the dynamically fetched username
        'review': newReviewText,
        'rating': newRating,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        // Successfully added review
        setState(() {
          reviewText = '';
          rating = 0;
          averageRating = (averageRating * (averageRating == 0.0 ? 1 : averageRating)) + newRating;
        });

        _reviewController.clear();
        _tempRating = 0;

        // Recalculate average rating after submitting the review.
        _calculateAverageRating();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you for your review!')),
        );
      }).catchError((error) {
        // Handle any errors that occur during submission
        print("Failed to add review: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review. Please try again.')),
        );
      });
    } else {
      // Show a message prompting the user to enter a review and rating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a rating and review before submitting.')),
      );
    }
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

            Timestamp timestamp = review['timestamp'] ?? Timestamp.now();
            DateTime date = timestamp.toDate();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display username in bold and white color, taking full width
                    Text(
                      review['username'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4), // Slight space between the username and stars

                    // Display star rating directly under the username
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      )),
                    ),

                    SizedBox(height: 8), // Slight space between stars and review

                    // Display the review text in white color
                    Text(
                      review['review'],
                      style: TextStyle(color: Colors.white),
                    ),

                    SizedBox(height: 8), // Slight space between review and the date

                    // Display the date in bold and white color
                    Text(
                      "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStarSelection() {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            _tempRating = index + 1;
            setState(() {}); // Only update the star selection
          },
          child: Icon(
            index < _tempRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
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
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchMenuItem(), // Call the custom future method
          builder: (context, snapshot) {
            // Show a loading spinner while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Check if there's an error or no data
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('Item not found.'));
            }

            // Extract the data from the snapshot
            var item = snapshot.data;

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
                        Image.network(
                          item['itemimage'], // Fetch image from 'itemimage' field
                          fit: BoxFit.cover,
                          width: double.infinity, // Fit the image to the full width of the screen.
                        ),
                        SizedBox(height: 5),
                        Text(item['itemname'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(item['description'], style: TextStyle(fontSize: 14)),
                        SizedBox(height: 5),
                        // Display the average rating as stars
                        Row(
                          children: [
                            Text('Average Rating: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                            SizedBox(width: 5),
                            Text(averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text('Customer Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Your Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      _buildStarSelection(),
                      SizedBox(height: 8),
                      Container(
                        color: Colors.white, // Change background color to white
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 3, // Allow up to 3 lines
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Write a review',
                          ),
                          // No onChanged with setState
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _submitReview,
                        child: Text('Submit Review', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDE59),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80), // Adjust padding to reduce size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Color(0xFF1B3C3D), width: 3),
                          minimumSize: Size(330,50), // Set a minimum size to control the button's size
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          },
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
}