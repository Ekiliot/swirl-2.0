import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swirl',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return DefaultTextStyle(
          style: GoogleFonts.montserrat(
            color: Colors.white,
          ),
          child: child!,
        );
      },
      home: StreamBuilder(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.pureBlack,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.toxicYellow),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}