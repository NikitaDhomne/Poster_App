import 'package:flutter/material.dart';
import 'package:poster_app/screens/admin_homepage.dart';
import 'package:poster_app/screens/admin_login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poster_app/screens/user_homepage.dart';
import 'package:poster_app/screens/user_login_screen.dart';
import 'package:poster_app/screens/user_register_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: UserLoginPage(),
      routes: {
        AdminLoginPage.routeName: (context) => AdminLoginPage(),
        UserLoginPage.routeName: (context) => UserLoginPage(),
        UserRegister.routeName: (context) => UserRegister(),
        AdminHomePage.routeName: (context) => AdminHomePage(),
        UserHomePage.routeName: (context) => UserHomePage()
      },
    );
  }
}
