import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'error_logger.dart';

/// 📸 Studygram & Instagram Story Paylaşım Kartı Motoru
class ShareCardService {
  static final ShareCardService instance = ShareCardService._();
  ShareCardService._();

  /// GlobalKey ile işaretlenmiş widget'ı 3x piksel oranıyla (1080p Instagram Story) PNG'ye dönüştürür
  Future<Uint8List?> captureWidgetToPng(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e, st) {
      ErrorLogger.log('ShareCardService.captureWidgetToPng', e, st);
      return null;
    }
  }

  /// PNG verisini geçici dosyaya kaydedip yerel sistem paylaşım sayfasını açar
  Future<bool> shareStoryImage(Uint8List pngBytes, {String? caption}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/calenda_story_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      final shareResult = await Share.shareXFiles(
        [XFile(filePath)],
        text: caption ?? 'Calenda ile Çalışıyorum 🌿 #Studygram #Calenda',
      );

      return shareResult.status == ShareResultStatus.success;
    } catch (e, st) {
      ErrorLogger.log('ShareCardService.shareStoryImage', e, st);
      return false;
    }
  }
}
