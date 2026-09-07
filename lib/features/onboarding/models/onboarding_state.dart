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
  String userId;
  String email;

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
    this.userId = '',
    this.email = '',
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

  Map<String, dynamic> toJson() => {
    'weeklyGoalDays': weeklyGoalDays,
    'dailyFocusMinutes': dailyFocusMinutes,
    'coreGoals': coreGoals,
    'customGoalText': customGoalText,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'birthDay': birthDay,
    'birthMonth': birthMonth,
    'birthYear': birthYear,
    'avatarAnimal': avatarAnimal,
    'avatarAccessory': avatarAccessory,
    'avatarBgColor': avatarBgColor,
    'marketingEmailOptIn': marketingEmailOptIn,
    'isGoogleAuthed': isGoogleAuthed,
    'userId': userId,
    'email': email,
  };

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      weeklyGoalDays: json['weeklyGoalDays'] as int? ?? 4,
      dailyFocusMinutes: json['dailyFocusMinutes'] as int? ?? 45,
      coreGoals: (json['coreGoals'] as List<dynamic>?)?.cast<String>(),
      customGoalText: json['customGoalText'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      birthDay: json['birthDay'] as int?,
      birthMonth: json['birthMonth'] as int?,
      birthYear: json['birthYear'] as int?,
      avatarAnimal: json['avatarAnimal'] as String? ?? '01_rabbit',
      avatarAccessory: json['avatarAccessory'] as String? ?? 'none',
      avatarBgColor: json['avatarBgColor'] as String? ?? '#FAF7F2',
      marketingEmailOptIn: json['marketingEmailOptIn'] as bool? ?? false,
      isGoogleAuthed: json['isGoogleAuthed'] as bool? ?? false,
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
