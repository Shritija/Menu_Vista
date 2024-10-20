import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'assets/images/MenuVistaicon.png',
                height: 40, // Reduced height to fit smaller screens
                width: 160,  // Adjusted width accordingly
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Color(0xFF1B3C3D),
      ),
      backgroundColor: Color(0xFFEAFCFA),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly distribute space
          children: [
            // Creator card section
            Expanded(child: buildCreatorCard(context)), // Using Expanded for flexibility
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1B3C3D),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);  // Go back to the previous page
          },
        ),
      ),
    );
  }

  // Widget to build the creator card
  Widget buildCreatorCard(BuildContext context) {
    return Column(
      children: [
        buildPersonInfo('Sainand Kundaikar', 'Goa College of Engineering', 'Innovate and Inspire'),
        buildPersonInfo('Saish Chodankar', 'Goa College of Engineering', 'Learn and Lead'),
        buildPersonInfo('Shritija Sawant', 'Goa College of Engineering', 'Empower through Knowledge'),
      ],
    );
  }

  // Widget to build person info
  Widget buildPersonInfo(String name, String college, String motto) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1B3C3D), // Background color
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.0), // Reduced padding for compactness
          child: FittedBox( // FittedBox to scale text to fit
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: $name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Reduced font size
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'College: $college',
                  style: TextStyle(
                    fontSize: 14, // Reduced font size
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Motto: $motto',
                  style: TextStyle(
                    fontSize: 14, // Reduced font size
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}