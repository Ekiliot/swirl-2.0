import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../registration/unified_registration_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Spacer(),
                
                // Логотип
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.toxicYellow,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: AppTheme.pureBlack,
                    size: 60,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Заголовок
                Text(
                  'Добро пожаловать в Swirl',
                  style: TextStyle(
                    color: AppTheme.toxicYellow,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 16),
                
                // Подзаголовок
                Text(
                  'Найди свою вторую половинку',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                Spacer(),
                
                // Кнопка регистрации
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UnifiedRegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.toxicYellow,
                      foregroundColor: AppTheme.pureBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Начать',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Кнопка входа
                Container(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.toxicYellow,
                      side: BorderSide(color: AppTheme.toxicYellow, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}