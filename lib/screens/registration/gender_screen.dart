import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/registration_progress.dart';
import 'name_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Прогресс-бар
              RegistrationProgress(
                currentStep: 2,
                totalSteps: 4,
              ),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      
                      // Заголовок с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          'Ваш пол?',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.toxicYellow,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Подзаголовок
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1000),
                        child: Text(
                          'Выберите ваш пол',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 60),
                
                      // Варианты пола с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1200),
                        child: _buildGenderOption('Мужской', 'male'),
                      ),
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1400),
                        child: _buildGenderOption('Женский', 'female'),
                      ),
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1600),
                        child: _buildGenderOption('Другое', 'other'),
                      ),
                
                      Spacer(),
                      
                      // Кнопка продолжить с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1800),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _selectedGender != null ? () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => NameScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: animation.drive(
                                        Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
                                            .chain(CurveTween(curve: Curves.easeInOut)),
                                      ),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: Duration(milliseconds: 300),
                                ),
                              );
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedGender != null ? AppTheme.toxicYellow : AppTheme.mediumGray,
                              foregroundColor: AppTheme.pureBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: _selectedGender != null ? 8 : 0,
                              shadowColor: _selectedGender != null ? AppTheme.toxicYellow.withValues(alpha: 0.3) : null,
                            ),
                            child: Text(
                              'Продолжить',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = _selectedGender == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.toxicYellow : AppTheme.darkGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.toxicYellow,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.toxicYellow.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: GoogleFonts.montserrat(
              color: isSelected ? AppTheme.pureBlack : AppTheme.toxicYellow,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}