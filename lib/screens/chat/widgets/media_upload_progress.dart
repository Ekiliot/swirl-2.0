import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'dart:typed_data';
import '../../../theme/app_theme.dart';

/// Виджет для отображения прогресса загрузки медиа
class MediaUploadProgress extends StatefulWidget {
  final double progress;
  final Uint8List? thumbnailData;
  final VoidCallback? onCancel;
  final String? error;

  const MediaUploadProgress({
    Key? key,
    required this.progress,
    this.thumbnailData,
    this.onCancel,
    this.error,
  }) : super(key: key);

  @override
  State<MediaUploadProgress> createState() => _MediaUploadProgressState();
}

class _MediaUploadProgressState extends State<MediaUploadProgress>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.darkGray.withOpacity(0.8),
        border: Border.all(
          color: AppTheme.toxicYellow.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Миниатюра или фон
          if (widget.thumbnailData != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                widget.thumbnailData!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.toxicYellow.withOpacity(0.3),
                    AppTheme.darkYellow.withOpacity(0.3),
                  ],
                ),
              ),
            ),

          // Оверлей с прогрессом
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.6),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Анимированная иконка
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value * 2 * 3.14159,
                          child: Icon(
                            widget.error != null 
                                ? EvaIcons.closeCircle 
                                : EvaIcons.cloudUpload,
                            size: 48,
                            color: widget.error != null 
                                ? Colors.red 
                                : AppTheme.toxicYellow,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Прогресс бар
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 120 * widget.progress,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.toxicYellow,
                                AppTheme.darkYellow,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Текст прогресса или ошибки
                  Text(
                    widget.error != null 
                        ? 'Ошибка загрузки'
                        : '${(widget.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (widget.error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Кнопка отмены
          if (widget.onCancel != null && widget.error == null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onCancel,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    EvaIcons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
