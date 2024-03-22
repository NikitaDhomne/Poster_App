import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poster_app/screens/admin_homepage.dart';
import 'package:poster_app/screens/user_login_screen.dart';

import '../widgets/headingtitle_widget.dart';

class AdminLoginPage extends StatefulWidget {
  static const routeName = '/adminlogin';
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool loader = false;

  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  void login() async {
    setState(() {
      loader = true;
    });
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passController.text.toString(),
      );

      final uid = userCredential.user!.uid;

      // Check if user data exists in Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('Admin').doc(uid).get();
      if (!userDoc.exists) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'User data not found');
      }

      Navigator.of(context).pushReplacementNamed(AdminHomePage.routeName);
      setState(() {
        loader = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 250,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'images/warning.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    'Invalid Credentials',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1FB141), // background color
                      foregroundColor: Colors.white, // text color
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  )
                ],
              ),
            ),
          );
        },
      );
      setState(() {
        loader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserLoginPage.routeName);
              },
              child: Text(
                'User',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.indigoAccent,
                    color: Colors.indigoAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.15,
                ),
                HeadingTitleWidget(title: 'Welcome Admin'),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Enter your Email',
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                TextFormField(
                  controller: passController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: hidePassword
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    labelText: 'Password',
                  ),
                  obscureText: hidePassword,
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber,
                    ),
                    height: screenHeight * 0.06,
                    width: screenWidth * 1,
                    alignment: Alignment.center,
                    child: Text(
                      'Sign in',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
