import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class GenderWidget extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderChanged;

  const GenderWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = selectedGender == value;
    
    return GestureDetector(
      onTap: () {
        onGenderChanged(value);
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
