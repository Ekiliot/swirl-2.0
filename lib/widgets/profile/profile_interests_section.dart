import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/interests_data.dart';

class ProfileInterestsSection extends StatelessWidget {
  final List<String> interests;
  final VoidCallback onAddPressed;
  final Function(String) onRemoveInterest;

  const ProfileInterestsSection({
    super.key,
    required this.interests,
    required this.onAddPressed,
    required this.onRemoveInterest,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                EvaIcons.star,
                color: AppTheme.toxicYellow,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Интересы',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...interests.map((interest) => _buildInterestChip(interest)),
              _buildAddInterestChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    final String key = interest.trim();
    final displayLabel = InterestsData.allInterestsLabels[key]
        ?? InterestsData.allInterestsLabels[key.toLowerCase()]
        ?? _beautifyKey(key);

    return GestureDetector(
      onLongPress: () => onRemoveInterest(interest),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.toxicYellow.withValues(alpha: 0.2),
              AppTheme.darkYellow.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.toxicYellow,
            width: 1,
          ),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.montserrat(
            color: AppTheme.toxicYellow,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _beautifyKey(String key) {
    final spaced = key.replaceAll('_', ' ');
    if (spaced.isEmpty) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  Widget _buildAddInterestChip() {
    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.toxicYellow,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              EvaIcons.plus,
              color: AppTheme.toxicYellow,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Добавить',
              style: GoogleFonts.montserrat(
                color: AppTheme.toxicYellow,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

