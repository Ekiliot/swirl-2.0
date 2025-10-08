import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'thumbnail_service.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Пути в Storage
  static const String _photosPath = 'chat_photos';
  static const String _videosPath = 'chat_videos';

  /// Выбор и отправка фото
  Future<Map<String, dynamic>?> pickAndUploadPhoto() async {
    try {
      // Проверяем авторизацию перед началом
      final user = _auth.currentUser;
      print('MediaService: Текущий пользователь: ${user?.uid}');
      
      if (user == null) {
        print('MediaService: Пользователь не авторизован!');
        return null;
      }

      // Выбираем фото с качеством 80% для сжатия
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Встроенное сжатие ImagePicker
        maxWidth: 1920,   // Ограничиваем размер
        maxHeight: 1920,
      );

      if (image == null) return null;

      // Создаем миниатюру
      final thumbnailData = await ThumbnailService.createThumbnail(image);
      String? thumbnailPath;
      if (thumbnailData != null) {
        final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid ?? 'unknown'}.png';
        thumbnailPath = await ThumbnailService.saveThumbnailToCache(thumbnailData, fileName);
      }

      // На веб-платформе используем XFile напрямую
      if (kIsWeb) {
        final String downloadUrl = await _uploadPhotoWeb(image);
        return {
          'type': 'photo',
          'url': downloadUrl,
          'localPath': image.path,
          'size': await image.length(),
          'thumbnail': thumbnailPath,
          'thumbnailData': thumbnailData,
        };
      } else {
        final File imageFile = File(image.path);
        final String downloadUrl = await _uploadPhoto(imageFile);
        return {
          'type': 'photo',
          'url': downloadUrl,
          'localPath': imageFile.path,
          'size': await imageFile.length(),
          'thumbnail': thumbnailPath,
          'thumbnailData': thumbnailData,
        };
      }
    } catch (e) {
      print('MediaService: Ошибка при выборе фото: $e');
      return null;
    }
  }

  /// Съемка и отправка фото
  Future<Map<String, dynamic>?> takeAndUploadPhoto() async {
    try {
      // Снимаем фото с качеством 80% для сжатия
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Встроенное сжатие ImagePicker
        maxWidth: 1920,   // Ограничиваем размер
        maxHeight: 1920,
      );

      if (image == null) return null;

      // Создаем миниатюру
      final thumbnailData = await ThumbnailService.createThumbnail(image);
      String? thumbnailPath;
      if (thumbnailData != null) {
        final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid ?? 'unknown'}.png';
        thumbnailPath = await ThumbnailService.saveThumbnailToCache(thumbnailData, fileName);
      }

      // На веб-платформе используем XFile напрямую
      if (kIsWeb) {
        final String downloadUrl = await _uploadPhotoWeb(image);
        return {
          'type': 'photo',
          'url': downloadUrl,
          'localPath': image.path,
          'size': await image.length(),
          'thumbnail': thumbnailPath,
          'thumbnailData': thumbnailData,
        };
      } else {
        final File imageFile = File(image.path);
        final String downloadUrl = await _uploadPhoto(imageFile);
        return {
          'type': 'photo',
          'url': downloadUrl,
          'localPath': imageFile.path,
          'size': await imageFile.length(),
          'thumbnail': thumbnailPath,
          'thumbnailData': thumbnailData,
        };
      }
    } catch (e) {
      print('MediaService: Ошибка при съемке фото: $e');
      return null;
    }
  }

  /// Выбор и отправка видео
  Future<Map<String, dynamic>?> pickAndUploadVideo() async {
    try {
      // Выбираем видео
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 5), // Ограничиваем длительность
      );

      if (video == null) return null;

      // На веб-платформе используем XFile напрямую
      if (kIsWeb) {
        final String downloadUrl = await _uploadVideoWeb(video);
        return {
          'type': 'video',
          'url': downloadUrl,
          'localPath': video.path,
          'size': await video.length(),
          'duration': 0, // Длительность будет получена из метаданных
        };
      } else {
        final File videoFile = File(video.path);
        final String downloadUrl = await _uploadVideo(videoFile);
        return {
          'type': 'video',
          'url': downloadUrl,
          'localPath': videoFile.path,
          'size': await videoFile.length(),
          'duration': 0, // Длительность будет получена из метаданных
        };
      }
    } catch (e) {
      print('MediaService: Ошибка при выборе видео: $e');
      return null;
    }
  }

  /// Съемка и отправка видео
  Future<Map<String, dynamic>?> takeAndUploadVideo() async {
    try {
      // Снимаем видео
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(minutes: 5), // Ограничиваем длительность
      );

      if (video == null) return null;

      // На веб-платформе используем XFile напрямую
      if (kIsWeb) {
        final String downloadUrl = await _uploadVideoWeb(video);
        return {
          'type': 'video',
          'url': downloadUrl,
          'localPath': video.path,
          'size': await video.length(),
          'duration': 0, // Длительность будет получена из метаданных
        };
      } else {
        final File videoFile = File(video.path);
        final String downloadUrl = await _uploadVideo(videoFile);
        return {
          'type': 'video',
          'url': downloadUrl,
          'localPath': videoFile.path,
          'size': await videoFile.length(),
          'duration': 0, // Длительность будет получена из метаданных
        };
      }
    } catch (e) {
      print('MediaService: Ошибка при съемке видео: $e');
      return null;
    }
  }


  /// Загрузка фото в Storage (мобильные платформы)
  Future<String> _uploadPhoto(File photoFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'anonymous';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final Reference ref = _storage.ref().child('$_photosPath/$fileName');

      final UploadTask uploadTask = ref.putFile(photoFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('MediaService: Фото загружено: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('MediaService: Ошибка загрузки фото: $e');
      rethrow;
    }
  }

  /// Загрузка фото в Storage (веб-платформа)
  Future<String> _uploadPhotoWeb(XFile photoFile) async {
    try {
      // Проверяем авторизацию пользователя
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final String userId = user.uid;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      
      final Reference ref = _storage.ref().child('$_photosPath/$fileName');
      final Uint8List data = await photoFile.readAsBytes();
      
      final UploadTask uploadTask = ref.putData(data);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Конвертируем URL для использования через прокси
      final String proxyUrl = _convertToProxyUrl(downloadUrl);
      
      print('MediaService: Фото загружено (веб): $proxyUrl');
      return proxyUrl;
    } catch (e) {
      print('MediaService: Ошибка загрузки фото (веб): $e');
      rethrow;
    }
  }

  /// Загрузка видео в Storage (мобильные платформы)
  Future<String> _uploadVideo(File videoFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'anonymous';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.mp4';
      final Reference ref = _storage.ref().child('$_videosPath/$fileName');

      final UploadTask uploadTask = ref.putFile(videoFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('MediaService: Видео загружено: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('MediaService: Ошибка загрузки видео: $e');
      rethrow;
    }
  }

  /// Загрузка видео в Storage (веб-платформа)
  Future<String> _uploadVideoWeb(XFile videoFile) async {
    try {
      // Проверяем авторизацию пользователя
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final String userId = user.uid;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.mp4';
      
      final Reference ref = _storage.ref().child('$_videosPath/$fileName');
      final Uint8List data = await videoFile.readAsBytes();
      
      final UploadTask uploadTask = ref.putData(data);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Конвертируем URL для использования через прокси
      final String proxyUrl = _convertToProxyUrl(downloadUrl);
      
      print('MediaService: Видео загружено (веб): $proxyUrl');
      return proxyUrl;
    } catch (e) {
      print('MediaService: Ошибка загрузки видео (веб): $e');
      rethrow;
    }
  }


  /// Конвертация Firebase Storage URL в прокси URL
  String _convertToProxyUrl(String firebaseUrl) {
    if (kIsWeb) {
      // Извлекаем путь к файлу из Firebase Storage URL
      final uri = Uri.parse(firebaseUrl);
      final pathSegments = uri.pathSegments;
      
      // Находим индекс 'o' (объект) в пути
      final oIndex = pathSegments.indexOf('o');
      if (oIndex != -1 && oIndex + 1 < pathSegments.length) {
        // Получаем путь к файлу после 'o'
        final filePath = pathSegments.sublist(oIndex + 1).join('/');
        // Возвращаем прокси URL
        return 'https://us-central1-swirl-1856f.cloudfunctions.net/proxyStorage/storage/$filePath';
      }
    }
    
    // Если не веб или не удалось извлечь путь, возвращаем оригинальный URL
    return firebaseUrl;
  }

  /// Получение размера файла в читаемом формате
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Получение длительности в читаемом формате
  String formatDuration(int milliseconds) {
    final int seconds = (milliseconds / 1000).round();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}

