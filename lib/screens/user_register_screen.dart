import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poster_app/providers/user_setup.dart';
import 'package:poster_app/screens/user_login_screen.dart';

import '../widgets/headingtitle_widget.dart';

class UserRegister extends StatefulWidget {
  static const routeName = '/userregister';
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final _form = GlobalKey<FormState>();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    confirmpassword.dispose();
  }

  void signUp() {
    setState(() {
      loading = true;
    });
    // If the form is valid, display a Snackbar.
    _auth
        .createUserWithEmailAndPassword(
            email: email.text.toString(), password: password.text.toString())
        .then((value) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 300,
                width: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            'images/dialog_success.png',
                            fit: BoxFit.cover,
                          )),
                      Text(
                        "Account Created Successfully",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(UserLoginPage.routeName);
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
                    ]),
              ),
            );
          });

      setState(() {
        loading = false;
      });
      userSetUp(username.text, email.text, password.text);
    }).catchError((e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 300,
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
                          )),
                      Text(
                        e.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
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
                    ]),
              ),
            );
          });
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeadingTitleWidget(title: 'Sign Up For Poster App'),
                  SizedBox(
                    height: screenHeight * 0.04,
                  ),
                  TextFormField(
                    controller: username,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Username',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '*Username is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.alternate_email),
                      labelText: 'Email',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Email is required.';
                      }
                      if (!value.contains('@')) {
                        return '* Must contain @.';
                      }
                      if (!value.endsWith('.com') &&
                          !value.endsWith('.in') &&
                          !value.endsWith('.co') &&
                          !value.endsWith('.gov') &&
                          !value.endsWith('.edu')) {
                        return '* Enter valid email id';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Password is required';
                      }
                      if (value.length < 6) {
                        return '* Password should have atleast 6 characters long';
                      }
                      if (value.length > 15) {
                        return '* Password should not be greater than 15 characters';
                      }

                      return null;
                    },
                    controller: password,
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
                    height: screenHeight * 0.02,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Password is required';
                      }
                      if (value.length < 6) {
                        return '* Password should have atleast 6 characters long';
                      }
                      if (value.length > 15) {
                        return '* Password should not be greater than 15 characters';
                      }
                      print(password.text);
                      print(confirmpassword.text);
                      if (password.text != confirmpassword.text) {
                        return '* Password doesn\'t match';
                      }

                      return null;
                    },
                    controller: confirmpassword,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: hideConfirmPassword
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword = !hideConfirmPassword;
                          });
                        },
                      ),
                      labelText: 'Confirm Password',
                    ),
                    obscureText: hideConfirmPassword,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_form.currentState!.validate()) {
                        // If the form is valid, display a Snackbar.
                        signUp();
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
                        'Sign Up',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
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
        ),
      ),
    );
  }
}
