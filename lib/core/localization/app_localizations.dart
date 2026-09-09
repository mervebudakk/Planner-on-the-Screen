import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🌐 Calenda — Çoklu Dil ve Yerelleştirme Sözlüğü (TR & EN)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('tr'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isTurkish => locale.languageCode == 'tr';
  bool get isEnglish => locale.languageCode == 'en';

  // ─────────────────────────────────────────────────────────────
  // 🌿 GENEL / COMMON
  // ─────────────────────────────────────────────────────────────
  String get appName => 'Calenda';
  String get save => isTurkish ? 'Kaydet' : 'Save';
  String get cancel => isTurkish ? 'Vazgeç' : 'Cancel';
  String get delete => isTurkish ? 'Sil' : 'Delete';
  String get edit => isTurkish ? 'Düzenle' : 'Edit';
  String get close => isTurkish ? 'Kapat' : 'Close';
  String get done => isTurkish ? 'Tamam' : 'Done';
  String get next => isTurkish ? 'İleri' : 'Next';
  String get back => isTurkish ? 'Geri' : 'Back';
  String get yes => isTurkish ? 'Evet' : 'Yes';
  String get no => isTurkish ? 'Hayır' : 'No';
  String get discard => isTurkish ? 'Vazgeç' : 'Discard';
  String get warning => isTurkish ? 'Uyarı' : 'Warning';
  String get success => isTurkish ? 'Başarılı' : 'Success';
  String get error => isTurkish ? 'Hata' : 'Error';
  String get allDay => isTurkish ? 'Tüm Gün' : 'All Day';

  // ─────────────────────────────────────────────────────────────
  // 🧭 ALT NAVİGASYON / BOTTOM TOOLBOX
  // ─────────────────────────────────────────────────────────────
  String get tabPlanner => isTurkish ? 'Planlayıcı' : 'Planner';
  String get tabFocus => isTurkish ? 'Odak' : 'Focus';
  String get tabClubs => isTurkish ? 'Kulüpler' : 'Clubs';
  String get tabProfile => isTurkish ? 'Profil' : 'Profile';
  String get tabRoutines => isTurkish ? 'Rutinler' : 'Routines';

  // ─────────────────────────────────────────────────────────────
  // ☀️ SELAMLAMALAR / GREETINGS
  // ─────────────────────────────────────────────────────────────
  String get goodMorning => isTurkish ? 'Günaydın' : 'Good Morning';
  String get goodAfternoon => isTurkish ? 'İyi Günler' : 'Good Afternoon';
  String get goodEvening => isTurkish ? 'İyi Akşamlar' : 'Good Evening';
  String get goodNight => isTurkish ? 'İyi Geceler' : 'Good Night';
  String get guestUser => isTurkish ? 'Misafir Kullanıcı' : 'Guest User';

  // ─────────────────────────────────────────────────────────────
  // 📅 PLANLAYICI & GÜNLÜK AKIŞ / PLANNER
  // ─────────────────────────────────────────────────────────────
  String get weeklySchedule => isTurkish ? 'Haftalık Planlar' : 'Weekly Schedule';
  String get todaySchedule => isTurkish ? 'Bugünün Planı' : "Today's Schedule";
  String get myWeeklyPlan => isTurkish ? 'Haftalık Planım' : 'My Weekly Plan';
  String get noPlansToday => isTurkish ? 'Bugün için plan bulunmuyor 🌿' : 'No plans scheduled for today 🌿';
  String get noPlansThisDay => isTurkish ? 'Bu güne ait plan bulunmuyor' : 'No plans scheduled for this day';
  String get addNewPlan => isTurkish ? 'Yeni Plan Ekle' : 'Add New Event';
  String get editPlan => isTurkish ? 'Planı Düzenle' : 'Edit Plan';
  String get newPlan => isTurkish ? 'Yeni Plan' : 'New Plan';
  String get planTitle => isTurkish ? 'Plan Başlığı' : 'Plan Title';
  String get planTitleHint => isTurkish
      ? 'örn. Psikoloji 101, Kitap Okuma, Tenis...'
      : 'e.g. Psychology 101, Reading, Tennis...';
  String get notesOrLocation => isTurkish ? 'Açıklama veya Konum' : 'Notes or Location';
  String get notesOrLocationHint => isTurkish
      ? 'Açıklama ekle...'
      : 'Add a description...';
  String get selectDay => isTurkish ? 'Gün' : 'Day';
  String get timeInterval => isTurkish ? 'Saat Aralığı' : 'Time Interval';
  String get starts => isTurkish ? 'Başlangıç' : 'Starts';
  String get ends => isTurkish ? 'Bitiş' : 'Ends';
  String get noEndTime => isTurkish ? 'Bitiş saati yok' : 'No end time';
  String get colorPalette => isTurkish ? 'Renk Paleti' : 'Color Palette';
  String get reminder => isTurkish ? 'Bildirim' : 'Reminder';
  String get reminderHint => isTurkish
      ? '10 dakika önce zarif bir bildirim gönderilir'
      : 'A gentle reminder 10 minutes before';
  String get savePlan => isTurkish ? 'Planı Kaydet' : 'Save Plan';
  String get deletePlan => isTurkish ? 'Planı Sil' : 'Delete Plan';
  String get deletePlanConfirm => isTurkish
      ? 'Bu planı silmek istediğinize emin misiniz?'
      : 'Are you sure you want to delete this plan?';
  String get discardChangesConfirm => isTurkish
      ? 'Değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?'
      : 'Unsaved changes will be lost. Are you sure you want to leave?';
  String get addNewPlanSubtitle => isTurkish
      ? 'Haftalık akışına etkinlik oluştur'
      : 'Schedule an event in your week';
  String get emptyTimelineHint => isTurkish
      ? 'Yeni bir plan eklemek için yukarıdaki "Yeni Plan Ekle" butonuna dokunun.'
      : 'Tap "Add New Event" above to schedule a plan.';
  String get enterTitleWarning => isTurkish
      ? 'Lütfen bir başlık girin'
      : 'Please enter a title';
  String get startTime => isTurkish ? 'Başlangıç Saati' : 'Start Time';
  String get endTime => isTurkish ? 'Bitiş Saati' : 'End Time';
  String get endTimeOptional => isTurkish ? 'Bitiş (İsteğe Bağlı)' : 'End (Optional)';
  String get addEndTime => isTurkish ? 'Bitiş Ekle' : 'Add End Time';
  String get removeEndTime => isTurkish
      ? 'Bitiş Saatini Kaldır (Alarm Modu)'
      : 'Remove End Time (Alarm Mode)';
  String get endTimeAfterStartTime => isTurkish
      ? 'Bitiş saati başlangıç saatinden sonra olmalı.'
      : 'End time must be after start time.';
  String get saveFailedRetry => isTurkish
      ? 'Kaydedilemedi. Lütfen tekrar deneyin.'
      : 'Failed to save. Please try again.';
  String get updateChanges => isTurkish ? 'Değişiklikleri Güncelle' : 'Update Changes';
  String get howMuchEarlier => isTurkish ? 'Ne kadar önce?' : 'How much earlier?';
  String minutesEarlier(int minutes) => isTurkish
      ? (minutes < 60 ? '$minutes dk' : '${minutes ~/ 60} saat')
      : (minutes < 60 ? '$minutes min' : '${minutes ~/ 60} hr');
  String get notificationPermissionDenied => isTurkish
      ? 'Bildirim izni kapalı. Ayarlar > Calenda bölümünden bildirimleri açabilirsiniz.'
      : 'Notifications are disabled. You can enable them in Settings > Calenda.';
  String planCount(int count) => isTurkish
      ? '$count Plan'
      : (count == 1 ? '1 Plan' : '$count Plans');
  String planDeleted(String title) => isTurkish ? '$title silindi' : '$title deleted';
  String todayWithDay(String dayName) => isTurkish ? 'Bugün, $dayName' : 'Today, $dayName';

  // ─────────────────────────────────────────────────────────────
  // 🎨 RENK SEÇİCİ / COLOR PICKER
  // ─────────────────────────────────────────────────────────────
  String get selectColor => isTurkish ? 'Renk Seçimi' : 'Select Color';
  String get removeCustomColor => isTurkish ? 'Özel Rengi Kaldır' : 'Remove Custom Color';
  String removeCustomColorConfirm(String hex) => isTurkish
      ? '$hex özel rengini paletinizden kaldırmak istiyor musunuz?'
      : 'Remove custom color $hex from your palette?';
  String get colorAddedToPalette => isTurkish ? 'Renk palete eklendi' : 'Color added to palette';
  String get createCustomColor => isTurkish ? 'Özel Renk Oluştur' : 'Create Custom Color';
  String get hexCode => isTurkish ? 'HEX Kodu' : 'HEX Code';
  String get addColor => isTurkish ? 'Rengi Ekle' : 'Add Color';
  String get pickColor => isTurkish ? 'Renk Seç' : 'Pick Color';

  // ─────────────────────────────────────────────────────────────
  // ⏱️ ODAK SAYACI / FOCUS TIMER
  // ─────────────────────────────────────────────────────────────
  String get focusTimer => isTurkish ? 'Odaklanma' : 'Focus Session';
  String get selectDuration => isTurkish ? 'Süre Seç' : 'Choose Duration';
  String get selectCategory => isTurkish ? 'Kategori Seç' : 'Select Category';
  String get startFocus => isTurkish ? 'Başlat' : 'Start Focus';
  String get pause => isTurkish ? 'Duraklat' : 'Pause';
  String get resume => isTurkish ? 'Devam Et' : 'Resume';
  String get finishSession => isTurkish ? 'Seansı Bitir' : 'Finish Session';
  String get cancelSession => isTurkish ? 'Vazgeç' : 'Cancel Session';
  String get focusCompletedTitle => isTurkish ? 'Harika iş çıkardın!' : 'Great job! Session Completed 🌿';
  String focusCompletedDesc(int minutes) => isTurkish
      ? 'Toplam $minutes dakika odaklandın.'
      : 'You focused for $minutes minutes.';
  String get totalFocusToday => isTurkish ? 'Bugünkü Toplam Odak' : 'Total Focus Today';
  String get weeklyFocus => isTurkish ? 'Haftalık Odak' : 'Weekly Focus';
  String get focusStreak => isTurkish ? 'Odak Serisi' : 'Focus Streak';
  String get shortBreak => isTurkish ? 'Kısa Mola' : 'Short Break';
  String get longBreak => isTurkish ? 'Uzun Mola' : 'Long Break';
  String get focusInProgress => isTurkish
      ? '🌱 Odaklanma Seansı Devam Ediyor'
      : '🌱 Focus Session in Progress';
  String get breakInProgress => isTurkish
      ? '☕ Mola Devam Ediyor'
      : '☕ Break in Progress';
  String get restYourMind => isTurkish ? 'Zihnini dinlendir' : 'Rest your mind';
  String get sessionCompleted => isTurkish
      ? '🎉 Odak Seansı Tamamlandı!'
      : '🎉 Focus Session Completed!';
  String get breakFinished => isTurkish
      ? '⏰ Mola Süresi Bitti!'
      : '⏰ Break Over!';
  String get breakFinishedDesc => isTurkish
      ? 'Mola süresi doldu. Yeni bir odak seansına başlamaya hazır mısın?'
      : 'Break time is over. Ready to start a new focus session?';
  String get finishAndSaveSession => isTurkish
      ? 'Seansı Bitir ve Kaydet?'
      : 'Finish and Save Session?';
  String get cancelSessionPrompt => isTurkish ? 'Seansı İptal Et?' : 'Cancel Session?';
  String get saveAndFinish => isTurkish ? 'Kaydet ve Bitir' : 'Save & Finish';
  String get cancelSessionAction => isTurkish ? 'İptal Et' : 'Cancel';
  String focusSuccessEarnedCredit(int minutes) => isTurkish
      ? 'Tebrikler, $minutes dakika boyunca odaklandın! Bu süre günlük odak sürene, haftalık ritmine ve kulüplerine eklenecektir.'
      : 'Great job! You focused for $minutes minutes. This time will be added to your daily focus, weekly rhythm, and clubs.';
  String get focusUnder5MinWarning => isTurkish
      ? '5 dakikadan az odaklandığın için bu süre kaydedilmeyecektir. Seansı iptal etmek istediğinden emin misin?'
      : 'Focus under 5 minutes will not be saved. Are you sure you want to cancel the session?';
  String get breakCancelPrompt => isTurkish
      ? 'Mola seansını sonlandırmak istediğinden emin misin?'
      : 'Are you sure you want to end this break?';

  // Odak Etiketleri
  String get tagStudy => isTurkish ? 'Ders & Çalışma' : 'Study & Work';
  String get tagProject => isTurkish ? 'Proje & İş' : 'Project & Business';
  String get tagReading => isTurkish ? 'Kitap & Okuma' : 'Reading & Books';
  String get tagCalm => isTurkish ? 'Sakin Odak' : 'Calm Focus';
  String get tagCreative => isTurkish ? 'Yaratıcı & Tasarım' : 'Creative & Design';
  String get tagCoding => isTurkish ? 'Kodlama' : 'Coding';
  String get tagDesign => isTurkish ? 'Tasarım' : 'Design';
  String get tagWriting => isTurkish ? 'Yazı' : 'Writing';
  String get tagWork => isTurkish ? 'Çalışma' : 'Work';
  String get tagGeneral => isTurkish ? 'Genel' : 'General';
  String get minutesShort => isTurkish ? 'dk' : 'min';
  String get hoursShort => isTurkish ? 'sa' : 'hr';

  // ─────────────────────────────────────────────────────────────
  // 🔄 RUTİNLER & ALIŞKANLIKLAR / ROUTINES
  // ─────────────────────────────────────────────────────────────
  String get myRoutines => isTurkish ? 'Rutinlerim' : 'My Routines';
  String get newRoutine => isTurkish ? 'Yeni Rutin Ekle' : 'Add New Routine';
  String get createHabitSubtitle => isTurkish
      ? 'Alışkanlık veya günlük hedef oluştur'
      : 'Build a habit or daily goal';
  String get dailyRoutines => isTurkish ? 'Günlük Rutinler' : 'Daily Routines';
  String get allDone => isTurkish ? 'Hepsi Tamam ✨' : 'All Done ✨';
  String completedRatio(int done, int total) => isTurkish
      ? '$done/$total Tamamlandı'
      : '$done/$total Completed';
  String get routineName => isTurkish ? 'Rutin Adı' : 'Routine Name';
  String get routineNameHint => isTurkish
      ? 'örn. Sabah Meditasyonu, Kitap Okuma...'
      : 'e.g. Morning Meditation, Reading...';
  String get frequency => isTurkish ? 'Sıklık' : 'Frequency';
  String get everyDay => isTurkish ? 'Her Gün' : 'Daily';
  String get weekdays => isTurkish ? 'Hafta İçi' : 'Weekdays';
  String get weekends => isTurkish ? 'Hafta Sonu' : 'Weekends';
  String get timeOfDay => isTurkish ? 'Günün Zamanı' : 'Time of Day';
  String get morning => isTurkish ? 'Sabah' : 'Morning';
  String get afternoon => isTurkish ? 'Öğle' : 'Afternoon';
  String get evening => isTurkish ? 'Akşam' : 'Evening';
  String get streak => isTurkish ? 'Seri' : 'Streak';
  String get daysUnit => isTurkish ? 'Gün' : 'Days';
  String get routineCreated => isTurkish ? 'Rutin başarıyla eklendi 🌿' : 'Routine created successfully 🌿';
  String get routineDeleted => isTurkish ? 'Rutin silindi' : 'Routine deleted';
  String get deleteRoutineConfirm => isTurkish
      ? 'Bu rutini silmek istediğinize emin misiniz?'
      : 'Are you sure you want to delete this routine?';
  String get noRoutinesYet => isTurkish ? 'Henüz bir rutin eklenmedi 🌿' : 'No routines added yet 🌿';

  // ─────────────────────────────────────────────────────────────
  // 👥 KULÜPLER / CLUBS
  // ─────────────────────────────────────────────────────────────
  String get studyClubs => isTurkish ? 'Çalışma Kulüpleri' : 'Study Clubs';
  String get joinClub => isTurkish ? 'Kulübe Katıl' : 'Join Club';
  String get createClub => isTurkish ? 'Yeni Kulüp Kur' : 'Create Club';
  String get clubCode => isTurkish ? 'Kulüp Kodu' : 'Invite Code';
  String get clubCodeHint => isTurkish ? '6 haneli kodu girin' : 'Enter 6-character code';
  String get enterClubNameWarning => isTurkish
      ? 'Lütfen bir kulüp adı belirleyin.'
      : 'Please enter a club name.';
  String get enterInviteCodeWarning => isTurkish
      ? 'Lütfen 6 haneli davet kodunu girin.'
      : 'Please enter the 6-character invite code.';
  String clubCreated(String name, String code) => isTurkish
      ? '"$name" kulübü kuruldu! Davet Kodu: $code'
      : 'Club "$name" created! Invite Code: $code';
  String clubJoined(String name) => isTurkish
      ? '"$name" kulübüne başarıyla katıldınız!'
      : 'Successfully joined "$name"!';
  String get clubCreateFailed => isTurkish
      ? 'Kulüp oluşturulamadı.'
      : 'Failed to create club.';
  String get clubJoinFailed => isTurkish
      ? 'Kulübe katılınamadı. Kodu kontrol edin.'
      : 'Failed to join club. Please check the code.';
  String get focusTogether => isTurkish ? 'Birlikte Odaklan' : 'Focus Together';
  String get activeFocusers => isTurkish ? 'Aktif Odaklananlar' : 'Currently Focusing';
  String get leaderboard => isTurkish ? 'Liderlik Tablosu' : 'Leaderboard';
  String get members => isTurkish ? 'Üyeler' : 'Members';
  String get quietRoom => isTurkish ? 'Sessiz Çalışma Odası' : 'Quiet Study Room';
  String get noClubsYet => isTurkish ? 'Henüz bir kulübe katılmadınız' : "You haven't joined any clubs yet";

  // ─────────────────────────────────────────────────────────────
  // 👤 PROFİL & AYARLAR / PROFILE & SETTINGS
  // ─────────────────────────────────────────────────────────────
  String get profile => isTurkish ? 'Profil' : 'Profile';
  String get settings => isTurkish ? 'Ayarlar' : 'Settings';
  String get editProfile => isTurkish ? 'Profili Düzenle' : 'Edit Profile';
  String get firstName => isTurkish ? 'Ad' : 'First Name';
  String get lastName => isTurkish ? 'Soyad' : 'Last Name';
  String get username => isTurkish ? 'Kullanıcı Adı' : 'Username';
  String get avatarStudio => isTurkish ? 'Avatar Stüdyosu' : 'Avatar Studio';
  String get weeklyRhythm => isTurkish ? 'Haftalık Ritim' : 'Weekly Rhythm';
  String get addWidget => isTurkish ? 'Ana Ekran Widget\'ı Ekle' : 'Add Home Screen Widget';
  String get helpAndFeedback => isTurkish ? 'Yardım & Geri Bildirim' : 'Help & Feedback';
  String get language => isTurkish ? 'Dil' : 'Language';
  String get chooseLanguage => isTurkish ? 'Dil Seçimi' : 'Choose Language';
  String get turkish => 'Türkçe';
  String get english => 'English';
  String get currentLanguageName => isTurkish ? 'Türkçe' : 'English';
  String get signOut => isTurkish ? 'Oturumu Kapat' : 'Sign Out';
  String get signOutConfirm => isTurkish
      ? 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'
      : 'Are you sure you want to sign out?';
  String get deleteAccount => isTurkish ? 'Hesabı ve Verileri Sil' : 'Delete Account & Data';
  String get deleteAccountConfirm => isTurkish
      ? 'Bu işlem geri alınamaz. Tüm planlarınız, rutinleriniz ve verileriniz kalıcı olarak silinecektir.'
      : 'This action cannot be undone. All your plans, routines, and data will be permanently deleted.';
  String get sendFeedback => isTurkish ? 'Geri Bildirim Gönder' : 'Send Feedback';
  String get feedbackHint => isTurkish
      ? 'Fikirleriniz, önerileriniz veya karşılaştığınız sorunlar...'
      : 'Your thoughts, suggestions or any issues you encountered...';
  String get submit => isTurkish ? 'Gönder' : 'Submit';
  String get feedbackReceived => isTurkish
      ? 'Teşekkürler! Geri bildiriminiz alındı 🌿'
      : 'Thank you! Your feedback has been received 🌿';
  String get version => isTurkish ? 'Sürüm' : 'Version';
  String get privacyPolicy => isTurkish ? 'Gizlilik Politikası' : 'Privacy Policy';
  String get termsOfUse => isTurkish ? 'Kullanım Koşulları' : 'Terms of Use';

  String memberSince(String monthName, int year) {
    if (isTurkish) {
      final lastDigit = year % 10;
      String suffix;
      switch (lastDigit) {
        case 0:
        case 6:
        case 9:
          suffix = "'dan";
          break;
        case 3:
        case 4:
        case 5:
          suffix = "'ten";
          break;
        default:
          suffix = "'den";
      }
      return "$monthName $year$suffix beri üye";
    } else {
      return "Member since $monthName $year";
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📆 TARİHLER & HAFTALAR / DATES
  // ─────────────────────────────────────────────────────────────
  String get today => isTurkish ? 'Bugün' : 'Today';
  String get yesterday => isTurkish ? 'Dün' : 'Yesterday';
  String get tomorrow => isTurkish ? 'Yarın' : 'Tomorrow';
  String get thisWeek => isTurkish ? 'Bu Hafta' : 'This Week';
  String get nextWeek => isTurkish ? 'Gelecek Hafta' : 'Next Week';
  String get prevWeek => isTurkish ? 'Geçen Hafta' : 'Previous Week';

  // ─────────────────────────────────────────────────────────────
  // ⏱️ ODAK SAYACI EK DİZELER / FOCUS TIMER EXTRAS
  // ─────────────────────────────────────────────────────────────
  String get startFocusing => isTurkish ? 'Odaklanmaya Başla' : 'Start Focus';
  String get tapToChangeDuration => isTurkish ? 'Süreyi değiştirmek için dokun' : 'Tap to change duration';
  String get focusTopic => isTurkish ? 'Odak Konusu' : 'Focus Topic';
  String get applyDuration => isTurkish ? 'Süreyi Uygula' : 'Apply Duration';
  String get focusDuration => isTurkish ? 'Odak Süresi' : 'Focus Duration';
  String get breakDuration => isTurkish ? 'Mola Süresi' : 'Break Duration';
  String minRest(int mins) => isTurkish ? '$mins dk Dinlenme' : '$mins min Break';
  String ongoingFocusNotifBody(String tag, int mins) =>
      isTurkish ? '$tag • Toplam $mins dk' : '$tag • Total $mins min';
  String ongoingBreakNotifBody(int mins) =>
      isTurkish ? 'Zihnini dinlendir • $mins dk' : 'Rest your mind • $mins min';
  String focusCompletionNotifBody(int mins, String tag) => isTurkish
      ? '$mins dakikalık "$tag" seansını başarıyla tamamladın. Harika bir iş!'
      : 'You completed your $mins min "$tag" session. Great job!';
  String get breakCompletionNotifBody => isTurkish
      ? 'Mola süresi doldu. Yeni bir odak seansına başlamaya hazır mısın?'
      : 'Break time is over. Ready to start a new focus session?';
  String earlyFocusSavedSnackbar(int mins) => isTurkish
      ? '$mins dakikalık odaklanma süren kaydedildi! 🌿'
      : '$mins minutes of focus time recorded! 🌿';
  String get startFocusSession => isTurkish ? 'Odak Seansına Başla' : 'Start Focus Session';
  String get takeABreak => isTurkish ? 'Molaya Geç' : 'Take a Break';
  String get focusSessionCompletedTitle => isTurkish ? 'Odak Seansı Tamamlandı' : 'Focus Session Completed';
  String focusSessionCompletedDesc(int mins, String tag) => isTurkish
      ? '$mins dakikalık "$tag" seansını başarıyla tamamladın.'
      : 'You completed your $mins min "$tag" session.';
  String get breakCompletedTitle => isTurkish ? 'Mola Tamamlandı' : 'Break Completed';
  String get breakCompletedDesc => isTurkish
      ? 'Zihnini dinlendirdin. Yeni bir odak seansına başlamaya hazır mısın?'
      : 'Mind rested. Ready to start another focus session?';
  String get modeFocus => isTurkish ? 'Odak' : 'Focus';
  String get modeShortBreak => isTurkish ? 'Kısa Mola' : 'Short Break';
  String get modeLongBreak => isTurkish ? 'Uzun Mola' : 'Long Break';

  // ─────────────────────────────────────────────────────────────
  // 👥 KULÜPLER EK DİZELER / CLUBS EXTRAS
  // ─────────────────────────────────────────────────────────────
  String get clubMembersHeader => isTurkish ? 'Kulüp Üyeleri' : 'Club Members';
  String clubMemberCount(int count, int max) =>
      isTurkish ? '$count / $max Üye' : '$count / $max Members';
  String get loadingMembers => isTurkish ? 'Üye listesi yükleniyor...' : 'Loading member list...';
  String get prepLobby => isTurkish ? 'HAZIRLIK LOBİSİ' : 'PREPARATION LOBBY';
  String get liveFocusSessionBadge => isTurkish ? 'CANLI ODAK SEANSI' : 'LIVE FOCUS SESSION';
  String get closeSessionDialogTitle => isTurkish ? 'Seansı Kapat' : 'End Session';
  String get closeSessionDialogDesc => isTurkish
      ? 'Bu odaklanma seansını sonlandırmak istiyor musunuz?'
      : 'Do you want to end this focus session?';
  String get yesClose => isTurkish ? 'Evet, Kapat' : 'Yes, End';
  String startedBy(String host, String tag) =>
      isTurkish ? '@$host tarafından başlatıldı • $tag' : 'Started by @$host • $tag';
  String waitingHostLobby(String host, int count) =>
      isTurkish ? '@$host tarafından açıldı • $count kişi bekliyor' : 'Hosted by @$host • $count waiting';
  String get goToRoomAndStart => isTurkish ? 'Odaya Git ve Seansı Başlat' : 'Go to Room & Start';
  String get goToLiveSession => isTurkish ? 'Canlı Seans Ekranına Git' : 'Go to Live Session';
  String get silentStudyLounge => isTurkish ? 'Sessiz Çalışma Salonu' : 'Silent Study Lounge';
  String get noActiveSessionHint => isTurkish
      ? 'Şu an aktif seans yok. İlk adımı sen at!'
      : 'No active session right now. Start one together!';
  String get startSessionTogether => isTurkish ? 'Birlikte Seans Başlat' : 'Start Session Together';
  String get nowFocusingOnline => isTurkish ? 'Şu an odakta 🟢' : 'Focusing now 🟢';
  String get waitingInLobbyStatus => isTurkish ? 'Odada bekliyor ⏳' : 'Waiting in room ⏳';
  String get activeToday => isTurkish ? 'Bugün aktif oldu' : 'Active today';
  String get notFocusedYet => isTurkish ? 'Henüz odaklanmadı' : 'Not focused yet';
  String get specialInviteCode => isTurkish ? 'ÖZEL DAVET KODU' : 'INVITE CODE';
  String get copy => isTurkish ? 'Kopyala' : 'Copy';
  String inviteCodeCopied(String code) =>
      isTurkish ? 'Davet kodu panoya kopyalandı: $code' : 'Invite code copied: $code';
  String get leaveClub => isTurkish ? 'Kulüpten Ayrıl' : 'Leave Club';
  String get closeAndLeaveClub => isTurkish ? 'Kulübü Kapat ve Ayrıl' : 'Delete & Leave Club';
  String lastMemberLeaveWarning(String name) => isTurkish
      ? 'Bu kulüpteki son üyesiniz. Ayrıldığınızda "$name" kulübü ve kulübe ait tüm veriler kalıcı olarak tamamen silinecektir.\n\nAyrılmak istediğinize emin misiniz?'
      : 'You are the last member of "$name". Leaving will permanently delete the club and all its data.\n\nAre you sure you want to leave?';
  String leaveClubWarning(String name) => isTurkish
      ? '"$name" kulübünden ayrılmak istediğinize emin misiniz? Tekrar katılmak için davet kodunu yeniden girmeniz gerekir.'
      : 'Are you sure you want to leave "$name"? You will need the invite code to rejoin.';
  String get deleteClubAndLeaveAction => isTurkish ? 'Kulübü Sil ve Ayrıl' : 'Delete Club & Leave';
  String clubDeletedEmptyNotice(String name) => isTurkish
      ? '"$name" kulübünde başka üye kalmadığı için kulüp tamamen silindi ✨'
      : '"$name" was permanently deleted because no members remained ✨';
  String get leftClubSuccess => isTurkish ? 'Kulüpten başarıyla ayrıldınız.' : 'Successfully left the club.';
  String get createClubTab => isTurkish ? 'Kulüp Oluştur' : 'Create Club';
  String get joinWithCodeTab => isTurkish ? 'Kod ile Katıl' : 'Join with Code';
  String get clubNameLabel => isTurkish ? 'KULÜP ADI' : 'CLUB NAME';
  String get clubIconLabel => isTurkish ? 'KULÜP SİMGESİ' : 'CLUB ICON';
  String get buildClubButton => isTurkish ? 'Kulübü Kur' : 'Create Club';
  String get joinClubButton => isTurkish ? 'Kulübe Katıl' : 'Join Club';
  String get roomSetup => isTurkish ? 'Oda Hazırlığı' : 'Room Setup';
  String get waitingParticipants => isTurkish ? '⏳ Katılımcılar Bekleniyor' : '⏳ Waiting for Participants';
  String get focusModeSilentSession => isTurkish ? '🌿 Odak Modu • Sessiz Seans' : '🌿 Focus Mode • Quiet Session';
  String openForJoinRemaining(String time) =>
      isTurkish ? '🟢 Katılıma Açık • Kalan: $time' : '🟢 Open to Join • Left: $time';
  String get targetDuration => isTurkish ? 'Hedef Süre' : 'Target Duration';
  String get focusingSilentlyTogether =>
      isTurkish ? 'Birlikte sessizce odaklanıyorsunuz 🌿' : 'Focusing quietly together 🌿';
  String get participants => isTurkish ? 'Katılımcılar' : 'Participants';
  String get joinClosed => isTurkish ? '🔒 Katılıma kapandı' : '🔒 Closed to join';
  String get founderBadge => isTurkish ? 'Kurucu' : 'Host';
  String get membersWillJoinAfterOpen => isTurkish
      ? 'Oda açıldıktan sonra kulüp üyeleri buraya katılabilecek.'
      : 'Club members will be able to join once the room is opened.';
  String get openRoomAction => isTurkish ? 'Odayı Aç' : 'Open Room';
  String get startFocusingAction => isTurkish ? 'Odaklanmayı Başlat' : 'Start Focus';
  String get joinRoomAction => isTurkish ? 'Odaya Katıl' : 'Join Room';
  String get waitingForHost => isTurkish ? 'Kurucu Bekleniyor...' : 'Waiting for Host...';
  String get joinSessionAction => isTurkish ? 'Seansa Katıl' : 'Join Session';
  String get closedToJoinAction => isTurkish ? 'Katılıma Kapalı' : 'Closed to Join';
  String get leaveSessionAction => isTurkish ? 'Seanstan Ayrıl' : 'Leave Session';
  String get joinedSessionSuccess => isTurkish ? 'Seansa başarıyla katıldınız!' : 'Successfully joined session!';
  String get joinedSessionFailed =>
      isTurkish ? 'Seansa katılınamadı veya katılım süresi doldu.' : 'Could not join session or join window expired.';
  String get congratsTitle => isTurkish ? '🎉 Tebrikler!' : '🎉 Congratulations!';
  String clubFocusCompletedCongrats(int mins, String tag) => isTurkish
      ? '$mins dakikalık "$tag" odaklanma seansını kulübünüzle birlikte başarıyla tamamladınız! 🌿 Süreniz profilinize ve haftalık ritminize eklendi.'
      : 'You and your club completed a $mins min "$tag" focus session! 🌿 Time added to your profile.';
  String get awesome => isTurkish ? 'Harika!' : 'Awesome!';
  String get sessionPrepSubtitle => isTurkish ? 'Seans Hazırlığı' : 'Session Setup';
  String get sessionWaitingSubtitle => isTurkish ? 'Hazırlık Lobisi' : 'Waiting Lobby';
  String get sessionLockedSubtitle => isTurkish ? '🔒 Odaklanma Seansı (Kilitli)' : '🔒 Focus Session (Locked)';
  String get focusSessionSubtitle => isTurkish ? 'Odaklanma Seansı' : 'Focus Session';
  String get finishAndSaveAction => isTurkish ? 'Bitir ve Kaydet' : 'End & Save';
  String get leaveAndSaveAction => isTurkish ? 'Ayrıl ve Kaydet' : 'Leave & Save';
  String get yesFinishAction => isTurkish ? 'Evet, Bitir' : 'Yes, End';
  String get leaveAction => isTurkish ? 'Ayrıl' : 'Leave';
  String get keepFocusingAction => isTurkish ? 'Devam Et' : 'Continue';
  String hostEarnsCreditPrompt(int mins) => isTurkish
      ? 'Tebrikler! Geçen $mins dakikalık odaklanma süresi profilinize ve kulübünüze kaydedilecektir. Seansı tüm katılımcılar için bitirmek istiyor musunuz?'
      : 'Congratulations! Your $mins minutes of focus will be recorded. End session for all participants?';
  String participantEarnsCreditPrompt(int mins) => isTurkish
      ? 'Tebrikler! Geçen $mins dakikalık odaklanma süresi profilinize ve kulübünüze kaydedilecektir. Seanstan ayrılmak istiyor musunuz?'
      : 'Congratulations! Your $mins minutes of focus will be recorded. Leave the session?';
  String get hostUnder5Prompt => isTurkish
      ? 'Canlı odaklanma seansını tüm katılımcılar için bitirmek istiyor musunuz? (5 dakikadan az olduğu için süre kaydedilmez)'
      : 'End the live session for everyone? (Sessions under 5 minutes are not recorded)';
  String get participantUnder5Prompt => isTurkish
      ? 'Seans devam ediyor. Ayrılmak istediğinize emin misiniz? (5 dakikadan az olduğu için süre kaydedilmez)'
      : 'Session is ongoing. Are you sure you want to leave? (Sessions under 5 minutes are not recorded)';
  String clubFocusOngoingNotifTitle(String club) =>
      '👥 $club — ${isTurkish ? 'Birlikte Odaklanma' : 'Focus Together'}';
  String get clubFocusCompletionNotifTitle =>
      isTurkish ? '🎉 Kulüp Odak Seansı Tamamlandı!' : '🎉 Club Focus Session Completed!';
  String clubFocusCompletionNotifBody(String club, int mins, String tag) => isTurkish
      ? '$club kulübündeki $mins dakikalık "$tag" seansı tamamlandı!'
      : 'The $mins min "$tag" session in $club is completed!';

  // ─────────────────────────────────────────────────────────────
  // 🌟 KARŞILAMA, GİRİŞ & WIDGET ÖZELLEŞTİRİCİ / WELCOME, LOGIN & WIDGET
  // ─────────────────────────────────────────────────────────────
  String get welcomeTagline => isTurkish
      ? 'Derslerini, hedeflerini ve rutinlerini sana uygun huzurlu bir akışta planla.'
      : 'Plan your studies, goals, and routines in a peaceful aesthetic flow.';
  String get getStarted => isTurkish ? 'Hemen Başla' : 'Get Started';
  String get alreadyHaveAccount => isTurkish ? 'Zaten bir hesabın var mı? ' : 'Already have an account? ';
  String get signIn => isTurkish ? 'Giriş Yap' : 'Sign In';
  String get welcomeBack => isTurkish ? 'Tekrar Hoş Geldin!' : 'Welcome Back!';
  String get loginSubtitle => isTurkish
      ? 'Kaldığın yerden haftalık planlarına, hedeflerine ve huzurlu ritmine devam et.'
      : 'Pick up right where you left off with your schedule, goals, and peaceful rhythm.';
  String get signInWithApple => isTurkish ? 'Apple ile Giriş Yap' : 'Sign in with Apple';
  String get signInWithGoogle => isTurkish ? 'Google ile Giriş Yap' : 'Sign in with Google';
  String get loginFootnote => isTurkish
      ? 'Giriş yaparak kayıtlı tüm haftalık planlarını ve hedeflerini anında geri yüklersin.'
      : 'Signing in restores all your saved weekly plans, routines, and progress.';
  String get loginFailedTryAgain => isTurkish ? 'Giriş yapılamadı. Lütfen tekrar deneyin.' : 'Sign in failed. Please try again.';
  String get checkInternetConnection => isTurkish ? 'İnternet bağlantınızı kontrol edip tekrar deneyin.' : 'Please check your internet connection and try again.';
  String get widgetCustomizer => isTurkish ? 'Widget Özelleştir' : 'Widget Customizer';
  String get widgetAppearance => isTurkish ? 'Widget Görünümü' : 'Widget Appearance';
  String get weeklyScheduleWidget => isTurkish ? 'Haftalık Program' : 'Weekly Schedule';
  String get dailyScheduleWidget => isTurkish ? 'Günlük Program' : 'Daily Schedule';
  String get widgetSettingsUpdated => isTurkish ? 'Widget ayarları güncellendi.' : 'Widget settings updated.';
  String widgetSettingsSaved(String name) => isTurkish ? '$name ayarları kaydedildi.' : '$name settings saved.';
  String widgetAddingToHome(String name) => isTurkish ? '$name widget\'ı ana ekrana ekleniyor...' : '$name widget is being added to home screen...';
  String get saveDailyWidgetSettings => isTurkish ? 'Günlük Widget Ayarlarını Kaydet' : 'Save Daily Widget Settings';
  String get saveWeeklyWidgetSettings => isTurkish ? 'Haftalık Widget Ayarlarını Kaydet' : 'Save Weekly Widget Settings';
  String get addDailyWidget => isTurkish ? 'Günlük Widget Ekle' : 'Add Daily Widget';
  String get addWeeklyWidget => isTurkish ? 'Haftalık Widget Ekle' : 'Add Weekly Widget';
  String get preview => isTurkish ? 'Önizleme' : 'Preview';
  String get lightBg => isTurkish ? 'Açık Zemin' : 'Light';
  String get darkBg => isTurkish ? 'Koyu Zemin' : 'Dark';
  String get textColor => isTurkish ? 'Yazı Rengi' : 'Text Color';
  String get colorBlack => isTurkish ? 'Siyah' : 'Black';
  String get colorWhite => isTurkish ? 'Beyaz' : 'White';
  String get colorCream => isTurkish ? 'Krem' : 'Cream';
  String get colorPink => isTurkish ? 'Pembe' : 'Pink';
  String get colorBlue => isTurkish ? 'Mavi' : 'Blue';
  String get samsungLockScreenGuide => isTurkish ? 'Samsung Kilit Ekranı Rehberi' : 'Samsung Lock Screen Guide';
  String get samsungLockScreenDesc => isTurkish
      ? 'Samsung One UI, kilit ekranında doğrudan yalnızca kendi sistem uygulamalarını listeler. Calenda widget\'ını kilit ekranına eklemek için:'
      : 'Samsung One UI only lists system apps on the lock screen by default. To add the Calenda widget:';
  String get samsungStep1 => isTurkish
      ? 'Galaxy Store\'dan Good Lock uygulamasını indirin.'
      : 'Download Good Lock from the Galaxy Store.';
  String get samsungStep2 => isTurkish
      ? 'Good Lock içinden LockStar eklentisini kurun.'
      : 'Install LockStar inside Good Lock.';
  String get samsungStep3 => isTurkish
      ? 'LockStar\'ı açıp kilit ekranına dokunun, "+" butonundan Calenda widget\'ını ekleyin.'
      : 'Open LockStar, tap lock screen, and add Calenda widget via the "+" button.';
  String get iosWidgetInstructionsTitle => isTurkish ? 'iPhone Ana Ekranına Widget Ekleme' : 'Add Widget to iPhone Home Screen';
  String get iosWidgetInstructionsDesc => isTurkish
      ? 'Apple güvenlik kuralları gereği widget\'lar doğrudan iPhone ana ekranından eklenir:'
      : 'Due to iOS system guidelines, widgets are placed directly from the Home Screen:';
  String get iosStep1Title => isTurkish ? 'Ana Ekrana Basılı Tutun' : 'Touch & Hold Home Screen';
  String get iosStep1Desc => isTurkish ? 'Boş bir alana uygulamalar titreyene kadar basılı tutun.' : 'Press and hold an empty space until apps jiggle.';
  String get iosStep2Title => isTurkish ? 'Sol Üstteki (+) İkonuna Dokunun' : 'Tap (+) in the Top Left';
  String get iosStep2Desc => isTurkish ? 'Apple widget galerisini açın.' : 'Open the iOS widget gallery.';
  String get iosStep3Title => isTurkish ? 'Calenda\'yı Seçip Ekleyin' : 'Select Calenda & Add';
  String get iosStep3Desc => isTurkish ? 'Calenda widget\'ını seçip "Widget Ekle" butonuna basın.' : 'Select the Calenda widget and tap "Add Widget".';
  String get gotIt => isTurkish ? 'Tamamdır, Anladım' : 'Got It';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Kolay erişim extension'ı: `context.l10n`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
