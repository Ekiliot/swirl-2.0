import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileMainInfoCard extends StatelessWidget {
  final String name;
  final int age;
  final String gender;
  final String bio;
  final VoidCallback? onEditBio;

  const ProfileMainInfoCard({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    this.onEditBio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkGray.withValues(alpha: 0.8),
            AppTheme.mediumGray.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.toxicYellow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.toxicYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$age',
                  style: GoogleFonts.montserrat(
                    color: AppTheme.pureBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            gender,
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  bio,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: onEditBio,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.toxicYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Icon(Icons.edit, color: AppTheme.toxicYellow, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

