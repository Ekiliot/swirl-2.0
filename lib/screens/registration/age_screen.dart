import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/registration_progress.dart';
import 'gender_screen.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int _selectedAge = 18;

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
                currentStep: 1,
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
                          'Сколько вам лет?',
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
                          'Прокрутите колесо, чтобы выбрать возраст',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 40),
                
                      // Выбор возраста с красивым колесом
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 60,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 53,
                                builder: (context, index) {
                                  final age = 18 + index;
                                  final isSelected = age == _selectedAge;

                                  return AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    margin: EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? AppTheme.toxicYellow.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 200),
                                        style: GoogleFonts.montserrat(
                                          color: isSelected ? AppTheme.toxicYellow : Colors.grey.shade400,
                                          fontSize: isSelected ? 32 : 24,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        child: Text('$age'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedAge = 18 + index;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                
                      SizedBox(height: 40),
                      
                      // Кнопка продолжить с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1200),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => GenderScreen(),
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
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.toxicYellow,
                              foregroundColor: AppTheme.pureBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.toxicYellow.withValues(alpha: 0.3),
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
}