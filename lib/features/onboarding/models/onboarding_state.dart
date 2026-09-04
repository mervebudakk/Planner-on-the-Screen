/// Onboarding adımlarında toplanan geçici kullanıcı tercihleri
class OnboardingState {
  int weeklyGoalDays;         // 0 - 7
  int dailyFocusMinutes;      // 0, 45, 90, 180
  List<String> coreGoals;     // Örn: ['Dersler & Sınavlar', 'Projeler & Çalışma Hayatı']
  String customGoalText;      // Kullanıcı dilerse kendi yazdığı hedef
  String username;
  String firstName;
  String lastName;
  int? birthDay;
  int? birthMonth;
  int? birthYear;
  String avatarAnimal;        // '01_rabbit', '02_fox', '03_deer', '04_cat', '05_bear', '06_seal', '07_puppy'
  String avatarAccessory;     // 'strawberry_beret', 'star_glasses', 'flower_crown', 'acc_frog_bonnet', 'sleep_mask', 'velvet_bowtie', 'gold_crown', 'none'
  String avatarBgColor;       // '#FAF7F2', '#FDEBF0', '#EBF5EE', '#DAEAF6', '#FCF4DD', '#FFFFFF'
  bool marketingEmailOptIn;
  bool isGoogleAuthed;

  OnboardingState({
    this.weeklyGoalDays = 4,
    this.dailyFocusMinutes = 45,
    List<String>? coreGoals,
    this.customGoalText = '',
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.birthDay,
    this.birthMonth,
    this.birthYear,
    this.avatarAnimal = '01_rabbit',
    this.avatarAccessory = 'none',
    this.avatarBgColor = '#FAF7F2',
    this.marketingEmailOptIn = false,
    this.isGoogleAuthed = false,
  }) : coreGoals = coreGoals ?? ['Dersler & Sınavlar'];

  String get coreGoal => coreGoals.isNotEmpty ? coreGoals.join(', ') : 'Kişisel Planlama';
  set coreGoal(String value) {
    if (!coreGoals.contains(value)) {
      coreGoals = [value];
    }
  }

  DateTime? get birthDate {
    if (birthDay != null && birthMonth != null && birthYear != null) {
      try {
        return DateTime(birthYear!, birthMonth!, birthDay!);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
