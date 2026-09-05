import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 📌 Not Verisi Modeli (Oransal Konumlandırma, Boyut & Açı)
class _StickyNoteData {
  final String image;
  final double leftPercent;
  final double topPercent;
  final double widthPercent;
  final double heightPercent;
  final double angle;

  const _StickyNoteData({
    required this.image,
    required this.leftPercent,
    required this.topPercent,
    required this.widthPercent,
    required this.heightPercent,
    required this.angle,
  });
}

/// 📌 Adım 1: Mantar Pano ve Yapışkanlı Notlar (Cork Board Pinboard)
class WashiTapeFrequencyStep extends StatefulWidget {
  final OnboardingState state;
  final VoidCallback onNext;

  const WashiTapeFrequencyStep({
    super.key,
    required this.state,
    required this.onNext,
  });

  @override
  State<WashiTapeFrequencyStep> createState() => _WashiTapeFrequencyStepState();
}

class _WashiTapeFrequencyStepState extends State<WashiTapeFrequencyStep> {
  /// 🎨 Kullanıcının Özel Belirlediği Estetik 7 Not Düzeni
  static const List<_StickyNoteData> _notes = [
    // 1. Gün: Üst Sol (Sarı Not)
    _StickyNoteData(
      image: 'yellow_note.webp',
      leftPercent: 0.091,
      topPercent: 0.133,
      widthPercent: 0.189,
      heightPercent: 0.301,
      angle: -0.038,
    ),
    // 2. Gün: Üst Orta (Pembe Not)
    _StickyNoteData(
      image: 'pink_note.webp',
      leftPercent: 0.329,
      topPercent: 0.197,
      widthPercent: 0.194,
      heightPercent: 0.309,
      angle: 0.113,
    ),
    // 3. Gün: Üst Sağ (Yeşil Not)
    _StickyNoteData(
      image: 'green_note.webp',
      leftPercent: 0.689,
      topPercent: 0.163,
      widthPercent: 0.189,
      heightPercent: 0.301,
      angle: -0.107,
    ),
    // 4. Gün: Orta Sol (Mavi Not)
    _StickyNoteData(
      image: 'blue_note.webp',
      leftPercent: 0.082,
      topPercent: 0.464,
      widthPercent: 0.191,
      heightPercent: 0.303,
      angle: 0.104,
    ),
    // 5. Gün: Sağ Alt (Mor Not)
    _StickyNoteData(
      image: 'purple_note.webp',
      leftPercent: 0.713,
      topPercent: 0.552,
      widthPercent: 0.191,
      heightPercent: 0.303,
      angle: 0.019,
    ),
    // 6. Gün: Orta Sağ (Turuncu Not)
    _StickyNoteData(
      image: 'orange_note.webp',
      leftPercent: 0.523,
      topPercent: 0.399,
      widthPercent: 0.186,
      heightPercent: 0.295,
      angle: 0.088,
    ),
    // 7. Gün: Alt Sol-Orta (Lila Not)
    _StickyNoteData(
      image: 'lilac_note.webp',
      leftPercent: 0.297,
      topPercent: 0.580,
      widthPercent: 0.191,
      heightPercent: 0.303,
      angle: -0.021,
    ),
  ];

  bool _stepPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_stepPrecached) {
      _stepPrecached = true;
      // 🚀 Pano ve notları anında GPU belleğine alarak sıfır gecikmeyle göster
      precacheImage(const AssetImage(AppAssets.corkBoard), context);
      for (final n in _notes) {
        precacheImage(AssetImage('${AppAssets.notesPath}${n.image}'), context);
      }
    }
  }

  String _getRhythmDescription(int days) {
    switch (days) {
      case 0:
        return 'Herhangi bir hedef baskısı olmadan dilediğin zaman serbestçe plan yaparsın.';
      case 1:
      case 2:
        return 'Haftayı hafif ve sakin bir başlangıçla keşfet.';
      case 3:
      case 4:
        return 'Dengeli ve sürdürülebilir ideal bir haftalık ritim.';
      case 5:
        return 'Hafta içi odaklanma, hafta sonu hak edilmiş dinlenme!';
      case 6:
      case 7:
        return 'Yüksek verimlilik ve güçlü bir odaklanma hedefi!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);

    final days = widget.state.weeklyGoalDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Soru Başlığı ──
          Text(
            'Haftalık planlama ritmini bul',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Haftada kaç gün odaklanma veya ders çalışmayı hedefliyorsun?',
            textAlign: TextAlign.center,
            style: AppTypography.sfPro(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.35,
            ),
          ),

          const Spacer(flex: 1),

          // ── 📌 MANTAR PANO VE GERÇEK YAPIŞKANLI NOTLAR (CORK PINBOARD) ──
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350, maxHeight: 230),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B33).withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.60,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boardWidth = constraints.maxWidth;
                      final boardHeight = constraints.maxHeight;

                      return Stack(
                        children: [
                          // 0. Anında Görünen Mantar Zemin (Görsel çözülürken boşluk veya beyazlık oluşmasını %100 engeller)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7A779),
                                border: Border.all(color: const Color(0xFFB57D4F), width: 8),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),

                          // 1. Mantar Pano Temel Arka Planı (Doğal ahşap çerçeve & optimize 800px görsel)
                          Positioned.fill(
                            child: Image.asset(
                              AppAssets.corkBoard,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),

                          // 2. Sırayla Yapışarak Eklenen 7 Özel Post-it Notu
                          for (int i = 0; i < _notes.length; i++)
                            _buildStickyNote(
                              visible: days > i,
                              boardWidth: boardWidth,
                              boardHeight: boardHeight,
                              data: _notes[i],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Seçilen Gün Başlığı ──
          Text(
            days == 0 ? 'Serbest Mod' : 'Haftada $days Gün',
            textAlign: TextAlign.center,
            style: AppTypography.sfProRounded(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),

          const SizedBox(height: 14),

          // ── 🍃 Serbest Mod + 7 Gün Baloncukları (8 Çip) ──
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🍃 0. Çip: Serbest Mod (Hedefsiz)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  child: Tooltip(
                    message: 'Serbest Mod (Hedefsiz)',
                    child: BouncingWidget(
                      scaleFactor: 0.88,
                      onTap: () {
                        AppHaptics.lightImpact();
                        setState(() => widget.state.weeklyGoalDays = 0);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: days == 0
                              ? const Color(0xFFE6ABA7)
                              : Colors.white,
                          border: Border.all(
                            color: days == 0
                                ? const Color(0xFFD48B86)
                                : const Color(0xFFE8DDD7),
                            width: days == 0 ? 2.2 : 1.2,
                          ),
                          boxShadow: [
                            if (days == 0)
                              BoxShadow(
                                color: const Color(0xFFE6ABA7).withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.spa_rounded,
                          size: 19,
                          color: days == 0 ? Colors.white : const Color(0xFFA58E94),
                        ),
                      ),
                    ),
                  ),
                ),

                // 1-7 Gün Çipleri
                ...List.generate(7, (index) {
                  final d = index + 1;
                  final isExact = days == d;
                  final isInRange = days > 0 && d <= days;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: BouncingWidget(
                      scaleFactor: 0.88,
                      onTap: () {
                        AppHaptics.lightImpact();
                        setState(() => widget.state.weeklyGoalDays = d);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isExact
                              ? const Color(0xFFE6ABA7)
                              : (isInRange
                                  ? const Color(0xFFF9EFEB)
                                  : Colors.white),
                          border: Border.all(
                            color: isExact
                                ? const Color(0xFFD48B86)
                                : (isInRange
                                    ? const Color(0xFFECCFCB)
                                    : const Color(0xFFE8DDD7)),
                            width: isExact ? 2.2 : 1.2,
                          ),
                          boxShadow: [
                            if (isExact)
                              BoxShadow(
                                color: const Color(0xFFE6ABA7).withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$d',
                          style: AppTypography.sfProRounded(
                            fontSize: 16,
                            fontWeight: isExact
                                ? FontWeight.w800
                                : (isInRange ? FontWeight.w700 : FontWeight.w600),
                            color: isExact
                                ? Colors.white
                                : (isInRange
                                    ? const Color(0xFF6E3E47)
                                    : const Color(0xFFA58E94)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Sabit Yükseklikli Ritim Açıklama Metni ──
          SizedBox(
            height: 38,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _getRhythmDescription(days),
                key: ValueKey('rhythm_$days'),
                textAlign: TextAlign.center,
                style: AppTypography.sfPro(
                  fontSize: 13,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // ── Devam Et Butonu ──
          AestheticPlannerButton(
            text: 'Devam Et',
            height: 52,
            onPressed: widget.onNext,
          ),

          const SizedBox(height: 44),
        ],
      ),
    );
  }

  /// 📝 Yapışarak Eklenen Estetik Post-it Notu (Yaylanarak Açılma & Kapanma)
  Widget _buildStickyNote({
    required bool visible,
    required double boardWidth,
    required double boardHeight,
    required _StickyNoteData data,
  }) {
    return Positioned(
      left: data.leftPercent * boardWidth,
      top: data.topPercent * boardHeight,
      width: data.widthPercent * boardWidth,
      height: data.heightPercent * boardHeight,
      child: AnimatedScale(
        duration: Duration(milliseconds: visible ? 280 : 180),
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        scale: visible ? 1.0 : 0.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: visible ? 1.0 : 0.0,
          child: Transform.rotate(
            angle: data.angle,
            child: Image.asset(
              '${AppAssets.notesPath}${data.image}',
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
