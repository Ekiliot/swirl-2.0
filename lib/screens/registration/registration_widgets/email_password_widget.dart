import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class EmailPasswordWidget extends StatefulWidget {
  final String? email;
  final String? password;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;

  const EmailPasswordWidget({
    super.key,
    required this.email,
    required this.password,
    required this.onEmailChanged,
    required this.onPasswordChanged,
  });

  @override
  State<EmailPasswordWidget> createState() => _EmailPasswordWidgetState();
}

class _EmailPasswordWidgetState extends State<EmailPasswordWidget> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Валидация
  bool get _isPasswordValid => _passwordController.text.length >= 6;
  bool get _isConfirmPasswordValid => _confirmPasswordController.text == _passwordController.text && _confirmPasswordController.text.isNotEmpty;
  bool get _isEmailValid => _emailController.text.contains('@') && _emailController.text.contains('.');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _passwordController = TextEditingController(text: widget.password ?? '');
    _confirmPasswordController = TextEditingController();
    
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    widget.onEmailChanged(_emailController.text);
  }

  void _onPasswordChanged() {
    widget.onPasswordChanged(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 20),
          
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
        ],
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
