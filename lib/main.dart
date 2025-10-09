import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/auth_service.dart';
import 'services/user_activity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Настройка системной навигационной панели - скрываем её полностью
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Показываем только статус бар
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Настройка ориентации экрана
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Инициализация SharedPreferences
  await SharedPreferences.getInstance();
  
  // Инициализация сервиса активности пользователей
  await UserActivityService().initialize();
  
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
        return SafeArea(
          child: DefaultTextStyle(
            style: GoogleFonts.montserrat(
              color: Colors.white,
            ),
            child: child!,
          ),
        );
      },
      home: StreamBuilder(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.pureBlack,
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.toxicYellow),
                ),
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