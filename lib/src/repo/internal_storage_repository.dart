/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';

const _imageExt = '.jpg';

class InternalStorageRepository {
  final AnalyticsRepository analyticsRepository;

  InternalStorageRepository({required this.analyticsRepository});

  Future<Directory> getImagesDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return Directory('${appDirectory.path}/images').create();
  }

  Future<File> saveItemImage(String itemId, File imageFile) async {
    try {
      final imageFilePath = await getItemImagePath(itemId);
      final savedFile = imageFile.copySync(imageFilePath);

      imageFile.deleteSync();

      return savedFile;
    } catch (e, trace) {
      analyticsRepository.logException(
        reason: '$runtimeType: saveItemImage',
        exception: e,
        trace: trace,
      );
      debugPrint('$runtimeType: saveItemImage $e');
      return imageFile;
    }
  }

  Future<void> removeItemImage(String itemId) async {
    final itemImage = await getItemImage(itemId);
    await itemImage.delete();
    return;
  }

  Future<String> getItemImagePath(String itemId) async {
    final imageFileName = '${itemId}_image$_imageExt';
    final imageFileDirectory = await getImagesDirectory();
    return '${imageFileDirectory.path}/$imageFileName';
  }

  Future<File> getItemImage(String itemId) async {
    return File(await getItemImagePath(itemId));
  }

  Future<void> clearCacheFromImages(Directory? cache) async {
    if (cache != null) {
      final cacheFiles = cache.listSync();
      cacheFiles.where((file) => extension(file.path) == _imageExt).forEach(
        (image) {
          image.delete();
        },
      );
    }
  }
}
