import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../widgets/bouncing_widget.dart';

/// 📜 Yasal Belge Sekmeleri
enum LegalTab {
  terms,
  privacy,
}

/// ⚖️ Calenda — App Store & Google Play Uyumlu Profesyonel Yasal Bilgilendirme Sayfası
///
/// Apple App Store İnceleme Kılavuzları (5.1.1, 5.1.2, EULA) ve
/// Google Play Geliştirici Politikaları (Veri Güvenliği, KVKK, GDPR) ile
/// %100 uyumlu Kullanım Koşulları ve Gizlilik Politikası modal alt sayfası.
class LegalPolicySheet extends StatefulWidget {
  final LegalTab initialTab;

  const LegalPolicySheet({
    super.key,
    this.initialTab = LegalTab.terms,
  });

  /// Modal alt sayfayı açar
  static Future<void> show(
    BuildContext context, {
    LegalTab initialTab = LegalTab.terms,
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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF7A5861);
    const sheetBg = Color(0xFFFAF7F2);

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
                  color: const Color(0xFFD6C8BB),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yasal Bilgilendirme',
                          style: AppTypography.sfProRounded(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Son Güncelleme: 1 Eylül 2026 • Sürüm 1.0',
                          style: AppTypography.sfPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA69389),
                          ),
                        ),
                      ],
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
                        border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
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

            // ── Sekme Değiştirici (Segmented Switcher) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Kullanım Koşulları',
                        icon: Icons.description_outlined,
                        isSelected: _currentTab == LegalTab.terms,
                        onTap: () => _switchTab(LegalTab.terms),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Gizlilik Politikası',
                        icon: Icons.shield_outlined,
                        isSelected: _currentTab == LegalTab.privacy,
                        onTap: () => _switchTab(LegalTab.privacy),
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
                child: _currentTab == LegalTab.terms
                    ? _buildTermsContent(titleColor, subtitleColor)
                    : _buildPrivacyContent(titleColor, subtitleColor),
              ),
            ),

            // ── Alt Kısım: Aksiyon Butonu & İletişim ──
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: const BoxDecoration(
                color: sheetBg,
                border: Border(
                  top: BorderSide(color: Color(0xFFEFE8DF), width: 1.2),
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
                        color: titleColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: titleColor.withValues(alpha: 0.25),
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
                  const SizedBox(height: 8),
                  Text(
                    'Resmi Destek ve Hukuki Bildirim: calenda.support@gmail.com',
                    style: AppTypography.sfPro(
                      fontSize: 11.5,
                      color: const Color(0xFFA69389),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFF8A776F),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sfProRounded(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4A2B33) : const Color(0xFF8A776F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📜 KULLANIM KOŞULLARI (TERMS OF SERVICE / EULA)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTermsContent(Color titleColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightCard(
          icon: Icons.verified_user_outlined,
          title: 'Kullanıcı Odaklı & Şeffaf Hizmet Sözleşmesi',
          description:
              'Calenda uygulamasını indirerek, hesap oluşturarak veya kullanarak işbu Kullanım Koşulları\'nı ve Gizlilik Politikası\'nı kabul etmiş sayılırsınız.',
          accentColor: const Color(0xFF3E7E52),
          bgColor: const Color(0xFFF1F8F3),
          borderColor: const Color(0xFFD3EAD8),
        ),

        const SizedBox(height: 18),

        _buildSection(
          number: '1',
          title: 'Hizmetin Tanımı ve Kapsamı',
          content:
              'Calenda; haftalık planlama, ders ve etkinlik takvimi, alışkanlık ve rutin takibi, odaklanma sayacı (Pomodoro ritmi) ve topluluk odak kulüpleri sunan dijital bir kişisel verimlilik uygulamasıdır. Calenda, hizmeti bireysel ve ticari olmayan kişisel kullanımınız için sunar.',
        ),

        _buildSection(
          number: '2',
          title: 'Hesap Oluşturma ve Güvenlik',
          content:
              '• Calenda\'yı Apple ile Giriş Yap (Sign in with Apple), Google ile Giriş Yap veya E-Posta yöntemleriyle kullanabilirsiniz.\n'
              '• Hesabınızın ve cihazınızın güvenliğini sağlamak sizin sorumluluğunuzdadır.\n'
              '• Seçtiğiniz kullanıcı adı küfür, hakaret, nefret söylemi veya üçüncü tarafların tescilli marka haklarını ihlal edemez. Uygunsuz kullanıcı adları Calenda tarafından uyarılmaksızın değiştirilebilir veya askıya alınabilir.',
        ),

        _buildSection(
          number: '3',
          title: 'Kullanıcı İçeriği ve Mülkiyet Hakları',
          content:
              'Calenda\'ya eklediğiniz tüm dersler, planlar, görevler, özel notlar ve rutinler tamamen SİZE aittir.\n\n'
              'Calenda, kullanıcı içerikleri üzerinde hiçbir mülkiyet iddiasında bulunmaz. İçerikleriniz yalnızca size hizmet sağlamak, cihazlarınız arasında senkronize etmek ve bildirimlerinizi iletmek amacıyla güvenli sunucularımızda şifreli olarak işlenir.',
        ),

        _buildSection(
          number: '4',
          title: 'Fikri Mülkiyet ve Telif Hakları',
          content:
              'Calenda adı, uygulama logosu, arayüz tasarımları, kawaii maskot çizimleri (hayvan avatarları ve aksesuarlar), özel renk paletleri, sesler, animasyonlar ve kaynak kodları Calenda\'nın münhasır mülkiyetindedir ve uluslararası telif hakları mevzuatıyla korunmaktadır. Uygulamanın kaynak kodlarını kopyalamak, tersine mühendislik uygulamak veya izinsiz dağıtmak kesinlikle yasaktır.',
        ),

        _buildSection(
          number: '5',
          title: 'Kabul Edilebilir Kullanım ve Kulüp Kuralları',
          content:
              'Kullanıcılar aşağıdaki eylemlerde bulunmayacağını kabul ve taahhüt eder:\n'
              '• Uygulama sunucularını veya ağ altyapısını bozmaya, aşırı yüklemeye veya güvenlik açıklarını istismar etmeye çalışmak.\n'
              '• Ortak odak kulüplerinde spam yapmak, diğer üyelere rahatsızlık vermek veya yasa dışı içerikler paylaşmak.\n'
              '• Başka bir kullanıcının kimliğine bürünmek veya yetkisiz erişim sağlamaya teşebbüs etmek.',
        ),

        _buildSection(
          number: '6',
          title: 'Çevrimdışı Kullanım ve Hizmet Sürekliliği',
          content:
              'Calenda, çevrimdışı-öncelikli (offline-first) mimari ile geliştirilmiştir. İnternet bağlantınız olmadığında dahi planlarınıza erişebilir ve değişiklik yapabilirsiniz. İnternet bağlantısı sağlandığında yerel verileriniz bulut hesabınızla güvenle senkronize edilir. Calenda, planlı bakım veya altyapı güncellemeleri nedeniyle hizmette yaşanabilecek geçici kesintilerden sorumlu tutulamaz.',
        ),

        _buildSection(
          number: '7',
          title: 'Hesap ve Verileri Kalıcı Silme Güvencesi (Apple & Google Mağaza Politikası)',
          content:
              'Apple App Store Kılavuzu 5.1.1(v) ve Google Play Veri Güvenliği kuralları uyarınca; Profil > Ayarlar menüsünden "Hesabı ve Tüm Verileri Sil" seçeneğini kullanarak dilediğiniz an tek bir dokunuşla:\n'
              '• Profil bilgilerinizi,\n'
              '• Tüm haftalık planlarınızı ve geçmiş etkinliklerinizi,\n'
              '• Tüm rutinlerinizi ve odak sayaçlarınızı,\n'
              '• Bulut veri tabanındaki tüm kayıtlarınızı\n'
              'kalıcı ve geri döndürülemez şekilde anında silebilirsiniz.',
        ),

        _buildSection(
          number: '8',
          title: 'Sorumluluğun Sınırlandırılması',
          content:
              'Calenda "olduğu gibi" (as-is) sunulmaktadır. Calenda, hizmetin kesintisiz veya tamamen hatasız olacağını garanti etmez. Uygulamanın kullanımından, cihaz arızalarından veya veri aktarım aksaklıklarından doğabilecek dolaylı zararlardan yasaların izin verdiği azami ölçüde sorumluluk kabul edilmez.',
        ),

        _buildSection(
          number: '9',
          title: 'Değişiklikler ve Yürürlük',
          content:
              'Calenda, işbu Kullanım Koşulları\'nı güncelleyebilir. Önemli değişiklikler uygulama içerisinden veya e-posta yoluyla bildirilir. Uygulamayı kullanmaya devam etmeniz güncel koşulları kabul ettiğiniz anlamına gelir.',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🛡️ GİZLİLİK POLİTİKASI (PRIVACY POLICY - KVKK & GDPR UYUMLU)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPrivacyContent(Color titleColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightCard(
          icon: Icons.lock_outline_rounded,
          title: 'Sıfır Reklam • Sıfır Takip • Tam Gizlilik',
          description:
              'Kişisel verileriniz asla satılmaz, kiralanmaz ve reklam verenlerle paylaşılmaz. Calenda uygulamasında hiçbir üçüncü taraf reklam ağı (AdMob vb.) veya kullanıcı izleme (tracking) mekanizması bulunmamaktadır.',
          accentColor: const Color(0xFF1D5C8A),
          bgColor: const Color(0xFFF0F6FA),
          borderColor: const Color(0xFFCEE0EE),
        ),

        const SizedBox(height: 18),

        _buildSection(
          number: '1',
          title: 'Veri Sorumlusu ve Taahhüdümüz',
          content:
              'Calenda ("Uygulama"), kullanıcı gizliliğini temel insan hakkı olarak kabul eder. Bu politika; 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK), Avrupa Birliği Genel Veri Koruma Tüzüğü (GDPR), Apple App Store İnceleme Kılavuzları (Madde 5.1.1 & 5.1.2) ve Google Play Geliştirici Politikaları doğrultusunda hazırlanmıştır.',
        ),

        _buildSection(
          number: '2',
          title: 'Toplanan Kişisel Veriler ve Kaynakları',
          content:
              'Uygulamamızı kullanırken aşağıdaki kategorilerde veriler toplanabilir:\n\n'
              '• Kimlik ve İletişim Verileri: Ad, soyad, kullanıcı adı, e-posta adresi. Bu veriler Apple ile Giriş Yap veya Google ile Giriş Yap sırasında güvenli belirteçler (OAuth Token) aracılığıyla veya e-posta kaydınızla sağlanır.\n'
              '• Kullanıcı Profil Tercihleri: Doğum tarihi (isteğe bağlı), seçtiğiniz avatar hayvanı, aksesuar ve arka plan rengi tercihleri.\n'
              '• Takvim ve Ajanda İçerikleri: Oluşturduğunuz etkinlikler, ders adları, başlangıç/bitiş saatleri, konum, renk kodları ve özel notlar.\n'
              '• Alışkanlık ve Odaklanma Verileri: Tanımladığınız günlük rutinler, tamamlama durumları ve Pomodoro odaklanma sayaçları (dakika bazında).\n'
              '• Teknik ve Tanılama Verileri: Cihaz modeli, işletim sistemi sürümü (iOS/Android), anonim çökme ve performans kayıtları (hiçbir kişisel veri içermez).',
        ),

        _buildSection(
          number: '3',
          title: 'Verilerin İşlenme Amaçları ve Hukuki Sebepleri',
          content:
              'Toplanan veriler yalnızca şu amaçlarla işlenir:\n'
              '• Kişiselleştirilmiş haftalık planlama ve zaman yönetimi hizmeti sunmak,\n'
              '• Verilerinizi cihazlarınız arasında kayıpsız senkronize etmek ve veri kaybını önlemek,\n'
              '• Belirlediğiniz ders ve alışkanlık hatırlatıcılarını yerel bildirim olarak iletmek,\n'
              '• Kulüp odaklanma odalarında eş zamanlı sayaç durumunu kulüp üyeleriyle paylaşmak,\n'
              '• Müşteri destek taleplerinizi yanıtlamak ve teknik sorunları gidermek.',
        ),

        _buildSection(
          number: '4',
          title: 'Veri Paylaşımı ve Altyapı Ortaklarımız',
          content:
              'Calenda, verilerinizi KESİNLİKLE reklam verenlerle paylaşmaz, satmaz veya ticarileştirmez. Yalnızca uygulamanın temel işlevlerini sunabilmek için dünya standartlarında güvenlik sertifikalarına sahip şu altyapı sağlayıcıları kullanılır:\n\n'
              '• Supabase Inc.: Uçtan uca şifrelenmiş PostgreSQL veri tabanı ve kimlik doğrulama altyapısı (SOC2 Type II, ISO 27001 ve GDPR uyumlu).\n'
              '• Apple Inc. & Google LLC: Güvenli tek tıkla kimlik doğrulama (Sign in with Apple / Google Identity) hizmeti.\n'
              'Yasal bir zorunluluk (mahkeme kararı vb.) olmadıkça kişisel verileriniz hiçbir resmi veya özel kurumla paylaşılmaz.',
        ),

        _buildSection(
          number: '5',
          title: 'Veri Güvenliği ve Şifreleme Standartları',
          content:
              '• Veri İletimi: Cihazınız ile sunucularımız arasındaki tüm veri akışı TLS 1.3 / SSL protokolleri ile en üst düzeyde şifrelenir.\n'
              '• Veri Tabanı Güvenliği: Supabase altyapısında Row Level Security (RLS) kuralları uygulanır; bir kullanıcının planlarına yalnızca kendi oturumu erişebilir.\n'
              '• Cihaz İçi Güvenlik: Hassas oturum belirteçleri iOS Keychain ve Android Keystore donanımsal güvenlik kasalarında korunur.',
        ),

        _buildSection(
          number: '6',
          title: 'Haklarınız (KVKK Madde 11 & GDPR Kapsamında)',
          content:
              'KVKK ve GDPR uyarınca aşağıdaki yasal haklara sahipsiniz:\n'
              '• Kişisel verilerinizin işlenip işlenmediğini öğrenme,\n'
              '• İşlenmişse buna ilişkin bilgi talep etme,\n'
              '• İşlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme,\n'
              '• Eksik veya yanlış işlenen verilerin düzeltilmesini isteme,\n'
              '• Verilerinizin silinmesini veya yok edilmesini talep etme.',
        ),

        _buildSection(
          number: '7',
          title: 'Hesap ve Tüm Verileri Kalıcı Silme Hakkı (Tek Tıkla Silme)',
          content:
              'Kullanıcılarımız diledikleri zaman Profil > Ayarlar menüsünden "Hesabı ve Tüm Verileri Sil" seçeneğini kullanarak hesaplarını ve sunucudaki tüm kişisel kayıtlarını anında, geri döndürülemez biçimde kalıcı olarak silebilirler.',
        ),

        _buildSection(
          number: '8',
          title: 'Çocukların Gizliliği',
          content:
              'Calenda, 13 yaşın (veya ilgili yargı bölgesindeki yasal yaşın) altındaki çocuklara yönelik değildir ve bilerek çocuklardan kişisel veri toplamaz. Ebeveyn izni olmadan çocuk verisi toplandığı tespit edilirse bu veriler derhal silinir.',
        ),

        _buildSection(
          number: '9',
          title: 'İletişim ve Veri Sorumlusu',
          content:
              'Gizlilik politikamız, kişisel verileriniz veya veri silme taleplerinizle ilgili her türlü soru için bize doğrudan e-posta gönderebilirsiniz:\n\n'
              'Resmi İletişim: calenda.support@gmail.com\n'
              'Uygulama: Calenda — Aesthetic Planner & Rhythm',
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
                    color: const Color(0xFF554441),
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
    const titleColor = Color(0xFF4A2B33);
    const subtitleColor = Color(0xFF6B5559);

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
                  color: const Color(0xFFEADBCE),
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
