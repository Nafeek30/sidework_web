import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sidework_web/landing_view/loginPage.dart';
import 'package:sidework_web/utilities/constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  /// Firebase configuration code
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Then run the app
  runApp(const SideWorkApp());
}

class SideWorkApp extends StatelessWidget {
  const SideWorkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants.sideworkBlue,
      ),
      home: const LoginPage(),
    );
  }
}
