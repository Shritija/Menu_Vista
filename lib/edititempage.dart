import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'menueditpage.dart';
import 'orderlistpage.dart';
import 'restaurantProfilePage.dart';

class EditMenuItemPage extends StatefulWidget {
  final String Rid;
  final String mealType;
  final String itemId;
  final Map<String, dynamic> itemData;

  const EditMenuItemPage({
    required this.Rid,
    required this.mealType,
    required this.itemId,
    required this.itemData,
  });

  @override
  _EditMenuItemPageState createState() => _EditMenuItemPageState();
}

class _EditMenuItemPageState extends State<EditMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  late String _itemName;
  late String _description;
  late String _ingredients;
  late String _imageUrl;
  late String _selectedMealType;
  File? _imageFile;
  bool isVeg = true; // Default to Veg

  @override
  void initState() {
    super.initState();
    _itemName = widget.itemData['itemname'];
    _description = widget.itemData['description'];
    _ingredients = widget.itemData['ingredients'] ?? '';
    _imageUrl = widget.itemData['itemimage'];
    _selectedMealType = widget.mealType;
    isVeg = widget.itemData['isveg'] ?? true; // Set initial veg/non-veg status
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<String> _uploadImageToStorage(File imageFile) async {
    String fileName = '${widget.Rid}_${_selectedMealType}_${widget.itemId}.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child('menuImages/$fileName');
    await storageReference.putFile(imageFile);
    return await storageReference.getDownloadURL();
  }

  Future<void> _updateMenuItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage(_imageFile!);
      }

      try {
        await FirebaseFirestore.instance
            .collection('restaurant')
            .doc(widget.Rid)
            .collection('menuItems')
            .doc('MealTypes')
            .collection(_selectedMealType.toLowerCase())
            .doc(widget.itemId)
            .update({
          'itemname': _itemName,
          'description': _description,
          'ingredients': _ingredients,
          'itemimage': imageUrl,
          'isveg': isVeg,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the MenuEditPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuEditPage(Rid: widget.Rid),
          ),
        );
      } catch (e) {
        print('Failed to update item: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                  children: [
                    _imageFile == null
                      ? Image.network(
                          _imageUrl,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, // Consistent button color
                      ),
                      onPressed: _pickImage,
                      child: Text('Change Image'),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
                SizedBox(height: 16),// Veg/Non-Veg Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVeg ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isVeg = true;
                        });
                      },
                      child: Text('Veg'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isVeg ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isVeg = false;
                        });
                      },
                      child: Text('Non-Veg'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildTextInput('Item Name', _itemName, (value) => _itemName = value),
                _buildTextInput('Description', _description, (value) => _description = value, maxLines: 3),
                _buildTextInput('Ingredients', _ingredients, (value) => _ingredients = value, maxLines: 3),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateMenuItem,
                  child: Text('Update Item'),
                ),
              ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTextInput(String label, String initialValue, Function(String) onSave, {int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        maxLines: maxLines,
        onSaved: (value) => onSave(value ?? ''),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container (
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
}
