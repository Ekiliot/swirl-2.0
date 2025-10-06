import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class RegistrationProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RegistrationProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Прогресс-бар
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width * (currentStep / totalSteps),
              decoration: BoxDecoration(
                color: AppTheme.toxicYellow,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Текст прогресса
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Шаг $currentStep из $totalSteps',
                style: GoogleFonts.montserrat(
                  color: AppTheme.toxicYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((currentStep / totalSteps) * 100).round()}%',
                style: GoogleFonts.montserrat(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
