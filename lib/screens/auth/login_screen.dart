import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  bool get _isEmailValid => _emailController.text.contains('@') && _emailController.text.contains('.');
  bool get _isPasswordValid => _passwordController.text.length >= 6;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_isEmailValid || !_isPasswordValid) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.instance.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.pureBlack,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.toxicYellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: 40),
                
                // Заголовок
                Text(
                  'Войти',
                  style: TextStyle(
                    color: AppTheme.toxicYellow,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                
                SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                
                SizedBox(height: 24),
                
                // Поле email
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppTheme.toxicYellow),
                    prefixIcon: Icon(Icons.email, color: AppTheme.toxicYellow),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Поле пароля
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: TextStyle(color: AppTheme.toxicYellow),
                    prefixIcon: Icon(Icons.lock, color: AppTheme.toxicYellow),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Кнопка входа
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (_isEmailValid && _isPasswordValid && !_isLoading) ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isEmailValid && _isPasswordValid) ? AppTheme.toxicYellow : AppTheme.mediumGray,
                      foregroundColor: AppTheme.pureBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pureBlack),
                          )
                        : Text(
                            'Войти',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                  ),
                ),
                
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}