import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final bool isOnline;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.toxicYellow,
            AppTheme.darkYellow,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.toxicYellow.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppTheme.darkYellow.withValues(alpha: 0.2),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              initial,
              style: GoogleFonts.montserrat(
                color: AppTheme.pureBlack,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.pureBlack,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

