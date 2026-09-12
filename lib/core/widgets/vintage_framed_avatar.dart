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

  static String resolveAnimalAsset(String raw) {
    if (raw.startsWith('assets/')) return raw;
    final clean = raw.replaceAll(RegExp(r'^\d+_'), '');
    return 'assets/avatars/$clean.webp';
  }

  static String? resolveAccessoryAsset(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'none') return null;
    if (raw.startsWith('assets/')) return raw;
    return 'assets/accessories/$raw.webp';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double effectiveHeight = height;
        if (constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0 &&
            constraints.maxHeight < height) {
          effectiveHeight = constraints.maxHeight;
        }

        // 774 / 941 ≈ 0.8225 (vintage_frame doğal en/boy oranı)
        final frameWidth = width ?? (effectiveHeight * 0.8225);

        // Oval merkez oranları (hassas koordinatlar):
        final ovalWidth = frameWidth * 0.60;
        final ovalHeight = effectiveHeight * 0.63;
        final ovalLeft = (frameWidth - ovalWidth) / 2;
        final ovalTop = effectiveHeight * 0.22;
        final animalSquareSize = ovalWidth * 1.08;

        final resolvedAnimal = resolveAnimalAsset(animalAsset);
        final resolvedAccessory = resolveAccessoryAsset(accessoryAsset);

        return SizedBox(
          width: frameWidth,
          height: effectiveHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Zemin: Doğal Suluboya Parşömen Dokusu & Çerçeve Tabanı
              Positioned.fill(
                child: Image.asset(
                  AppAssets.vintageFrameParchment,
                  fit: BoxFit.contain,
                  cacheHeight: (effectiveHeight * 2.5).round(),
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

              // 3. Karakter Hayvan & Aksesuar Katmanı (Kusursuz 1:1 Doğal Kare Oranı)
              Positioned(
                left: ovalLeft,
                top: ovalTop,
                width: ovalWidth,
                height: ovalHeight,
                child: ClipOval(
                  child: Align(
                    alignment: const Alignment(0.0, 0.20),
                    child: SizedBox(
                      width: animalSquareSize,
                      height: animalSquareSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            resolvedAnimal,
                            width: animalSquareSize,
                            height: animalSquareSize,
                            fit: BoxFit.contain,
                            cacheHeight: (animalSquareSize * 2.5).round(),
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, size: 28, color: Color(0xFF9E8D86)),
                          ),
                          if (resolvedAccessory != null)
                            Image.asset(
                              resolvedAccessory,
                              width: animalSquareSize,
                              height: animalSquareSize,
                              fit: BoxFit.contain,
                              cacheHeight: (animalSquareSize * 2.5).round(),
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Üst Katman: Oymalı Altın Rim & Kurdele (Avatarın kenarlarını çerçeve içine gömer)
              Positioned.fill(
                child: Image.asset(
                  AppAssets.vintageFrameOverlay,
                  fit: BoxFit.contain,
                  cacheHeight: (effectiveHeight * 2.5).round(),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
