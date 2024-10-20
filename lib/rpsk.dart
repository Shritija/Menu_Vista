import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'underconstructionpage.dart';
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
