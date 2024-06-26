import 'package:flutter/material.dart';
import 'package:umla_help/profile/profile.dart';
import 'package:umla_help/report/report.dart';

import 'add_medicine/add.dart';
import 'authentication/Login.dart';
import 'authentication/Signup.dart';
import 'home/HomeScreen.dart';

class Routes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String report = '/report';
  static const String add = '/add';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => Login());
      case signup:
        return MaterialPageRoute(builder: (context) => Signup());
      case home:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case report:
        return MaterialPageRoute(builder: (context) => ReportScreen());
      case add:
        return MaterialPageRoute(builder: (context) => AddMedicineScreen());
      default:
        return MaterialPageRoute(builder: (context) => Login());
    }
  }
}
