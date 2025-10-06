import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/registration_progress.dart';
import '../main/main_screen.dart';
import 'registration_widgets/age_widget.dart';
import 'registration_widgets/gender_widget.dart';
import 'registration_widgets/name_widget.dart';
import 'registration_widgets/email_password_widget.dart';
import '../../services/auth_service.dart';

class UnifiedRegistrationScreen extends StatefulWidget {
  const UnifiedRegistrationScreen({super.key});

  @override
  State<UnifiedRegistrationScreen> createState() => _UnifiedRegistrationScreenState();
}

class _UnifiedRegistrationScreenState extends State<UnifiedRegistrationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isSubmitting = false;
  String? _error;
  
  // Данные регистрации
  int? _selectedAge;
  String? _selectedGender;
  String? _name;
  String? _email;
  String? _password;

  final List<String> _stepTitles = [
    'Сколько вам лет?',
    'Ваш пол?',
    'Как вас зовут?',
    'Создать аккаунт'
  ];

  final List<String> _stepSubtitles = [
    'Прокрутите колесо, чтобы выбрать возраст',
    'Выберите ваш пол',
    'Введите ваше имя',
    'Введите ваши данные для завершения регистрации'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeRegistration() async {
    if (!_canProceed()) return;
    setState(() { _isSubmitting = true; _error = null; });
    try {
      await AuthService.instance.registerWithEmail(
        email: _email!,
        password: _password!,
        name: _name!,
        age: _selectedAge!,
        gender: _selectedGender!,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedAge != null;
      case 1:
        return _selectedGender != null;
      case 2:
        return _name != null && _name!.trim().isNotEmpty;
      case 3:
        return _email != null && _password != null && 
               _email!.contains('@') && _email!.contains('.') && 
               _password!.length >= 6;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Прогресс-бар
                  RegistrationProgress(
                    currentStep: _currentStep + 1,
                    totalSteps: 4,
                  ),
                  
                  // Заголовок и подзаголовок
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        
                        // Заголовок с анимацией
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            _stepTitles[_currentStep],
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
                            _stepSubtitles[_currentStep],
                            style: GoogleFonts.montserrat(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_error != null) ...[
                          SizedBox(height: 12),
                          Text(
                            _error!,
                            style: GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Контент с PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // Этап 1: Возраст
                        AgeWidget(
                          selectedAge: _selectedAge,
                          onAgeChanged: (age) {
                            setState(() {
                              _selectedAge = age;
                            });
                          },
                        ),
                        
                        // Этап 2: Пол
                        GenderWidget(
                          selectedGender: _selectedGender,
                          onGenderChanged: (gender) {
                            setState(() {
                              _selectedGender = gender;
                            });
                          },
                        ),
                        
                        // Этап 3: Имя
                        NameWidget(
                          name: _name,
                          onNameChanged: (name) {
                            setState(() {
                              _name = name;
                            });
                          },
                        ),
                        
                        // Этап 4: Email и пароль
                        EmailPasswordWidget(
                          email: _email,
                          password: _password,
                          onEmailChanged: (email) {
                            setState(() {
                              _email = email;
                            });
                          },
                          onPasswordChanged: (password) {
                            setState(() {
                              _password = password;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Навигационные кнопки
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Кнопка "Назад"
                        if (_currentStep > 0)
                          Expanded(
                            child: Container(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _previousStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.darkGray,
                                  foregroundColor: AppTheme.toxicYellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: AppTheme.toxicYellow, width: 2),
                                  ),
                                ),
                                child: Text(
                                  'Назад',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        if (_currentStep > 0) SizedBox(width: 16),
                        
                        // Кнопка "Продолжить" / "Создать аккаунт"
                        Expanded(
                          child: Container(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _canProceed() ? (_currentStep == 3 ? _completeRegistration : _nextStep) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canProceed() 
                                    ? AppTheme.toxicYellow 
                                    : AppTheme.mediumGray,
                                foregroundColor: AppTheme.pureBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: _canProceed() ? 8 : 0,
                                shadowColor: _canProceed() 
                                    ? AppTheme.toxicYellow.withValues(alpha: 0.3) 
                                    : null,
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.pureBlack,
                                      ),
                                    )
                                  : Text(
                                      _currentStep == 3 ? 'Создать аккаунт' : 'Продолжить',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
