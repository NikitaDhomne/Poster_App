import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poster_app/screens/user_login_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Forgot Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.15,
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
              SizedBox(
                height: screenHeight * 0.05,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  auth
                      .sendPasswordResetEmail(email: emailController.text)
                      .then((value) {
                    setState(() {
                      isLoading = false;
                    });
                    _showSnackBar('Password reset email sent successfully');
                    Navigator.of(context)
                        .pushReplacementNamed(UserLoginPage.routeName);
                  }).catchError((error) {
                    setState(() {
                      isLoading = false;
                    });
                    _showSnackBar('An error occurred: $error');
                  });
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
                    'Forgot Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an accout please '),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed(UserLoginPage.routeName);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.indigoAccent),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
