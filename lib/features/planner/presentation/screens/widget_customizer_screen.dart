import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/planner_provider.dart';

/// Ana Ekran Widget Görünümü ve Şeffaflık Özelleştirici Ekranı
class WidgetCustomizerScreen extends StatefulWidget {
  const WidgetCustomizerScreen({super.key});

  @override
  State<WidgetCustomizerScreen> createState() => _WidgetCustomizerScreenState();
}

class _WidgetCustomizerScreenState extends State<WidgetCustomizerScreen> {
  late double _opacity;
  late String _titleText;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final config = context.read<PlannerProvider>().themeConfig;
    _opacity = config.backgroundOpacity;
    _titleText = config.titleText.isEmpty ? 'Bugünün Planı' : config.titleText;
    _titleController = TextEditingController(text: _titleText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    final provider = context.read<PlannerProvider>();
    final title = _limitText(_titleController.text, 40);
    final newConfig = provider.themeConfig.copyWith(
      backgroundOpacity: _opacity.clamp(0.0, 0.8).toDouble(),
      titleText: title.isEmpty ? 'Bugünün Planı' : title,
    );
    provider.updateThemeConfig(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Widget ayarları güncellendi ✨'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _limitText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        final todayEvents = provider.currentDayEvents;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Widget Görünümü',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Uygula', style: TextStyle(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // ─── 1. CANLI ÖNİZLEME KARTI (Duvar Kağıdı Üzerinde) ───
              Text(
                'Canlı Önizleme',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  // Arka plan simülasyonu (Estetik degrade duvar kağıdı)
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE0E7FF),
                      Color(0xFFFCE7F3),
                      Color(0xFFEDE9FE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: _opacity),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _titleText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Planlayıcı',
                                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Örnek Liste
                        if (todayEvents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Bugün için plan bulunmuyor ✨',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          )
                        else
                          ...todayEvents.take(3).map((e) {
                            final color = AppColors.hexToColor(e.colorHex);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3.5,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            shadows: [
                                              Shadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 1)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          e.formattedTimeRange,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 1)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── 2. ŞEFFAFLIK AYARI ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Arka Plan Şeffaflığı',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _opacity == 0.0 ? '%100 Şeffaf' : '%${((1.0 - _opacity) * 100).toInt()} Şeffaf',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _opacity,
                      min: 0.0,
                      max: 0.8,
                      divisions: 8,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _opacity = val);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tam Şeffaf (0%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        Text(
                          'Koyu Gölgeli (80%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── 3. WIDGET BAŞLIK YAZISI ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Widget Başlık Metni',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: Bugünün Planı, Günlük Akış',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _titleText = val.isEmpty ? 'Bugünün Planı' : val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
