import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/registration_progress.dart';
import '../main/main_screen.dart';

class EmailPasswordScreen extends StatefulWidget {
  const EmailPasswordScreen({super.key});

  @override
  State<EmailPasswordScreen> createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonEnabled = false;
  
  // Валидация паролей
  bool get _isPasswordValid => _passwordController.text.length >= 6;
  bool get _isConfirmPasswordValid => _confirmPasswordController.text == _passwordController.text && _confirmPasswordController.text.isNotEmpty;
  bool get _isEmailValid => _emailController.text.contains('@') && _emailController.text.contains('.');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onTextChanged);
    _passwordController.removeListener(_onTextChanged);
    _confirmPasswordController.removeListener(_onTextChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _isEmailValid && _isPasswordValid && _isConfirmPasswordValid;
    });
  }

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
                currentStep: 4,
                totalSteps: 4,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      
                      // Заголовок с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          'Создать аккаунт',
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
                          'Введите ваши данные для завершения регистрации',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 40),
                
                      // Поле email с валидацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1200),
                        child: _buildEmailField(),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Поле пароля с валидацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1400),
                        child: _buildPasswordField(),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Поле подтверждения пароля
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1600),
                        child: _buildConfirmPasswordField(),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Индикаторы валидации
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 1800),
                        child: _buildValidationIndicators(),
                      ),
                
                      SizedBox(height: 40),
                      
                      // Кнопка создать аккаунт с анимацией
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 2000),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled ? () {
                              // TODO: Реализовать создание аккаунта
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
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButtonEnabled 
                                  ? AppTheme.toxicYellow 
                                  : AppTheme.mediumGray,
                              foregroundColor: AppTheme.pureBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: _isButtonEnabled ? 8 : 0,
                              shadowColor: _isButtonEnabled ? AppTheme.toxicYellow.withValues(alpha: 0.3) : null,
                            ),
                            child: Text(
                              'Создать аккаунт',
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

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEmailValid ? AppTheme.toxicYellow : AppTheme.mediumGray,
          width: 2,
        ),
        boxShadow: _isEmailValid ? [
          BoxShadow(
            color: AppTheme.toxicYellow.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: TextField(
        controller: _emailController,
        style: GoogleFonts.montserrat(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
          prefixIcon: Icon(Icons.email, color: AppTheme.toxicYellow),
          suffixIcon: _isEmailValid ? Icon(
            Icons.check_circle,
            color: AppTheme.toxicYellow,
          ) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPasswordValid ? AppTheme.toxicYellow : AppTheme.mediumGray,
          width: 2,
        ),
        boxShadow: _isPasswordValid ? [
          BoxShadow(
            color: AppTheme.toxicYellow.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: GoogleFonts.montserrat(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Пароль',
          labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
          prefixIcon: Icon(Icons.lock, color: AppTheme.toxicYellow),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPasswordValid)
                Icon(Icons.check_circle, color: AppTheme.toxicYellow),
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.toxicYellow,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConfirmPasswordValid ? AppTheme.toxicYellow : AppTheme.mediumGray,
          width: 2,
        ),
        boxShadow: _isConfirmPasswordValid ? [
          BoxShadow(
            color: AppTheme.toxicYellow.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        style: GoogleFonts.montserrat(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Подтвердите пароль',
          labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
          prefixIcon: Icon(Icons.lock_outline, color: AppTheme.toxicYellow),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isConfirmPasswordValid)
                Icon(Icons.check_circle, color: AppTheme.toxicYellow),
              IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.toxicYellow,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildValidationIndicators() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mediumGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Требования к паролю:',
            style: GoogleFonts.montserrat(
              color: AppTheme.toxicYellow,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _buildValidationItem(
            'Минимум 6 символов',
            _isPasswordValid,
          ),
          SizedBox(height: 8),
          _buildValidationItem(
            'Пароли совпадают',
            _isConfirmPasswordValid,
          ),
          SizedBox(height: 8),
          _buildValidationItem(
            'Email корректный',
            _isEmailValid,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isValid ? AppTheme.toxicYellow : AppTheme.mediumGray,
            shape: BoxShape.circle,
          ),
          child: isValid
              ? Icon(
                  Icons.check,
                  color: AppTheme.pureBlack,
                  size: 14,
                )
              : null,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              color: isValid ? AppTheme.toxicYellow : Colors.grey.shade400,
              fontSize: 14,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}