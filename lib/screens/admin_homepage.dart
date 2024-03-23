import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poster_app/screens/admin_login_screen.dart';

class AdminHomePage extends StatefulWidget {
  static const routeName = '/adminhomepage';
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool backButtonPressed = false;
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;
    return WillPopScope(
      onWillPop: () async {
        if (!backButtonPressed) {
          setState(() {
            backButtonPressed = true;
          });
          bool exit = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Exit App'),
                content: Text('Do you really want to exit?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Stay on the page
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Exit the app
                    },
                    child: Text('Exit'),
                  ),
                ],
              );
            },
          );
          if (exit == true) {
            return true; // Exit the app
          } else {
            setState(() {
              backButtonPressed = false;
            });
            return false; // Stay on the page
          }
        }
        return false; // Already handled, stay on the page
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text('Poster App'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // Add your logout logic here
                FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushReplacementNamed(AdminLoginPage.routeName);
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('posters').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final posters = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: screenWidth * 0.03,
                    mainAxisSpacing: screenHeight * 0.02,
                    mainAxisExtent: screenHeight * 0.4),
                itemCount: posters.length,
                itemBuilder: (BuildContext context, int index) {
                  final data = posters[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      _showUpdateDialog(context, posters[index]);
                    },
                    child: Hero(
                      tag: data['imageUrl'],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Colors.white54,
                          height: screenHeight * 0.8,
                          width: screenWidth * 0.5,
                          child: Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showImageSelectionDialog(context);
          },
          tooltip: 'Add Poster',
          child: const Icon(Icons.add),
          backgroundColor: Colors.amber, // Specify your desired color here
          shape: CircleBorder(),
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(
      BuildContext context, QueryDocumentSnapshot data) async {
    final picker = ImagePicker();
    final titleController = TextEditingController(text: data['title']);
    final descriptionController =
        TextEditingController(text: data['description']);
    PickedFile? pickedImage;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Update Poster"),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel_sharp,
                        size: 30,
                      )),
                ],
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Title',
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Description',
                      ),
                      maxLines: null, // Allows multiline input
                    ),
                    SizedBox(height: 20),
                    pickedImage != null
                        ? Image.file(File(pickedImage!.path))
                        : Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            pickedImage = PickedFile(image.path);
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.amber), // Change the color here
                      ),
                      child: Text(
                        'Select Image',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    // Delete document from Firestore based on its UID
                    await FirebaseFirestore.instance
                        .collection('posters')
                        .doc(data.id)
                        .delete();
                    Navigator.of(context).pop(); // Close dialog after deletion
                  },
                  child: Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (pickedImage != null) {
                      // Upload image to Firebase Storage
                      firebase_storage.Reference ref =
                          firebase_storage.FirebaseStorage.instance.ref().child(
                              'images/${DateTime.now().millisecondsSinceEpoch}.jpg');
                      await ref.putFile(File(pickedImage!.path));

                      // Get download URL
                      String imageUrl = await ref.getDownloadURL();

                      // Update data in Firestore
                      await FirebaseFirestore.instance
                          .collection('posters')
                          .doc(data.id)
                          .update({
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'imageUrl': imageUrl,
                      });
                    } else {
                      // Update data in Firestore without changing the image
                      await FirebaseFirestore.instance
                          .collection('posters')
                          .doc(data.id)
                          .update({
                        'title': titleController.text,
                        'description': descriptionController.text,
                      });
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showImageSelectionDialog(BuildContext context) async {
    final picker = ImagePicker();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    PickedFile? pickedImage;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add Poster"),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel_sharp,
                        size: 30,
                      )),
                ],
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Title',
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Description',
                      ),
                      maxLines: null, // Allows multiline input
                    ),
                    SizedBox(height: 20),
                    pickedImage != null
                        ? Image.file(File(pickedImage!.path))
                        : Container(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            pickedImage = PickedFile(image.path);
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.amber), // Change the color here
                      ),
                      child: Text(
                        'Select Image',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if (pickedImage != null) {
                      Navigator.of(context).pop();
                      // Upload image to Firebase Storage
                      firebase_storage.Reference ref =
                          firebase_storage.FirebaseStorage.instance.ref().child(
                              'images/${DateTime.now().millisecondsSinceEpoch}.jpg');
                      await ref.putFile(File(pickedImage!.path));

                      // Get download URL
                      String imageUrl = await ref.getDownloadURL();

                      // Save data to Firestore
                      FirebaseFirestore.instance.collection('posters').add({
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'imageUrl': imageUrl,
                      });
                    } else {
                      // Show error message if no image selected
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please select an image.'),
                      ));
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
