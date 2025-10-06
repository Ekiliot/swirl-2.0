import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'email_password_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty;
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
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: 40),
                
                // Заголовок
                Text(
                  'Как вас зовут?',
                  style: TextStyle(
                    color: AppTheme.toxicYellow,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Поле ввода имени
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    labelStyle: TextStyle(color: AppTheme.toxicYellow),
                    hintText: 'Введите ваше имя',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
                
                Spacer(),
                
                // Кнопка продолжить
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailPasswordScreen()),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? AppTheme.toxicYellow : AppTheme.mediumGray,
                      foregroundColor: AppTheme.pureBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Продолжить',
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