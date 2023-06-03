import 'package:akira_mobile/middlewares/AuthMiddleware.dart';
import 'package:akira_mobile/screens/GI/good_issuing.dart';
import 'package:akira_mobile/screens/GRN/create.dart';
import 'package:akira_mobile/screens/Home/home.dart';
import 'package:akira_mobile/screens/Login/login_screen.dart';
import 'package:akira_mobile/screens/Material/create.dart';
import 'package:akira_mobile/screens/Preview/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/colors.dart';
import 'constants/styles.dart';
import 'screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check the validity of the token
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear();
  String? token = prefs.getString('access_token');
  bool tokenIsValid = token != null && validateToken(token);

  runApp(MyApp(tokenIsValid: tokenIsValid));
}

bool validateToken(String token) {
  // Perform token validation here, return true if valid and false otherwise
  return true;
}

class MyApp extends StatelessWidget {
  final bool tokenIsValid;
  MyApp({required this.tokenIsValid});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AKIRA Inventory',
        navigatorObservers: [AuthMiddleware()],
        theme: ThemeData(
            useMaterial3: true,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0, backgroundColor: kPrimaryColor,
                shape: const StadiumBorder(),
                maximumSize: const Size(double.infinity, 56),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: kPrimaryLightColor,
              iconColor: kPrimaryColor,
              prefixIconColor: kPrimaryColor,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
            )),
        home: tokenIsValid ? const HomeScreen() : const WelcomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/scan': (context) => ScanPage(),
          '/good_issuing': (context) => GoodIssuing(),
          '/new_material': (context) => CreateMaterial(),
          '/new_grn': (context) => CreateGRN(),
        }
    );
  }
}
