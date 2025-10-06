import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onSettingsPressed;

  const ProfileActionButtons({
    super.key,
    required this.onEditPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: EvaIcons.edit,
              label: 'Редактировать',
              onTap: onEditPressed,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: EvaIcons.settings,
              label: 'Настройки',
              onTap: onSettingsPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkGray.withValues(alpha: 0.8),
              AppTheme.mediumGray.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.toxicYellow.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.toxicYellow,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

