import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class NameWidget extends StatefulWidget {
  final String? name;
  final Function(String) onNameChanged;

  const NameWidget({
    super.key,
    required this.name,
    required this.onNameChanged,
  });

  @override
  State<NameWidget> createState() => _NameWidgetState();
}

class _NameWidgetState extends State<NameWidget> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name ?? '');
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onNameChanged(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 40),
          
          // Поле ввода имени
          AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 1200),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _nameController.text.trim().isNotEmpty 
                      ? AppTheme.toxicYellow 
                      : AppTheme.mediumGray,
                  width: 2,
                ),
                boxShadow: _nameController.text.trim().isNotEmpty ? [
                  BoxShadow(
                    color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: 'Ваше имя',
                  labelStyle: GoogleFonts.montserrat(color: AppTheme.toxicYellow),
                  hintText: 'Введите ваше имя',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.person, color: AppTheme.toxicYellow),
                  suffixIcon: _nameController.text.trim().isNotEmpty 
                      ? Icon(Icons.check_circle, color: AppTheme.toxicYellow)
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
          ),
          
          Spacer(),
        ],
      ),
    );
  }
}
