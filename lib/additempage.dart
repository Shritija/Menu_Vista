import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addItemPage extends StatefulWidget {  
  final String restaurantId;

  addItemPage(this.restaurantId);

  @override
  _addItemPageState createState() => _addItemPageState();
}

class _addItemPageState extends State<addItemPage> {
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
  List<String> mealTypes = ['breakfast', 'snacks', 'cool refreshers', 'desserts', 'main course', 'Others'];
  String itemImage = ""; // Variable to hold the image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Add image upload action
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Item Description'),
              ),
              TextField(
                controller: ingredientController,
                decoration: InputDecoration(labelText: 'Ingredient Description'),
              ),
              Row(
                children: [
                  Text("Type: "),
                  Radio(
                    value: true,
                    groupValue: isVeg,
                    onChanged: (value) {
                      setState(() {
                        isVeg = value!;
                      });
                    },
                  ),
                  Text("Veg"),
                  Radio(
                    value: false,
                    groupValue: isVeg,
                    onChanged: (value) {
                      setState(() {
                        isVeg = value!;
                      });
                    },
                  ),
                  Text("Non-Veg"),
                ],
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedMealType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMealType = newValue!;
                  });
                },
                items: mealTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (selectedMealType == 'Others')
                TextField(
                  controller: customMealTypeController,
                  decoration: InputDecoration(labelText: 'Enter Custom Meal Type'),
                ),
              SwitchListTile(
                title: Text("Available in Variable Sizes?"),
                value: hasVariableSizes,
                onChanged: (bool value) {
                  setState(() {
                    hasVariableSizes = value;
                  });
                },
              ),
              if (hasVariableSizes) ...[
                TextField(
                  controller: largePriceController,
                  decoration: InputDecoration(labelText: 'Large Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: mediumPriceController,
                  decoration: InputDecoration(labelText: 'Medium Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: smallPriceController,
                  decoration: InputDecoration(labelText: 'Small Price'),
                  keyboardType: TextInputType.number,
                ),
              ] else
                TextField(
                  controller: singlePriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Determine the collection path
                  String mealTypeToStore = selectedMealType == 'Others'
                      ? customMealTypeController.text
                      : selectedMealType;

                  FirebaseFirestore.instance
                      .collection('restaurant')
                      .doc(widget.restaurantId)
                      .collection('menuItems')
                      .doc('MealTypes')
                      .collection(mealTypeToStore)
                      .add({
                    'itemname': nameController.text,
                    'description': descriptionController.text,
                    'ingredients': ingredientController.text,
                    'isveg': isVeg,
                    'view': 'show',
                    'itemimage': itemImage.isNotEmpty 
                        ? itemImage 
                        : "https://static.vecteezy.com/system/resources/previews/022/014/063/original/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg", // Default image URL
                    if (hasVariableSizes) ...{
                      'large': double.tryParse(largePriceController.text) ?? 0.0, // Changed to number
                      'medium': double.tryParse(mediumPriceController.text) ?? 0.0, // Changed to number
                      'small': double.tryParse(smallPriceController.text) ?? 0.0, // Changed to number
                    } else
                      'price': double.tryParse(singlePriceController.text) ?? 0.0, // Keep as number
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}