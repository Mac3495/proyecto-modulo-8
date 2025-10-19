import 'package:flutter/material.dart';
import 'package:proyecto_modulo/presentation/screens/admin_home/admin_home_screen.dart';
import 'package:proyecto_modulo/presentation/screens/employee_home/employee_home_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/sign_in/sign_in_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const adminHome = '/admin-home';
  static const employeeHome = '/employee-home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case employeeHome:
        return MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
