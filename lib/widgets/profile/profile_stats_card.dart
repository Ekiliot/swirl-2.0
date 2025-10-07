import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkGray.withValues(alpha: 0.6),
            AppTheme.mediumGray.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.toxicYellow.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Матчи', '24', EvaIcons.heart),
          _buildStatItem('Сообщения', '156', EvaIcons.messageCircle),
          _buildStatItem('Дни', '7', EvaIcons.calendar),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.toxicYellow.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.toxicYellow.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.toxicYellow,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

