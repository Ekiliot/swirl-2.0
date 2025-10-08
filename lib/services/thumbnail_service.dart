import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

/// Сервис для создания миниатюр и кэширования медиа
class ThumbnailService {
  static const String _thumbnailsDir = 'thumbnails';
  
  /// Создание миниатюры для фото
  static Future<Uint8List?> createThumbnail(XFile imageFile, {int maxSize = 200}) async {
    try {
      if (kIsWeb) {
        // На веб используем canvas для создания миниатюры
        return await _createWebThumbnail(imageFile, maxSize);
      } else {
        // На мобильных устройствах используем Image
        return await _createMobileThumbnail(imageFile, maxSize);
      }
    } catch (e) {
      print('ThumbnailService: Ошибка создания миниатюры: $e');
      return null;
    }
  }

  /// Создание миниатюры на веб-платформе
  static Future<Uint8List?> _createWebThumbnail(XFile imageFile, int maxSize) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxSize,
        targetHeight: maxSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('ThumbnailService: Ошибка создания веб-миниатюры: $e');
      return null;
    }
  }

  /// Создание миниатюры на мобильных устройствах
  static Future<Uint8List?> _createMobileThumbnail(XFile imageFile, int maxSize) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxSize,
        targetHeight: maxSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('ThumbnailService: Ошибка создания мобильной миниатюры: $e');
      return null;
    }
  }

  /// Сохранение миниатюры в кэш
  static Future<String?> saveThumbnailToCache(Uint8List thumbnailData, String fileName) async {
    try {
      if (kIsWeb) {
        // На веб используем IndexedDB через shared_preferences
        return await _saveWebThumbnail(thumbnailData, fileName);
      } else {
        // На мобильных устройствах сохраняем в файловую систему
        return await _saveMobileThumbnail(thumbnailData, fileName);
      }
    } catch (e) {
      print('ThumbnailService: Ошибка сохранения миниатюры: $e');
      return null;
    }
  }

  /// Сохранение миниатюры на веб-платформе
  static Future<String?> _saveWebThumbnail(Uint8List thumbnailData, String fileName) async {
    try {
      // На веб создаем data URL для миниатюры
      final base64 = base64Encode(thumbnailData);
      return 'data:image/png;base64,$base64';
    } catch (e) {
      print('ThumbnailService: Ошибка сохранения веб-миниатюры: $e');
      return null;
    }
  }

  /// Сохранение миниатюры на мобильных устройствах
  static Future<String?> _saveMobileThumbnail(Uint8List thumbnailData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${directory.path}/$_thumbnailsDir');
      
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }
      
      final file = File('${thumbnailsDir.path}/$fileName');
      await file.writeAsBytes(thumbnailData);
      
      return file.path;
    } catch (e) {
      print('ThumbnailService: Ошибка сохранения мобильной миниатюры: $e');
      return null;
    }
  }

  /// Получение миниатюры из кэша
  static Future<Uint8List?> getThumbnailFromCache(String fileName) async {
    try {
      if (kIsWeb) {
        // На веб миниатюры хранятся в памяти
        return null;
      } else {
        // На мобильных устройствах читаем из файла
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_thumbnailsDir/$fileName');
        
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      print('ThumbnailService: Ошибка получения миниатюры из кэша: $e');
      return null;
    }
  }

  /// Проверка существования миниатюры в кэше
  static Future<bool> hasThumbnailInCache(String fileName) async {
    try {
      if (kIsWeb) {
        // На веб всегда возвращаем false, так как миниатюры в памяти
        return false;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_thumbnailsDir/$fileName');
        return await file.exists();
      }
    } catch (e) {
      print('ThumbnailService: Ошибка проверки миниатюры: $e');
      return false;
    }
  }

  /// Очистка кэша миниатюр
  static Future<void> clearThumbnailCache() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final thumbnailsDir = Directory('${directory.path}/$_thumbnailsDir');
        
        if (await thumbnailsDir.exists()) {
          await thumbnailsDir.delete(recursive: true);
        }
      }
    } catch (e) {
      print('ThumbnailService: Ошибка очистки кэша: $e');
    }
  }

  /// Получение размера кэша
  static Future<int> getCacheSize() async {
    try {
      if (kIsWeb) {
        return 0; // На веб размер кэша не отслеживаем
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final thumbnailsDir = Directory('${directory.path}/$_thumbnailsDir');
        
        if (!await thumbnailsDir.exists()) {
          return 0;
        }
        
        int totalSize = 0;
        await for (final entity in thumbnailsDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
        
        return totalSize;
      }
    } catch (e) {
      print('ThumbnailService: Ошибка получения размера кэша: $e');
      return 0;
    }
  }

  /// Форматирование размера кэша
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
