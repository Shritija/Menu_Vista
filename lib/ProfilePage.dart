import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';  // Firebase Storage import


class ProfilePage extends StatefulWidget {
  final String documentId;

  ProfilePage({required this.documentId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  String? _imageUrl;
  File? _imageFile;

  final picker = ImagePicker();
  bool _isUpdated = false;
  String? _editableField;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _genderController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    fetchData();
  }

  Future<void> fetchData() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .get();
    var restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc(widget.documentId)
        .get();

    if (userSnapshot.exists) {
      setData(userSnapshot);
    } else if (restaurantSnapshot.exists) {
      setData(restaurantSnapshot);
    }

    // Fetch profile image from Firebase Storage
    _imageUrl = await getImageUrlFromStorage();
    setState(() {});  // Update the UI with the fetched image
  }

  Future<String?> getImageUrlFromStorage() async {
    try {
      // Use the documentId as the folder name and fetch the image
      String filePath = 'profileImages/${widget.documentId}/profile.png';
      FirebaseStorage storage = FirebaseStorage.instance;

      // Get the download URL of the profile image
      String downloadUrl = await storage.ref(filePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to fetch image from storage: $e');
      return null;
    }
  }

  void setData(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _genderController.text = data['gender'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _addressController.text = data['address'] ?? '';
      // Profile image URL will be fetched separately from Firebase Storage
    });
  }

  Future<void> updateData() async {
    var updatedData = {
      'name': _nameController.text.isNotEmpty ? _nameController.text : null,
      'email': _emailController.text.isNotEmpty ? _emailController.text : null,
      'gender': _genderController.text.isNotEmpty ? _genderController.text : null,
      'contact': _contactController.text.isNotEmpty ? _contactController.text : null,
      'address': _addressController.text.isNotEmpty ? _addressController.text : null,
      'profileImage': _imageUrl,
    };

    updatedData.removeWhere((key, value) => value == null);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .update(updatedData);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUpdated = true;  // Mark that the image has been updated
      });

      // Upload the image and get the download URL
      _imageUrl = await uploadImageToFirestore(_imageFile!);
    }
  }

  Future<String> uploadImageToFirestore(File imageFile) async {
    try {
      // Use the user's documentId as the folder name
      String filePath = 'profileImages/${widget.documentId}/profile.png';
      FirebaseStorage storage = FirebaseStorage.instance;

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storage.ref(filePath).putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');  // Debug log for failure
      return '';
    }
  }

  void _checkForUpdates() {
    if (_isUpdated) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Save Changes'),
            content: Text('You have unsaved changes. Do you want to save them?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isUpdated = false; // Reset the flag
                  });
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await updateData();
                  Navigator.of(context).pop();
                  setState(() {
                    _isUpdated = false; // Reset the flag after saving
                  });
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _checkForUpdates();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/MenuVistaicon.png', height: 50, width: 200),
            ],
          ),
          automaticallyImplyLeading: false,  // Remove the back icon from the AppBar
          backgroundColor: Color(0xFF1B3C3D),
        ),
        backgroundColor: Color(0xFFEAFDFA),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/images/profileicon.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Icon(Icons.add_circle, color: Color(0xFF1B3C3D)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              buildEditableField('Name', 'Enter your name', _nameController, 'name'),
              buildEditableField('Email Address', 'Enter your email', _emailController, 'email'),
              buildEditableField('Gender', 'Enter your gender', _genderController, 'gender'),
              buildEditableField('Contact Number', 'Enter your contact', _contactController, 'contact'),
              buildEditableField('Address', 'Enter your address', _addressController, 'address'),
              if (_isUpdated)  // Show the Update Profile button if changes are made
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Save Changes'),
                          content: Text('Do you want to save the changes?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _isUpdated = false; // Reset the flag
                                });
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await updateData();
                                Navigator.of(context).pop();
                                setState(() {
                                  _isUpdated = false; // Reset the flag after saving
                                });
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3C3D),
                  ),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color(0xFF1B3C3D),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _checkForUpdates();
              Navigator.pop(context);  // Navigate back
            },
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(
      String label,
      String hintText,
      TextEditingController controller,
      String fieldKey, // Added parameter to identify the field
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: buildInputField(label, hintText, controller, fieldKey),
        ),
        IconButton(
          icon: Icon(
            Icons.edit,
            color: _editableField == fieldKey ? Color(0xFF1B3C3D) : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _editableField = _editableField == fieldKey ? null : fieldKey; // Toggle editable state
            });
          },
        ),
      ],
    );
  }

  Widget buildInputField(
      String label,
      String hintText,
      TextEditingController controller,
      String fieldKey, // Added parameter to identify the field
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _editableField == fieldKey, // Only allow editing if the field is in editable state
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            suffixIcon: _editableField == fieldKey
                ? IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setState(() {
                  _editableField = null; // Save and exit editable state
                  _isUpdated = true; // Mark that the data has been updated
                });
              },
            )
                : null,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
