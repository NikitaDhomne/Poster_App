import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poster_app/screens/posterdetailpage.dart';
import 'package:poster_app/screens/user_login_screen.dart';

class UserHomePage extends StatefulWidget {
  static const routeName = '/userhomepage';
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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
                    .pushReplacementNamed(UserLoginPage.routeName);
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PosterDetailPage(
                          imageUrl: data['imageUrl'],
                          title: data['title'],
                        ),
                      ));
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
                            )),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
