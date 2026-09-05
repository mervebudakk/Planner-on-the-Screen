import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// 🖼️ Antika Altın & Pudra Pembe Kurdeleli Vintage Portre Çerçevesi
class VintageFramedAvatar extends StatelessWidget {
  final String animalAsset;
  final String? accessoryAsset;
  final Color backgroundColor;
  final double height;
  final double? width;

  const VintageFramedAvatar({
    super.key,
    required this.animalAsset,
    this.accessoryAsset,
    required this.backgroundColor,
    this.height = 160,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // 774 / 941 ≈ 0.8225 (vintage_frame doğal en/boy oranı)
    final frameWidth = width ?? (height * 0.8225);

    // Oval merkez oranları (hassas koordinatlar):
    final ovalWidth = frameWidth * 0.60;
    final ovalHeight = height * 0.63;
    final ovalLeft = (frameWidth - ovalWidth) / 2;
    final ovalTop = height * 0.22;

    return SizedBox(
      width: frameWidth,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Zemin: Doğal Suluboya Parşömen Dokusu & Çerçeve Tabanı
          Positioned.fill(
            child: Image.asset(
              AppAssets.vintageFrameParchment,
              fit: BoxFit.contain,
              cacheHeight: (height * 2.5).round(),
              filterQuality: FilterQuality.medium,
            ),
          ),

          // 2. Kullanıcının Seçtiği Renk Tonu (Parşömen üzerine yumuşak renk katmanı)
          Positioned(
            left: ovalLeft,
            top: ovalTop,
            width: ovalWidth,
            height: ovalHeight,
            child: ClipOval(
              child: Container(
                color: backgroundColor.withValues(alpha: 0.70),
              ),
            ),
          ),

          // 3. Karakter Hayvan & Aksesuar Katmanı
          Positioned(
            left: ovalLeft + (ovalWidth - ovalWidth * 0.90) / 2,
            top: ovalTop + ovalHeight * 0.08,
            width: ovalWidth * 0.90,
            height: ovalHeight * 0.88,
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    animalAsset,
                    width: ovalWidth * 0.88,
                    height: ovalHeight * 0.88,
                    fit: BoxFit.contain,
                    cacheWidth: (ovalWidth * 2.5).round(),
                    cacheHeight: (ovalHeight * 2.5).round(),
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.pets, size: 36, color: Color(0xFF9E8D86)),
                  ),
                  if (accessoryAsset != null)
                    Image.asset(
                      accessoryAsset!,
                      width: ovalWidth * 0.88,
                      height: ovalHeight * 0.88,
                      fit: BoxFit.contain,
                      cacheWidth: (ovalWidth * 2.5).round(),
                      cacheHeight: (ovalHeight * 2.5).round(),
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                ],
              ),
            ),
          ),

          // 4. Üst Katman: Oymalı Altın Rim & Kurdele (Avatarın kenarlarını çerçeve içine gömer)
          Positioned.fill(
            child: Image.asset(
              AppAssets.vintageFrameOverlay,
              fit: BoxFit.contain,
              cacheHeight: (height * 2.5).round(),
              filterQuality: FilterQuality.medium,
            ),
          ),
        ],
      ),
    );
  }
}
