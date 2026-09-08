import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../widgets/bouncing_widget.dart';

/// 📜 Yasal Belge Sekmeleri
enum LegalTab {
  privacy,
  terms,
}

/// ⚖️ Calenda — Profesyonel ve Net Yasal Bilgilendirme Sayfası
class LegalPolicySheet extends StatefulWidget {
  final LegalTab initialTab;

  const LegalPolicySheet({
    super.key,
    this.initialTab = LegalTab.privacy,
  });

  /// Modal alt sayfayı açar
  static Future<void> show(
    BuildContext context, {
    LegalTab initialTab = LegalTab.privacy,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LegalPolicySheet(initialTab: initialTab),
    );
  }

  @override
  State<LegalPolicySheet> createState() => _LegalPolicySheetState();
}

class _LegalPolicySheetState extends State<LegalPolicySheet> {
  late LegalTab _currentTab;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _switchTab(LegalTab tab) {
    if (_currentTab != tab) {
      setState(() => _currentTab = tab);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌿 Calenda Soft Matcha & Adaçayı Yeşili Minimalist Renk Paleti
    const titleColor = Color(0xFF1B3B26);
    const subtitleColor = Color(0xFF4E6B56);
    const sheetBg = Color(0xFFFAFBF9);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Tutamaç (Drag Handle) ──
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCDACC),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Üst Başlık & Kapat Butonu ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Yasal Bilgilendirme',
                      style: AppTypography.sfProRounded(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  BouncingWidget(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDDE7DC), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: titleColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Sekme Değiştirici (Sol: Gizlilik Politikası, Sağ: Kullanım Koşulları) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCE8DB), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Gizlilik Politikası',
                        icon: Icons.shield_outlined,
                        isSelected: _currentTab == LegalTab.privacy,
                        onTap: () => _switchTab(LegalTab.privacy),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Kullanım Koşulları',
                        icon: Icons.description_outlined,
                        isSelected: _currentTab == LegalTab.terms,
                        onTap: () => _switchTab(LegalTab.terms),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Kaydırılabilir İçerik Alanı ──
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
                child: _currentTab == LegalTab.privacy
                    ? _buildPrivacyContent(titleColor, subtitleColor)
                    : _buildTermsContent(titleColor, subtitleColor),
              ),
            ),

            // ── Alt Kısım: Aksiyon Butonu & İletişim ──
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: const BoxDecoration(
                color: sheetBg,
                border: Border(
                  top: BorderSide(color: Color(0xFFEAEFE7), width: 1.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BouncingWidget(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF244E33),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF244E33).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Anladım ve Kabul Ediyorum',
                          style: AppTypography.sfProRounded(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Destek ve Hukuki İletişim: calenda.support@gmail.com',
                    style: AppTypography.sfPro(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF869B8B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF234B30);
    const inactiveColor = Color(0xFF6E8876);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: isSelected
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3F2B).withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sfProRounded(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🛡️ GİZLİLİK POLİTİKASI (PRIVACY POLICY)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPrivacyContent(Color titleColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightCard(
          icon: Icons.lock_outline_rounded,
          title: 'Gizlilik ve Veri Güvenliği',
          description:
              'Kişisel verileriniz asla üçüncü taraflara satılmaz veya kiralanmaz. Calenda içerisinde reklam ağı veya kullanıcı izleme (tracking) mekanizması bulunmaz.',
          accentColor: const Color(0xFF235A43),
          bgColor: const Color(0xFFF0F8F4),
          borderColor: const Color(0xFFCEE7DB),
        ),

        const SizedBox(height: 18),

        _buildSection(
          number: '1',
          title: 'Veri Sorumlusu ve Kapsam',
          content:
              'Calenda, kullanıcı gizliliğini ve veri güvenliğini ön planda tutar. Bu politika; 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve uluslararası veri koruma düzenlemeleri (GDPR) uyarınca verilerinizin toplanma, işlenme ve korunma esaslarını açıklar.',
        ),

        _buildSection(
          number: '2',
          title: 'Toplanan Veriler',
          content:
              '• Hesap Bilgileri: Kayıt ve giriş için kullanılan ad, soyad, kullanıcı adı ve e-posta adresi (Apple, Google veya e-posta girişi).\n'
              '• Plan ve Ajanda Verileri: Oluşturduğunuz etkinlikler, ders programları, başlangıç/bitiş saatleri, renk kodları ve kişisel notlar.\n'
              '• Rutinler ve Odak Sayaçları: Belirlediğiniz alışkanlıklar, odaklanma süreleri ve kulüp oturum kayıtları.\n'
              '• Profil Tercihleri: Seçtiğiniz avatar, arayüz teması ve isteğe bağlı doğum tarihi.\n'
              '• Teknik Bilgiler: Hizmet kararlılığını sağlamak ve çökmeleri gidermek için kullanılan anonim donanım ve işletim sistemi sürüm bilgisi.',
        ),

        _buildSection(
          number: '3',
          title: 'Verilerin İşlenme Amaçları',
          content:
              'Verileriniz yalnızca şu amaçlarla işlenir:\n'
              '• Kişisel ajanda, planlama ve odaklanma servislerini sunmak,\n'
              '• Verilerinizi cihazlarınız arasında güvenle senkronize etmek,\n'
              '• Belirlediğiniz planlara ait yerel bildirim ve hatırlatıcıları iletmek,\n'
              '• Odak kulüplerinde çalışma durumunu diğer üyelerle paylaşmak,\n'
              '• Destek taleplerinizi yanıtlamak ve teknik aksaklıkları gidermek.',
        ),

        _buildSection(
          number: '4',
          title: 'Veri Paylaşımı ve Altyapı',
          content:
              'Kişisel verileriniz hiçbir reklam verenle paylaşılmaz ve ticarileştirilmez. Verileriniz, uygulamanın çalışması için gerekli olan güvenli bulut veri tabanında (Supabase) şifreli olarak saklanır ve kimlik doğrulama altyapısı (Apple, Google) üzerinden korunur. Yasal zorunluluklar haricinde üçüncü şahıslara aktarılmaz.',
        ),

        _buildSection(
          number: '5',
          title: 'Veri Güvenliği Standartları',
          content:
              'Cihazınız ile sunucu arasındaki tüm iletişim TLS/SSL ile şifrelenir. Veritabanı düzeyinde Satır Düzeyinde Güvenlik (Row Level Security) kuralları uygulanır; verilerinize yalnızca kendi hesabınız erişebilir. Oturum belirteçleri cihazın güvenli donanım kasasında saklanır.',
        ),

        _buildSection(
          number: '6',
          title: 'Kullanıcı Hakları ve Verileri Kalıcı Silme',
          content:
              'Dilediğiniz an verilerinizin durumunu öğrenme, güncelleme veya silinmesini talep etme hakkına sahipsiniz.\n\n'
              'Profil > Ayarlar bölümünden "Hesabı ve Tüm Verileri Sil" seçeneğini kullanarak hesabınızı, planlarınızı ve buluttaki tüm kayıtlarınızı tek dokunuşla kalıcı ve geri döndürülemez şekilde anında silebilirsiniz.',
        ),

        _buildSection(
          number: '7',
          title: 'İletişim',
          content:
              'Gizlilik politikası ve kişisel verilerinizle ilgili her türlü soru için destek ekibimize ulaşabilirsiniz:\n\n'
              'E-posta: calenda.support@gmail.com',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📜 KULLANIM KOŞULLARI (TERMS OF SERVICE)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTermsContent(Color titleColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightCard(
          icon: Icons.verified_user_outlined,
          title: 'Hizmet Şartları ve Kullanım Esasları',
          description:
              'Calenda uygulamasını indirerek, hesap oluşturarak veya kullanarak işbu Kullanım Koşulları\'nı kabul etmiş sayılırsınız.',
          accentColor: const Color(0xFF244E33),
          bgColor: const Color(0xFFF1F7F1),
          borderColor: const Color(0xFFD4E7D6),
        ),

        const SizedBox(height: 18),

        _buildSection(
          number: '1',
          title: 'Hizmetin Kapsamı',
          content:
              'Calenda; haftalık planlama, ders takvimi, alışkanlık takibi, odaklanma sayacı ve topluluk kulüpleri sunan bireysel bir dijital ajanda uygulamasıdır. Hizmet kişisel kullanım amacıyla sunulmaktadır.',
        ),

        _buildSection(
          number: '2',
          title: 'Hesap Güvenliği ve Kullanıcı Sorumluluğu',
          content:
              'Hesabınızın ve cihazınızın güvenliğini sağlamak sizin sorumluluğunuzdadır. Küfür, nefret söylemi veya başkalarının haklarını ihlal eden kullanıcı adları önceden bildirilmeksizin askıya alınabilir veya değiştirilebilir.',
        ),

        _buildSection(
          number: '3',
          title: 'Kullanıcı İçerikleri ve Mülkiyet',
          content:
              'Calenda\'ya eklediğiniz dersler, planlar, hedefler ve notlar tamamen size aittir. Calenda, kullanıcı içerikleri üzerinde mülkiyet iddiasında bulunmaz; içeriklerinizi yalnızca hizmeti sunmak ve senkronize etmek için işler.',
        ),

        _buildSection(
          number: '4',
          title: 'Fikri Mülkiyet Hakları',
          content:
              'Calenda adı, uygulama logosu, arayüz tasarımları, karakter çizimleri ve kaynak kodları Calenda\'nın mülkiyetindedir. Uygulamanın izinsiz kopyalanması, çoğaltılması veya tersine mühendisliğe tabi tutulması yasaktır.',
        ),

        _buildSection(
          number: '5',
          title: 'Kabul Edilebilir Kullanım',
          content:
              'Kullanıcılar; uygulama altyapısını bozacak veya sunucu güvenliğini tehlikeye atacak eylemlerde bulunmayacağını, ortak odak kulüplerinde diğer üyeleri rahatsız edici içerikler paylaşmayacağını taahhüt eder.',
        ),

        _buildSection(
          number: '6',
          title: 'Hizmet Sürekliliği ve Sorumluluk',
          content:
              'Calenda çevrimdışı-öncelikli çalışır; internet bağlantınız olmasa da planlarınıza erişebilirsiniz. Hizmetin kesintisiz sunulması için gereken özen gösterilmekle birlikte, teknik aksaklıklardan doğabilecek durumlarda sorumluluk yasaların izin verdiği ölçüde sınırlandırılmıştır.',
        ),

        _buildSection(
          number: '7',
          title: 'Koşullarda Değişiklik ve İletişim',
          content:
              'Calenda, kullanım koşullarını güncelleyebilir. Değişiklikler uygulama üzerinden duyurulur. Her türlü soru ve bildirim için bizimle iletişime geçebilirsiniz:\n\n'
              'E-posta: calenda.support@gmail.com',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 YARDIMCI GÖRSEL BİLEŞENLER
  // ─────────────────────────────────────────────────────────────

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.sfProRounded(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.sfPro(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF415647),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
  }) {
    const titleColor = Color(0xFF1B3B26);
    const subtitleColor = Color(0xFF4E6B56);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EDE2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: AppTypography.sfProRounded(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.sfProRounded(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              content,
              style: AppTypography.sfPro(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
