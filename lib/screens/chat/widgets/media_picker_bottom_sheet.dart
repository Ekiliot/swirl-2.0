import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../services/media_service.dart';

class MediaPickerBottomSheet extends StatelessWidget {
  final Function(Map<String, dynamic>) onMediaSelected;

  const MediaPickerBottomSheet({
    super.key,
    required this.onMediaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              
              Text(
                'Выберите медиа',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              
              // Кнопки выбора
              Row(
                children: [
                  Expanded(
                    child: _buildMediaButton(
                      context: context,
                      icon: EvaIcons.cameraOutline,
                      label: 'Камера',
                      color: AppTheme.toxicYellow,
                      onTap: () => _showCameraOptions(context),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildMediaButton(
                      context: context,
                      icon: EvaIcons.imageOutline,
                      label: 'Галерея',
                      color: Colors.blue,
                      onTap: () => _showGalleryOptions(context),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionButton(
                  context: context,
                  icon: EvaIcons.cameraOutline,
                  label: 'Сфотографировать',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhotoFromCamera(context);
                  },
                ),
                SizedBox(height: 12),
                _buildOptionButton(
                  context: context,
                  icon: EvaIcons.videoOutline,
                  label: 'Записать видео',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickVideoFromCamera(context);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGalleryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionButton(
                  context: context,
                  icon: EvaIcons.imageOutline,
                  label: 'Выбрать фото',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPhotoFromGallery(context);
                  },
                ),
                SizedBox(height: 12),
                _buildOptionButton(
                  context: context,
                  icon: EvaIcons.videoOutline,
                  label: 'Выбрать видео',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickVideoFromGallery(context);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.mediumGray.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.toxicYellow,
              size: 24,
            ),
            SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              EvaIcons.arrowRightOutline,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhotoFromCamera(BuildContext context) async {
    try {
      final result = await MediaService().takeAndUploadPhoto();
      if (result != null) {
        Navigator.pop(context); // Закрываем основное модальное окно
        onMediaSelected(result);
      }
    } catch (e) {
      print('Ошибка при съемке фото: $e');
    }
  }

  Future<void> _pickPhotoFromGallery(BuildContext context) async {
    try {
      final result = await MediaService().pickAndUploadPhoto();
      if (result != null) {
        Navigator.pop(context); // Закрываем основное модальное окно
        onMediaSelected(result);
      }
    } catch (e) {
      print('Ошибка при выборе фото: $e');
    }
  }

  Future<void> _pickVideoFromCamera(BuildContext context) async {
    try {
      final result = await MediaService().takeAndUploadVideo();
      if (result != null) {
        Navigator.pop(context); // Закрываем основное модальное окно
        onMediaSelected(result);
      }
    } catch (e) {
      print('Ошибка при съемке видео: $e');
    }
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    try {
      final result = await MediaService().pickAndUploadVideo();
      if (result != null) {
        Navigator.pop(context); // Закрываем основное модальное окно
        onMediaSelected(result);
      }
    } catch (e) {
      print('Ошибка при выборе видео: $e');
    }
  }
}
