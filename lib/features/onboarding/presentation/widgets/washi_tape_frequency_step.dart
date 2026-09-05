import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/aesthetic_planner_button.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../models/onboarding_state.dart';

/// 📌 Not Verisi Modeli (Oransal Konumlandırma, Boyut & Açı)
class _StickyNoteData {
  final String title;
  final String image;
  double leftPercent;
  double topPercent;
  double widthPercent;
  double heightPercent;
  double angle; // radyan cinsinden

  _StickyNoteData({
    required this.title,
    required this.image,
    required this.leftPercent,
    required this.topPercent,
    required this.widthPercent,
    required this.heightPercent,
    required this.angle,
  });

  _StickyNoteData copy() => _StickyNoteData(
        title: title,
        image: image,
        leftPercent: leftPercent,
        topPercent: topPercent,
        widthPercent: widthPercent,
        heightPercent: heightPercent,
        angle: angle,
      );
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
  /// 🎨 Varsayılan 7 Not Şablonu
  static List<_StickyNoteData> _getDefaultNotes() => [
        _StickyNoteData(
          title: '1. Sarı (Pzt)',
          image: 'yellow_note.png',
          leftPercent: 0.07,
          topPercent: 0.07,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: -0.06,
        ),
        _StickyNoteData(
          title: '2. Pembe (Sal)',
          image: 'pink_note.png',
          leftPercent: 0.39,
          topPercent: 0.06,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: 0.04,
        ),
        _StickyNoteData(
          title: '3. Yeşil (Çar)',
          image: 'green_note.png',
          leftPercent: 0.71,
          topPercent: 0.07,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: -0.04,
        ),
        _StickyNoteData(
          title: '4. Mavi (Per)',
          image: 'blue_note.png',
          leftPercent: 0.07,
          topPercent: 0.42,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: 0.05,
        ),
        _StickyNoteData(
          title: '5. Mor (Cum)',
          image: 'purple_note.png',
          leftPercent: 0.71,
          topPercent: 0.42,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: -0.05,
        ),
        _StickyNoteData(
          title: '6. Turuncu (Cmt)',
          image: 'orange_note.png',
          leftPercent: 0.23,
          topPercent: 0.57,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: -0.03,
        ),
        _StickyNoteData(
          title: '7. Lila (Paz)',
          image: 'purple2_note.png',
          leftPercent: 0.55,
          topPercent: 0.56,
          widthPercent: 0.22,
          heightPercent: 0.35,
          angle: 0.04,
        ),
      ];

  late List<_StickyNoteData> _notes;
  bool _isDesignMode = false;
  bool _isInteractingWithBoard = false;
  int _selectedNoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _notes = _getDefaultNotes();
  }

  void _resetNotes() {
    HapticFeedback.mediumImpact();
    setState(() {
      _notes = _getDefaultNotes();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not konumları varsayılana sıfırlandı.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _decrement() {
    if (widget.state.weeklyGoalDays > 0) {
      HapticFeedback.lightImpact();
      setState(() => widget.state.weeklyGoalDays--);
    }
  }

  void _increment() {
    if (widget.state.weeklyGoalDays < 7) {
      HapticFeedback.lightImpact();
      setState(() => widget.state.weeklyGoalDays++);
    }
  }

  void _nudge({double dx = 0.0, double dy = 0.0}) {
    HapticFeedback.selectionClick();
    setState(() {
      final note = _notes[_selectedNoteIndex];
      note.leftPercent = (note.leftPercent + dx).clamp(0.01, 0.99 - note.widthPercent);
      note.topPercent = (note.topPercent + dy).clamp(0.01, 0.99 - note.heightPercent);
    });
  }

  void _copyCoordinatesToClipboard() {
    final buffer = StringBuffer();
    buffer.writeln('// 📌 Mantar Pano Not Koordinatları:');
    for (int i = 0; i < _notes.length; i++) {
      final n = _notes[i];
      final deg = (n.angle * 180 / math.pi).toStringAsFixed(1);
      buffer.writeln(
        '// ${n.title} -> sol: %${(n.leftPercent * 100).toStringAsFixed(1)}, üst: %${(n.topPercent * 100).toStringAsFixed(1)}, genişlik: %${(n.widthPercent * 100).toStringAsFixed(1)}, açı: $deg°',
      );
    }
    buffer.writeln('\nstatic const List<_StickyNoteData> _notes = [');
    for (int i = 0; i < _notes.length; i++) {
      final n = _notes[i];
      buffer.writeln('  _StickyNoteData(');
      buffer.writeln("    title: '${n.title}',");
      buffer.writeln("    image: '${n.image}',");
      buffer.writeln('    leftPercent: ${n.leftPercent.toStringAsFixed(3)},');
      buffer.writeln('    topPercent: ${n.topPercent.toStringAsFixed(3)},');
      buffer.writeln('    widthPercent: ${n.widthPercent.toStringAsFixed(3)},');
      buffer.writeln('    heightPercent: ${n.heightPercent.toStringAsFixed(3)},');
      buffer.writeln('    angle: ${n.angle.toStringAsFixed(3)},');
      buffer.writeln('  ),');
    }
    buffer.writeln('];');

    final text = buffer.toString();
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Koordinatlar Kopyalandı!',
                      style: AppTypography.sfProRounded(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A2B33),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Aşağıdaki koordinat bilgisi panonuza kopyalandı. Direkt bana mesaj olarak yapıştırabilirsiniz:',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.3),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5DDD5)),
              ),
              constraints: const BoxConstraints(maxHeight: 180),
              child: SingleChildScrollView(
                child: SelectableText(
                  text,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AestheticPlannerButton(
              text: 'Tamam',
              height: 46,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
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

    return SingleChildScrollView(
      physics: (_isDesignMode && _isInteractingWithBoard)
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Soru Başlığı ──
            Text(
              _isDesignMode ? 'Notları Dilediğince Yerleştir' : 'Haftalık planlama ritmini bul',
              textAlign: TextAlign.center,
              style: AppTypography.sfProRounded(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _isDesignMode
                  ? 'Notları parmağınla sürükle, eğim ve boyutlarını ayarla.'
                  : 'Haftada kaç gün odaklanma veya ders çalışmayı hedefliyorsun?',
              textAlign: TextAlign.center,
              style: AppTypography.sfPro(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // ── 🛠️ TASARIM MODU AÇ/KAPA BUTONU ──
            Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isDesignMode = !_isDesignMode);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isDesignMode ? const Color(0xFF0E260A) : const Color(0xFFF2EAE5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isDesignMode ? const Color(0xFF0E260A) : const Color(0xFFD5C4BC),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDesignMode ? Icons.check_circle_rounded : Icons.tune_rounded,
                        size: 16,
                        color: _isDesignMode ? Colors.white : titleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isDesignMode ? 'Tasarımı Bitir & Önizle' : 'Tasarım Modu (Sürükle-Bırak)',
                        style: AppTypography.sfPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isDesignMode ? Colors.white : titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

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

                        return Listener(
                          onPointerDown: (_) {
                            if (_isDesignMode) {
                              setState(() => _isInteractingWithBoard = true);
                            }
                          },
                          onPointerUp: (_) {
                            if (_isDesignMode) {
                              setState(() => _isInteractingWithBoard = false);
                            }
                          },
                          onPointerCancel: (_) {
                            if (_isDesignMode) {
                              setState(() => _isInteractingWithBoard = false);
                            }
                          },
                          child: Stack(
                            children: [
                              // 1. Mantar Pano Temel Arka Planı (Doğal ahşap çerçeve)
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/cork_board.png',
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD7A779),
                                      border: Border.all(color: const Color(0xFFB57D4F), width: 8),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),

                              // 2. Notlar (Tasarım modunda hepsi görünür ve sürüklenebilir)
                              for (int i = 0; i < _notes.length; i++)
                                _buildStickyNote(
                                  index: i,
                                  visible: _isDesignMode || days > i,
                                  boardWidth: boardWidth,
                                  boardHeight: boardHeight,
                                  data: _notes[i],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── TASARIM MODU KONTROL PANELİ VEYA NORMAL SAYAÇ ──
            if (_isDesignMode)
              _buildDesignModeControls()
            else ...[
              // ── [-] ve [+] Sayaç Kontrolü ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BouncingWidget(
                    onTap: _decrement,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.remove_rounded, size: 24, color: titleColor),
                    ),
                  ),

                  const SizedBox(width: 24),

                  SizedBox(
                    width: 150,
                    child: Text(
                      days == 0 ? 'Serbest Mod' : '$days gün',
                      textAlign: TextAlign.center,
                      style: AppTypography.sfProRounded(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  BouncingWidget(
                    onTap: _increment,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, size: 24, color: titleColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Sabit Yükseklikli Ritim Açıklama Metni ──
              SizedBox(
                height: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getRhythmDescription(days),
                    key: ValueKey('rhythm_$days'),
                    textAlign: TextAlign.center,
                    style: AppTypography.sfPro(
                      fontSize: 12.5,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Devam Et Butonu ──
              AestheticPlannerButton(
                text: 'Devam Et',
                height: 52,
                onPressed: widget.onNext,
              ),

              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  /// 🛠️ Tasarım Modu Kontrol Paneli (Seçim Chip'leri, Yön Tuşları, Açı, Boyut, Kopyalama)
  Widget _buildDesignModeControls() {
    final selectedNote = _notes[_selectedNoteIndex];
    final angleDeg = (selectedNote.angle * 180 / math.pi);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFECE4DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Not Seçim Çubuğu (Yatay Kaydırma)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_notes.length, (index) {
                final isSelected = index == _selectedNoteIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedNoteIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0E260A) : const Color(0xFFF7F3EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0E260A) : const Color(0xFFE2D9D0),
                        ),
                      ),
                      child: Text(
                        _notes[index].title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF4A2B33),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Seçili Not & Hassas Yön Tuşları (Nudge D-Pad)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seçili: ${selectedNote.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2B33),
                  ),
                ),
              ),
              // Hassas Yön Butonları (1% kaydırır)
              _buildNudgeButton(Icons.arrow_back_rounded, () => _nudge(dx: -0.01)),
              const SizedBox(width: 4),
              _buildNudgeButton(Icons.arrow_upward_rounded, () => _nudge(dy: -0.01)),
              const SizedBox(width: 4),
              _buildNudgeButton(Icons.arrow_downward_rounded, () => _nudge(dy: 0.01)),
              const SizedBox(width: 4),
              _buildNudgeButton(Icons.arrow_forward_rounded, () => _nudge(dx: 0.01)),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Eğim (Açı) Kaydırıcısı
          Row(
            children: [
              const Icon(Icons.rotate_left_rounded, size: 18, color: Color(0xFF7A5861)),
              const SizedBox(width: 6),
              const Text('Açı:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: selectedNote.angle.clamp(-0.35, 0.35),
                    min: -0.35,
                    max: 0.35,
                    activeColor: const Color(0xFF0E260A),
                    inactiveColor: const Color(0xFFE2D9D0),
                    onChanged: (val) {
                      setState(() => selectedNote.angle = val);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${angleDeg.toStringAsFixed(1)}°',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // 4. Boyut (Genişlik) Kaydırıcısı
          Row(
            children: [
              const Icon(Icons.aspect_ratio_rounded, size: 18, color: Color(0xFF7A5861)),
              const SizedBox(width: 6),
              const Text('Boyut:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: selectedNote.widthPercent.clamp(0.16, 0.35),
                    min: 0.16,
                    max: 0.35,
                    activeColor: const Color(0xFF0E260A),
                    inactiveColor: const Color(0xFFE2D9D0),
                    onChanged: (val) {
                      setState(() {
                        selectedNote.widthPercent = val;
                        selectedNote.heightPercent = val * 1.59;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '%${(selectedNote.widthPercent * 100).toStringAsFixed(0)}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 5. Aksiyon Butonları: Koordinatları Kopyala & Sıfırla
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AestheticPlannerButton(
                  text: '📋 Koordinatları Kopyala',
                  height: 44,
                  onPressed: _copyCoordinatesToClipboard,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _resetNotes,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFFD5C4BC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text(
                    'Sıfırla',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A5861), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNudgeButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EAE5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD5C4BC)),
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF4A2B33)),
      ),
    );
  }

  /// 📝 Yapışarak Eklenen Estetik Post-it Notu
  Widget _buildStickyNote({
    required int index,
    required bool visible,
    required double boardWidth,
    required double boardHeight,
    required _StickyNoteData data,
  }) {
    final isSelected = _isDesignMode && _selectedNoteIndex == index;

    Widget noteWidget = Transform.rotate(
      angle: data.angle,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0xFF0E260A), width: 2)
              : null,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0E260A).withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Image.asset(
          'assets/images/${data.image}',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );

    if (_isDesignMode) {
      noteWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedNoteIndex = index);
        },
        onPanStart: (_) {
          HapticFeedback.selectionClick();
          setState(() => _selectedNoteIndex = index);
        },
        onPanUpdate: (details) {
          setState(() {
            final dx = details.delta.dx / boardWidth;
            final dy = details.delta.dy / boardHeight;
            data.leftPercent = (data.leftPercent + dx).clamp(0.01, 0.99 - data.widthPercent);
            data.topPercent = (data.topPercent + dy).clamp(0.01, 0.99 - data.heightPercent);
          });
        },
        child: noteWidget,
      );
    }

    return Positioned(
      left: data.leftPercent * boardWidth,
      top: data.topPercent * boardHeight,
      width: data.widthPercent * boardWidth,
      height: data.heightPercent * boardHeight,
      child: AnimatedScale(
        duration: Duration(milliseconds: _isDesignMode ? 0 : (visible ? 280 : 180)),
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        scale: visible ? 1.0 : 0.0,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: _isDesignMode ? 0 : 200),
          curve: Curves.easeOut,
          opacity: visible ? 1.0 : 0.0,
          child: noteWidget,
        ),
      ),
    );
  }
}
