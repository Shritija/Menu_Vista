import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'menueditpage.dart';
import 'orderlistpage.dart';
import 'LoginPage.dart';
import 'restaurantProfilePage.dart';
import 'dart:io';

class AddItemPage extends StatefulWidget {
  final String restaurantId;

  AddItemPage(this.restaurantId);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();
  TextEditingController customMealTypeController = TextEditingController();
  TextEditingController singlePriceController = TextEditingController();
  TextEditingController largePriceController = TextEditingController();
  TextEditingController mediumPriceController = TextEditingController();
  TextEditingController smallPriceController = TextEditingController();

  bool isVeg = true;
  bool hasVariableSizes = false;
  String selectedMealType = 'snacks';
  List<String> mealTypes = ['breakfast', 'snacks', 'lunch', 'dinner'];
  String itemImage = ""; // Variable to hold the image URL

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Ensure that the item name is provided
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter the item name before uploading an image"))
        );
        return;
      }

      // Upload to Firebase Storage with the item name
      final storageRef = FirebaseStorage.instance.ref();
      final itemRef = storageRef.child('items/${nameController.text}.jpg');
      await itemRef.putFile(File(pickedFile.path));

      // Get the download URL
      String downloadUrl = await itemRef.getDownloadURL();
      setState(() {
        itemImage = downloadUrl; // Store the image URL
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage, // Call the image picking method
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: itemImage.isEmpty
                      ? Center(child: Icon(Icons.add_a_photo, size: 50))
                      : Image.network(itemImage, fit: BoxFit.cover), // Display the selected image
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Ex: Butter Chicken',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Item Description',
                  hintText: 'Ex: Creamy, rich, and mildly spiced tomato-based curry with tender chicken pieces, finished with butter and cream.',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: ingredientController,
                decoration: InputDecoration(
                  labelText: 'Item Ingredient',
                  hintText: 'Ex: Chicken, tomato puree, butter, cream, garlic, ginger, spices, and herbs.',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Type: "),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isVeg = true; // Set to Veg
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVeg ? Colors.green : Colors.grey, // Green if selected, grey otherwise
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Veg", style: TextStyle(fontFamily: 'Oswald', color: Colors.black)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isVeg = false; // Set to Non-Veg
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isVeg ? Colors.red : Colors.grey, // Red if selected, grey otherwise
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Non-Veg", style: TextStyle(fontFamily: 'Oswald', color: Colors.black)),
                  ),
                  SizedBox(width: 10),
                  Expanded( // Wrap the Container and DropdownButton in Expanded
                    child: Container(
                      color: Colors.white, // Set the background color to white
                      padding: EdgeInsets.symmetric(horizontal: 8.0), // Add padding for better visual spacing
                      child: DropdownButton<String>(
                        value: selectedMealType,
                        style: TextStyle(color: Colors.black), // Text color inside the dropdown
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMealType = newValue!;
                          });
                        },
                        dropdownColor: Colors.white, // Set the dropdown menu's background color to white
                        items: mealTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true, // Make the DropdownButton expand to the width of the parent container
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: largePriceController,
                decoration: InputDecoration(
                  labelText: 'Large Price',
                  hintText: 'Ex: 200',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: mediumPriceController,
                decoration: InputDecoration(
                  labelText: 'Medium Price',
                  hintText: 'Ex: 150',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: smallPriceController,
                decoration: InputDecoration(
                  labelText: 'Small Price',
                  hintText: 'Ex: 100',
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Determine the collection path
                  String mealTypeToStore = selectedMealType;

                  // Prepare the data map to store in Firestore
                  Map<String, dynamic> dataToStore = {
                    'itemname': nameController.text,
                    'description': descriptionController.text,
                    'ingredients': ingredientController.text,
                    'isveg': isVeg,
                    'view': 'show',
                    'itemimage': itemImage.isNotEmpty
                        ? itemImage
                        : "https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg", // Default image URL
                    'imageurl': itemImage, // Save the image URL in Firestore
                  };

                  FirebaseFirestore.instance
                      .collection('restaurant')
                      .doc(widget.restaurantId)
                      .collection('menuItems')
                      .doc('MealTypes')  // The parent document containing meal types
                      .collection(selectedMealType)  // Subcollection for the selected meal type
                      .doc(nameController.text)  // Document name will be the item name
                      .set(dataToStore)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Item added to $selectedMealType successfully!")),
                    );
                    Navigator.pop(context);
                  })
                      .catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add item: $error")),
                    );
                  });
                  Navigator.pop(context);
                },
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
