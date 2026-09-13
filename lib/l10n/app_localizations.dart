import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Supported language definitions with code, English name, and native script name.
enum AppLanguage {
  english('en', 'English', 'English'),
  hindi('hi', 'Hindi', 'हिन्दी'),
  tamil('ta', 'Tamil', 'தமிழ்'),
  telugu('te', 'Telugu', 'తెలుగు'),
  malayalam('ml', 'Malayalam', 'മലയാളം'),
  kannada('kn', 'Kannada', 'ಕನ್ನಡ');

  final String code;
  final String englishName;
  final String nativeName;

  const AppLanguage(this.code, this.englishName, this.nativeName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Production localized string provider for SensAura AI.
/// Supports 6 languages: English, Hindi, Tamil, Telugu, Malayalam, Kannada.
/// 100% offline-first, compile-time safe, and zero cloud dependencies.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te'),
    Locale('ml'),
    Locale('kn'),
  ];

  static const List<String> supportedLocaleCodes = [
    'en',
    'hi',
    'ta',
    'te',
    'ml',
    'kn',
  ];

  String get _code => locale.languageCode;

  // App & Shell
  String get appName => 'SensAura AI';
  String get appTagline => _get({
        'en': 'Sense your world. Shape your space.',
        'hi': 'अपनी दुनिया को समझें। अपने स्थान को आकार दें।',
        'ta': 'உங்கள் உலகத்தை உணருங்கள். உங்கள் இடத்தை வடிவமைக்கவும்.',
        'te': 'మీ ప్రపంచాన్ని గ్రహించండి. మీ స్పేస్‌ను రూపొందించండి.',
        'ml': 'നിങ്ങളുടെ ലോകത്തെ അറിയുക. നിങ്ങളുടെ ഇടം ക്രമീകരിക്കുക.',
        'kn': 'ನಿಮ್ಮ ಪ್ರಪಂಚವನ್ನು ಗ್ರಹಿಸಿ. ನಿಮ್ಮ ಸ್ಥಳವನ್ನು ರೂಪಿಸಿ.',
      });

  String get offlineNotice => _get({
        'en': 'OFFLINE-FIRST • ON-DEVICE RULES',
        'hi': 'ऑफलाइन-फर्स्ट • ऑन-डिवाइस नियम',
        'ta': 'ஆஃப்லைன்-முதன்மை • சாதனத்தில் இயங்கும் விதிகள்',
        'te': 'ఆఫ్‌లైన్-ఫస్ట్ • పరికరంలో నడిచే నియమాలు',
        'ml': 'ഓഫ്‌ലൈൻ-ആദ്യം • ഉപകരണത്തിലെ നിയമങ്ങൾ',
        'kn': 'ಆಫ್‌ಲೈನ್-ಪ್ರಥಮ • ಸಾಧನದಲ್ಲಿನ ನಿಯಮಗಳು',
      });

  String get hardware => _get({
        'en': 'HARDWARE',
        'hi': 'हार्डवेयर',
        'ta': 'ஹார்டுவேர்',
        'te': 'హార్డ్‌వేర్',
        'ml': 'ഹാർഡ്‌വെയർ',
        'kn': 'ಹಾರ್ಡ್‌ವೇರ್',
      });

  String get hardwareUnavailable => _get({
        'en': 'HARDWARE UNAVAILABLE',
        'hi': 'हार्डवेयर अनुपलब्ध',
        'ta': 'ஹார்டுவேர் கிடைக்கவில்லை',
        'te': 'హార్డ్‌వేర్ అందుబాటులో లేదు',
        'ml': 'ഹാർഡ്‌വെയർ ലഭ്യമല്ല',
        'kn': 'ಹಾರ್ಡ್‌ವೇರ್ ಲಭ್ಯವಿಲ್ಲ',
      });

  String get demoMode => _get({
        'en': 'DEMO MODE',
        'hi': 'डेमो मोड',
        'ta': 'டெமோ பயன்முறை',
        'te': 'డెమో మోడ్',
        'ml': 'ഡെമോ മോഡ്',
        'kn': 'ಡೆಮೊ ಮೋಡ್',
      });

  String get statusLocal => _get({
        'en': 'LOCAL',
        'hi': 'लोकल',
        'ta': 'லோக்கல்',
        'te': 'లోకల్',
        'ml': 'ലോക്കൽ',
        'kn': 'ಸ್ಥಳೀಯ',
      });

  String get statusSensorStream => _get({
        'en': 'SENSOR STREAM',
        'hi': 'सेंसर स्ट्रीम',
        'ta': 'சென்சார் ஸ்ட்ரீம்',
        'te': 'సెన్సార్ స్ట్రీమ్',
        'ml': 'സെൻസർ സ്ട്രീം',
        'kn': 'ಸಂವೇದಕ ಸ್ಟ್ರೀಮ್',
      });

  String get statusSensorUnavailable => _get({
        'en': 'SENSOR UNAVAILABLE',
        'hi': 'सेंसर अनुपलब्ध',
        'ta': 'சென்சார் கிடைக்கவில்லை',
        'te': 'సెన్సార్ అందుబాటులో లేదు',
        'ml': 'സെൻസർ ലഭ്യമല്ല',
        'kn': 'ಸಂವೇದಕ ಲಭ್ಯವಿಲ್ಲ',
      });

  String get statusBleConnected => _get({
        'en': 'BLE CONNECTED',
        'hi': 'BLE कनेक्टेड',
        'ta': 'BLE இணைக்கப்பட்டது',
        'te': 'BLE కనెక్ట్ చేయబడింది',
        'ml': 'BLE കണക്റ്റുചെയ്‌തു',
        'kn': 'BLE ಸಂಪರ್ಕಗೊಂಡಿದೆ',
      });

  String get statusBleUnavailable => _get({
        'en': 'BLE UNAVAILABLE',
        'hi': 'BLE अनुपलब्ध',
        'ta': 'BLE கிடைக்கவில்லை',
        'te': 'BLE అందుబాటులో లేదు',
        'ml': 'BLE ലഭ്യമല്ല',
        'kn': 'BLE ಲಭ್ಯವಿಲ್ಲ',
      });

  String get selectLanguage => _get({
        'en': 'Select Language',
        'hi': 'भाषा चुनें',
        'ta': 'மொழி தேர்வு',
        'te': 'భాషను ఎంచుకోండి',
        'ml': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
        'kn': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      });

  String get languageChanged => _get({
        'en': 'Language changed',
        'hi': 'भाषा बदल दी गई',
        'ta': 'மொழி மாற்றப்பட்டது',
        'te': 'భాష మార్చబడింది',
        'ml': 'ഭാഷ മാറ്റി',
        'kn': 'ಭಾಷೆ ಬದಲಾಗಿದೆ',
      });

  // Navigation Tabs
  String get tabHome => _get({
        'en': 'Home',
        'hi': 'होम',
        'ta': 'முகப்பு',
        'te': 'హోమ్',
        'ml': 'ഹോം',
        'kn': 'ಮುಖಪುಟ',
      });

  String get tabSensors => _get({
        'en': 'Sensors',
        'hi': 'सेंसर',
        'ta': 'சென்சார்கள்',
        'te': 'సెన్సార్లు',
        'ml': 'സെൻസറുകൾ',
        'kn': 'ಸಂವೇದಕಗಳು',
      });

  String get tabEnvironment => _get({
        'en': 'Environment',
        'hi': 'वातावरण',
        'ta': 'சூழல்',
        'te': 'వాతావరణం',
        'ml': 'പരിസ്ഥിതി',
        'kn': 'ಪರಿಸರ',
      });

  String get tabAiContext => _get({
        'en': 'AI Context',
        'hi': 'एआई संदर्भ',
        'ta': 'AI சூழல்',
        'te': 'AI సందర్భం',
        'ml': 'AI പശ്ചാത്തലം',
        'kn': 'AI ಸನ್ನಿವೇಶ',
      });

  String get tabHistory => _get({
        'en': 'History',
        'hi': 'इतिहास',
        'ta': 'வரலாறு',
        'te': 'చరిత్ర',
        'ml': 'ചരിത്രം',
        'kn': 'ಇತಿಹಾಸ',
      });

  // Context States (Section 7)
  String get contextFocus => _get({
        'en': 'Focus',
        'hi': 'ध्यान',
        'ta': 'கவனம்',
        'te': 'దృష్టి',
        'ml': 'ഏകാഗ്രത',
        'kn': 'ಏಕಾಗ್ರತೆ',
      });

  String get contextRest => _get({
        'en': 'Rest',
        'hi': 'विश्राम',
        'ta': 'ஓய்வு',
        'te': 'విశ్రాంతి',
        'ml': 'വിശ്രമം',
        'kn': 'ವಿಶ್ರಾಂತಿ',
      });

  String get contextBreak => _get({
        'en': 'Break',
        'hi': 'विराम',
        'ta': 'இடைவேளை',
        'te': 'విరామం',
        'ml': 'ഇടവേള',
        'kn': 'ವಿರಾಮ',
      });

  String get contextArriving => _get({
        'en': 'Arriving',
        'hi': 'आगमन',
        'ta': 'வருகை',
        'te': 'రాక',
        'ml': 'വരവ്',
        'kn': 'ಆಗಮನ',
      });

  String get contextLeaving => _get({
        'en': 'Leaving',
        'hi': 'प्रस्थान',
        'ta': 'புறப்படுதல்',
        'te': 'బయలుదేరు',
        'ml': 'പുറപ്പെടൽ',
        'kn': 'ನಿರ್ಗಮನ',
      });

  String get contextSleep => _get({
        'en': 'Sleep',
        'hi': 'नींद',
        'ta': 'தூக்கம்',
        'te': 'నిద్ర',
        'ml': 'ഉറക്കം',
        'kn': 'ನಿದ್ರೆ',
      });

  String get contextNeutral => _get({
        'en': 'Neutral',
        'hi': 'सामान्य',
        'ta': 'இயல்பு',
        'te': 'సాధారణం',
        'ml': 'സാധാരണം',
        'kn': 'ಸಾಮಾನ್ಯ',
      });

  String get contextUncertain => _get({
        'en': 'Uncertain',
        'hi': 'अनिश्चित',
        'ta': 'உறுதியற்றது',
        'te': 'అనిశ్చితం',
        'ml': 'അനിശ്ചിതം',
        'kn': 'ಅನಿಶ್ಚಿತ',
      });

  String get contextFocusFull => _get({
        'en': 'Deep Focus',
        'hi': 'गहरा ध्यान',
        'ta': 'ஆழ்ந்த கவனம்',
        'te': 'గాఢమైన దృష్టి',
        'ml': 'ആഴത്തിലുള്ള ഏകാഗ്രത',
        'kn': 'ತೀವ್ರ ಏಕಾಗ್ರತೆ',
      });

  String get contextRestFull => _get({
        'en': 'Rest Mode',
        'hi': 'विश्राम मोड',
        'ta': 'ஓய்வு பயன்முறை',
        'te': 'విశ్రాంతి మోడ్',
        'ml': 'വിശ്രമ മോഡ്',
        'kn': 'ವಿಶ್ರಾಂತಿ ಮೋಡ್',
      });

  String get contextBreakFull => _get({
        'en': 'Break Time',
        'hi': 'विराम समय',
        'ta': 'இடைவேளை நேரம்',
        'te': 'విరామ సమయం',
        'ml': 'ഇടവേള സമയം',
        'kn': 'ವಿರಾಮ ಸಮಯ',
      });

  String get contextArrivingFull => _get({
        'en': 'Arriving / Back',
        'hi': 'आगमन / वापसी',
        'ta': 'வருகை / திரும்புதல்',
        'te': 'రాక / తిరిగి రావడం',
        'ml': 'വരവ് / തിരിച്ചെത്തൽ',
        'kn': 'ಆಗಮನ / ಹಿಂತಿರುಗುವಿಕೆ',
      });

  String get contextLeavingFull => _get({
        'en': 'Leaving Workstation',
        'hi': 'कार्यस्थल से प्रस्थान',
        'ta': 'பணிநிலையத்தை விட்டுச் செல்லுதல்',
        'te': 'వర్క్‌స్టేషన్ నుండి నిష్క్రమణ',
        'ml': 'വർക്ക്സ്റ്റേഷനിൽ നിന്നുള്ള പുറപ്പെടൽ',
        'kn': 'ಕೆಲಸದ ಸ್ಥಳದಿಂದ ನಿರ್ಗಮನ',
      });

  String get contextSleepFull => _get({
        'en': 'Night Rest',
        'hi': 'रात्रि विश्राम',
        'ta': 'இரவு ஓய்வு',
        'te': 'రాత్రి విశ్రాంతి',
        'ml': 'രാത്രി വിശ്രമം',
        'kn': 'ರಾತ್ರಿ ವಿಶ್ರಾಂತಿ',
      });

  String get contextNeutralFull => _get({
        'en': 'Active Normal',
        'hi': 'सक्रिय सामान्य',
        'ta': 'செயலில் உள்ள இயல்பு',
        'te': 'క్రియాశీల సాధారణం',
        'ml': 'സജീവ സാധാരണം',
        'kn': 'ಸಕ್ರಿಯ ಸಾಮಾನ್ಯ',
      });

  String get contextUncertainFull => _get({
        'en': 'Uncertain Context',
        'hi': 'अनिश्चित संदर्भ',
        'ta': 'உறுதியற்ற சூழல்',
        'te': 'అనిశ్చిత సందర్భం',
        'ml': 'അനിശ്ചിത പശ്ചാത്തലം',
        'kn': 'ಅನಿಶ್ಚಿತ ಸನ್ನಿವೇಶ',
      });

  // Context Guard States (Section 8)
  String get guardAutoSafe => _get({
        'en': 'AUTO_SAFE',
        'hi': 'स्वचालित कार्रवाई सुरक्षित',
        'ta': 'தானியங்கி செயல்முறை பாதுகாப்பானது',
        'te': 'స్వయంచాలక చర్య సురಕ್ಷితం',
        'ml': 'ഓട്ടോമാറ്റിക് പ്രവർത്തനം സുരക്ഷിതം',
        'kn': 'ಸ್ವಯಂಚಾಲಿತ ಕ್ರಮ ಸುರಕ್ಷಿತ',
      });

  String get guardAskUser => _get({
        'en': 'ASK_USER',
        'hi': 'उपयोगकर्ता की पुष्टि आवश्यक',
        'ta': 'பயனர் உறுதிப்படுத்தல் தேவை',
        'te': 'వినియోగదారు నిర్ధారణ అవసరం',
        'ml': 'ഉപയോക്തൃ സ്ഥിരീകരണം ആവശ്യമാണ്',
        'kn': 'ಬಳಕೆದಾರರ ದೃಢೀಕರಣ ಅಗತ್ಯ',
      });

  String get guardNoAction => _get({
        'en': 'NO_ACTION',
        'hi': 'कोई कार्रवाई नहीं',
        'ta': 'எந்த நடவடிக்கையும் இல்லை',
        'te': 'ఎలాంటి చర్య లేదు',
        'ml': 'നടപടിയൊന്നുമില്ല',
        'kn': 'ಯಾವುದೇ ಕ್ರಮವಿಲ್ಲ',
      });

  String get guardActionSafe => _get({
        'en': 'AUTO SAFE',
        'hi': 'सुरक्षित कार्रवाई',
        'ta': 'பாதுகாப்பானது',
        'te': 'సురక్షిత చర్య',
        'ml': 'സുരക്ഷിത പ്രവർത്തനം',
        'kn': 'ಸುರಕ್ಷಿತ ಕ್ರಮ',
      });

  String get guardConfirmationRequired => _get({
        'en': 'CONFIRMATION REQUIRED',
        'hi': 'पुष्टि आवश्यक',
        'ta': 'உறுதிப்படுத்தல் தேவை',
        'te': 'నిర్ధారణ అవసరం',
        'ml': 'സ്ഥിരീകരണം ആവശ്യമാണ്',
        'kn': 'ದೃಢೀಕರಣ ಅಗತ್ಯವಿದೆ',
      });

  String get guardAutomationPaused => _get({
        'en': 'AUTOMATION PAUSED',
        'hi': 'स्वचालन रोका गया',
        'ta': 'தானியங்கு இடைநிறுத்தப்பட்டது',
        'te': 'ఆటోమేషన్ పాజ్ చేయబడింది',
        'ml': 'ഓട്ടോമേഷൻ താൽക്കാലികമായി നിർത്തി',
        'kn': 'ಸ್ವಯಂಚಾಲಿತ ಸ್ಥಗಿತಗೊಂಡಿದೆ',
      });

  String get guardConflictingSignals => _get({
        'en': 'Conflicting Signals',
        'hi': 'परस्पर विरोधी संकेत',
        'ta': 'முரண்பாடான சமிக்ஞைகள்',
        'te': 'పరస్పర విరుద్ధమైన సంకేతాలు',
        'ml': 'പരസ്പരവിരുദ്ധമായ സിഗ്നലുകൾ',
        'kn': 'ಪರಸ್ಪರ ವಿರುದ್ಧ ಸಂಕೇತಗಳು',
      });

  String get guardManualOverrideActive => _get({
        'en': 'MANUAL OVERRIDE ACTIVE',
        'hi': 'मैनुअल नियंत्रण सक्रिय',
        'ta': 'கைமுறை கட்டுப்பாடு செயலில் உள்ளது',
        'te': 'మాన్యువల్ నియంత్రణ సక్రియంగా ఉంది',
        'ml': 'മാനുവൽ നിയന്ത്രണം സജീവം',
        'kn': 'ಹಸ್ತಚಾಲಿತ ನಿಯಂತ್ರಣ ಸಕ್ರಿಯ',
      });

  String get guardCooldownActive => _get({
        'en': 'COOLDOWN ACTIVE',
        'hi': 'कूलडाउन सक्रिय',
        'ta': 'கூலிங் இடைவேளை செயலில் உள்ளது',
        'te': 'కూల్‌డౌన్ సక్రియంగా ఉంది',
        'ml': 'കൂൾഡൗൺ സജീവം',
        'kn': 'ಕೂಲ್‌ಡೌನ್ ಸಕ್ರಿಯ',
      });

  // Gestures (Section 9)
  String get gestureOpenPalm => _get({
        'en': 'Open Palm (✋)',
        'hi': 'खुली हथेली (✋)',
        'ta': 'திறந்த உள்ளங்கை (✋)',
        'te': 'తెరిచిన అరచేయి (✋)',
        'ml': 'തുറന്ന കൈപ്പത്തി (✋)',
        'kn': 'ತೆರೆದ ಹಸ್ತ (✋)',
      });

  String get gestureClosedFist => _get({
        'en': 'Closed Fist (✊)',
        'hi': 'बंद मुट्ठी (✊)',
        'ta': 'மூடிய கைப்பிடி (✊)',
        'te': 'మూసిన పిడికిలి (✊)',
        'ml': 'അടഞ്ഞ മുഷ്ടി (✊)',
        'kn': 'ಮುಚ್ಚಿದ ಮುಷ್ಟಿ (✊)',
      });

  String get gestureThumbUp => _get({
        'en': 'Thumb Up (👍)',
        'hi': 'अंगूठा ऊपर (👍)',
        'ta': 'பெருவிரல் மேலே (👍)',
        'te': 'బొటనవేలు పైకి (👍)',
        'ml': 'തള്ളവിരൽ മുകളിലേക്ക് (👍)',
        'kn': 'ಹೆಬ್ಬೆರಳು ಮೇಲಕ್ಕೆ (👍)',
      });

  String get gestureThumbDown => _get({
        'en': 'Thumb Down (👎)',
        'hi': 'अंगूठा नीचे (👎)',
        'ta': 'பெருவிரல் கீழே (👎)',
        'te': 'బొటనవేలు క్రిందికి (👎)',
        'ml': 'തള്ളവിരൽ താഴേക്ക് (👎)',
        'kn': 'ಹೆಬ್ಬೆರಳು ಕೆಳಕ್ಕೆ (👎)',
      });

  String get gestureVictory => _get({
        'en': 'Victory / V-Sign (✌️)',
        'hi': 'विजय संकेत (✌️)',
        'ta': 'வெற்றி அடையாளம் (✌️)',
        'te': 'విజయ సంకేతం (✌️)',
        'ml': 'വിജയ അടയാളം (✌️)',
        'kn': 'ವಿಜಯದ ಸಂಕೇತ (✌️)',
      });

  String get gesturePointingUp => _get({
        'en': 'Pointing Up (☝️)',
        'hi': 'ऊपर इशारा (☝️)',
        'ta': 'மேல்நோக்கி சுட்டுதல் (☝️)',
        'te': 'పైకి చూపిస్తూ (☝️)',
        'ml': 'മുകളിലേക്ക് ചൂണ്ടുന്നു (☝️)',
        'kn': 'ಮೇಲಕ್ಕೆ ತೋರಿಸುವುದು (☝️)',
      });

  String get gestureNone => _get({
        'en': 'No Gesture',
        'hi': 'कोई इशारा नहीं',
        'ta': 'சைகை இல்லை',
        'te': 'సంకేతం లేదు',
        'ml': 'ആംഗ്യമില്ല',
        'kn': 'ಯಾವುದೇ ಸನ್ನೆ ಇಲ್ಲ',
      });

  String get gestureUnknown => _get({
        'en': 'Unrecognized',
        'hi': 'अपरिचित',
        'ta': 'அடையாளம் தெரியவில்லை',
        'te': 'గుర్తించబడలేదు',
        'ml': 'തിരിച്ചറിയാത്തത്',
        'kn': 'ಗುರುತಿಸಲಾಗದ',
      });

  String get gestureActionPause => _get({
        'en': 'Pause automation / lock current environment',
        'hi': 'स्वचालन रोकें / वर्तमान स्थान सुरक्षित रखें',
        'ta': 'தானியங்கியை நிறுத்து / தற்போதைய சூழலை பூட்டு',
        'te': 'ఆటోమేషన్‌ను పాజ్ చేయండి / ప్రస్తుత స్థలాన్ని లాక్ చేయండి',
        'ml': 'ഓട്ടോമേഷൻ നിർത്തുക / നിലവിലെ ഇടം പൂട്ടുക',
        'kn': 'ಸ್ವಯಂಚಾಲಿತ ನಿಲ್ಲಿಸಿ / ಪ್ರಸ್ತುತ ಪರಿಸರ ಲಾಕ್ ಮಾಡಿ',
      });

  String get gestureActionConfirm => _get({
        'en': 'Explicitly confirm recommended scene',
        'hi': 'अनुशंसित दृश्य की पुष्टि करें',
        'ta': 'பரிந்துரைக்கப்பட்ட அமைப்பை உறுதிப்படுத்தவும்',
        'te': 'సిఫార్సు చేసిన దృశ్యాన్ని స్పష్టంగా నిర్ధారించండి',
        'ml': 'ശുപാർശ ചെയ്യുന്ന രംഗം വ്യക്തമായി സ്ഥിരീകരിക്കുക',
        'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ದೃಶ್ಯವನ್ನು ಸ್ಪಷ್ಟವಾಗಿ ದೃಢೀಕರಿಸಿ',
      });

  String get gestureActionReject => _get({
        'en': 'Reject recommended scene',
        'hi': 'अनुशंसित दृश्य अस्वीकार करें',
        'ta': 'பரிந்துரைக்கப்பட்ட அமைப்பை நிராகரி',
        'te': 'సిఫార్సు చేసిన దృశ్యాన్ని తిరస్కరించండి',
        'ml': 'ശുപാർശ ചെയ്യുന്ന രംഗം നിരസിക്കുക',
        'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ದೃಶ್ಯವನ್ನು ತಿರಸ್ಕರಿಸಿ',
      });

  String get gestureActionFocus => _get({
        'en': 'Trigger Deep Focus profile',
        'hi': 'गहरा ध्यान प्रोफ़ाइल सक्रिय करें',
        'ta': 'ஆழ்ந்த கவனம் சுயவிவரத்தை இயக்கவும்',
        'te': 'గాఢ దృష్టి ప్రొఫైల్‌ను సక్రియం చేయండి',
        'ml': 'ആഴത്തിലുള്ള ഏകാഗ്രതാ പ്രൊഫൈൽ പ്രവർത്തനക്ഷമമാക്കുക',
        'kn': 'ತೀವ್ರ ಏಕಾಗ್ರತೆ ಪ್ರೊಫೈಲ್ ಸಕ್ರಿಯಗೊಳಿಸಿ',
      });

  String get gestureActionRest => _get({
        'en': 'Trigger Quiet / Rest profile',
        'hi': 'शांत / विश्राम प्रोफ़ाइल सक्रिय करें',
        'ta': 'அமைதி / ஓய்வு சுயவிவரத்தை இயக்கவும்',
        'te': 'నిశ్శబ్ద / విశ్రాంతి ప్రొఫైల్‌ను ప్రారంభించండి',
        'ml': 'ശാന്തമായ / വിശ്രമ പ്രൊഫൈൽ പ്രവർത്തനക്ഷമമാക്കുക',
        'kn': 'ಶಾಂತ / ವಿಶ್ರಾಂತಿ ಪ್ರೊಫೈಲ್ ಸಕ್ರಿಯಗೊಳಿಸಿ',
      });

  String get gestureActionCycle => _get({
        'en': 'Cycle to next recommended profile',
        'hi': 'अगले अनुशंसित प्रोफ़ाइल पर जाएं',
        'ta': 'அடுத்த பரிந்துரைக்கப்பட்ட சுயவிவரத்திற்கு மாறவும்',
        'te': 'తదుపరి సిఫార్సు చేసిన ప్రొఫైల్‌కు మారండి',
        'ml': 'അടുത്ത ശുപാർശിത പ്രൊഫൈലിലേക്ക് മാറുക',
        'kn': 'ಮುಂದಿನ ಶಿಫಾರಸು ಮಾಡಿದ ಪ್ರೊಫೈಲ್‌ಗೆ ಬದಲಾಯಿಸಿ',
      });

  // Observable Expression Signals
  String get signalCalm => _get({
        'en': 'Calm Signal',
        'hi': 'शांत संकेत',
        'ta': 'அமைதியான சமிக்ஞை',
        'te': 'ప్రశాంత సంకేతం',
        'ml': 'ശാന്തമായ സിഗ്നൽ',
        'kn': 'ಶಾಂತ ಸಂಕೇತ',
      });

  String get signalEngaged => _get({
        'en': 'Engaged Focus',
        'hi': 'सक्रिय एकाग्रता',
        'ta': 'ஈடுபாட்டுடன் கூடிய கவனம்',
        'te': 'నిమగ్నమైన దృష్టి',
        'ml': 'സജീവമായ ഏകാഗ്രത',
        'kn': 'ತೊಡಗಿಸಿಕೊಂಡ ಏಕಾಗ್ರತೆ',
      });

  String get signalPositive => _get({
        'en': 'Positive Expression',
        'hi': 'सकारात्मक अभिव्यक्ति',
        'ta': 'நேர்மறையான வெளிப்பாடு',
        'te': 'సానుకూల వ్యక్తీకరణ',
        'ml': 'പോസിറ്റീവ് ഭാവം',
        'kn': 'ಧನಾತ್ಮಕ ಅಭಿವ್ಯಕ್ತಿ',
      });

  String get signalLowActivity => _get({
        'en': 'Low Activity',
        'hi': 'कम गतिविधि',
        'ta': 'குறைந்த செயல்பாடு',
        'te': 'తక్కువ కార్యాచరణ',
        'ml': 'കുറഞ്ഞ പ്രവർത്തനം',
        'kn': 'ಕಡಿಮೆ ಚಟುವಟಿಕೆ',
      });

  String get signalElevatedActivity => _get({
        'en': 'Elevated Activity',
        'hi': 'बढ़ी हुई गतिविधि',
        'ta': 'அதிகரித்த செயல்பாடு',
        'te': 'ఎక్కువ కార్యాచరణ',
        'ml': 'വർദ്ധിച്ച പ്രവർത്തനം',
        'kn': 'ಹೆಚ್ಚಿದ ಚಟುವಟಿಕೆ',
      });

  String get signalEyesClosed => _get({
        'en': 'Eyes Closed',
        'hi': 'आंखें बंद',
        'ta': 'கண்கள் மூடியுள்ளன',
        'te': 'కళ్ళు మూసుకున్నాయి',
        'ml': 'കണ്ണുകൾ അടഞ്ഞു',
        'kn': 'ಕಣ್ಣುಗಳು ಮುಚ್ಚಿವೆ',
      });

  String get signalNotDetected => _get({
        'en': 'Not Detected',
        'hi': 'पता नहीं चला',
        'ta': 'கண்டறியப்படவில்லை',
        'te': 'గుర్తించబడలేదు',
        'ml': 'കണ്ടെത്തിയില്ല',
        'kn': 'ಪತ್ತೆಯಾಗಿಲ್ಲ',
      });

  // Camera & Vision UI (Section 11)
  String get cameraLive => _get({
        'en': 'Live Camera',
        'hi': 'लाइव कैमरा',
        'ta': 'நேரடி கேமரா',
        'te': 'ప్రత్యక్ష కెమెరా',
        'ml': 'തത്സമയ ക്യാമറ',
        'kn': 'ಲೈವ್ ಕ್ಯಾಮೆರಾ',
      });

  String get cameraConnected => _get({
        'en': 'Camera Connected',
        'hi': 'कैमरा कनेक्टेड',
        'ta': 'கேமரா இணைக்கப்பட்டுள்ளது',
        'te': 'కెమెరా కనెక్ట్ చేయబడింది',
        'ml': 'ക്യാമറ കണക്റ്റുചെയ്‌തു',
        'kn': 'ಕ್ಯಾಮೆರಾ ಸಂಪರ್ಕಗೊಂಡಿದೆ',
      });

  String get cameraUnavailable => _get({
        'en': 'CAMERA UNAVAILABLE — SENSOR-ONLY MODE',
        'hi': 'कैमरा उपलब्ध नहीं है — केवल सेंसर मोड',
        'ta': 'கேமரா கிடைக்கவில்லை — சென்சார் மட்டும் பயன்முறை',
        'te': 'కెమెరా అందుబాటులో లేదు — సెన్సార్-మాత్రమే మోడ్',
        'ml': 'ക്യാമറ ലഭ്യമല്ല — സെൻസർ മാത്രമുള്ള മോഡ്',
        'kn': 'ಕ್ಯಾಮೆರಾ ಲಭ್ಯವಿಲ್ಲ — ಸಂವೇದಕ-ಮಾತ್ರ ಮೋಡ್',
      });

  String get cameraSensorOnly => _get({
        'en': 'CAMERA: SENSOR-ONLY MODE',
        'hi': 'कैमरा: केवल सेंसर मोड',
        'ta': 'கேமரா: சென்சார் மட்டும் பயன்முறை',
        'te': 'కెమెరా: సెన్సార్-మాత్రమే మోడ్',
        'ml': 'ക്യാമറ: സെൻസർ മാത്രമുള്ള മോഡ്',
        'kn': 'ಕ್ಯಾಮೆರಾ: ಸಂವೇದಕ-ಮಾತ್ರ ಮೋಡ್',
      });

  String get cameraHardwareActive => _get({
        'en': 'CAMERA: LIVE iQOO',
        'hi': 'कैमरा: लाइव iQOO',
        'ta': 'கேமரா: நேரடி iQOO',
        'te': 'కెమెరా: లైవ్ iQOO',
        'ml': 'ക്യാമറ: ലൈവ് iQOO',
        'kn': 'ಕ್ಯಾಮೆರಾ: ಲೈವ್ iQOO',
      });

  String get cameraRetry => _get({
        'en': 'RETRY',
        'hi': 'पुनः प्रयास',
        'ta': 'மீண்டும் முயற்சி',
        'te': 'మళ్ళీ ప్రయత్నించండి',
        'ml': 'വീണ്ടും ശ്രമിക്കുക',
        'kn': 'ಮರುಪ್ರಯತ್ನಿಸಿ',
      });

  String get showAiOverlay => _get({
        'en': 'SHOW AI OVERLAY',
        'hi': 'एआई ओवरले दिखाएं',
        'ta': 'AI மேலடுக்கைக் காட்டு',
        'te': 'AI ఓవర్‌లే చూపించు',
        'ml': 'AI ഓവർലേ കാണിക്കുക',
        'kn': 'AI ಓವರ್‌ಲೇ ತೋರಿಸಿ',
      });

  String get hideAiOverlay => _get({
        'en': 'HIDE AI OVERLAY',
        'hi': 'एआई ओवरले छिपाएं',
        'ta': 'AI மேலடுக்கை மறை',
        'te': 'AI ఓవర్‌లే దాచండి',
        'ml': 'AI ഓവർലേ മറയ്ക്കുക',
        'kn': 'AI ಓವರ್‌ಲೇ ಮರೆಮಾಡಿ',
      });

  String get personDetected => _get({
        'en': 'Person Detected',
        'hi': 'व्यक्ति का पता चला',
        'ta': 'நபர் கண்டறியப்பட்டார்',
        'te': 'వ్యక్తి కనుగొనబడింది',
        'ml': 'വ്യക്തിയെ കണ്ടെത്തി',
        'kn': 'ವ್ಯಕ್ತಿ ಪತ್ತೆಯಾಗಿದ್ದಾರೆ',
      });

  String get noPersonDetected => _get({
        'en': 'No Person Detected',
        'hi': 'कोई व्यक्ति नहीं मिला',
        'ta': 'நபர் எவரும் காணப்படவில்லை',
        'te': 'ఎవరూ కనుగొనబడలేదు',
        'ml': 'വ്യക്തിയെ കണ്ടെത്തിയില്ല',
        'kn': 'ಯಾರೂ ಕಂಡುಬಂದಿಲ್ಲ',
      });

  String get aiRuntime => _get({
        'en': 'AI RUNTIME',
        'hi': 'एआई रनटाइम',
        'ta': 'AI இயங்குதளம்',
        'te': 'AI రన్‌టైమ్',
        'ml': 'AI റൺടൈം',
        'kn': 'AI ರನ್‌ಟೈಮ್',
      });

  String get latency => _get({
        'en': 'LATENCY',
        'hi': 'विलंबता',
        'ta': 'தாமதம்',
        'te': 'లేటెన్సీ',
        'ml': 'ലേറ്റൻസി',
        'kn': 'ವಿಳಂಬ',
      });

  String get droppedFrames => _get({
        'en': 'DROPPED',
        'hi': 'छोड़े गए',
        'ta': 'தவறவிடப்பட்டது',
        'te': 'డ్రాప్ చేయబడింది',
        'ml': 'ഡ്രോപ്പ് ചെയ്തു',
        'kn': 'ಕೈಬಿಡಲಾಗಿದೆ',
      });

  String get privacyGuarantee => _get({
        'en': 'Volatile processing only • Zero cloud frames',
        'hi': 'केवल वोलेटाइल प्रोसेसिंग • शून्य क्लाउड फ्रेम्स',
        'ta': 'நினைவகத்தில் மட்டுமே செயலாக்கம் • கிளவுட் இல்லை',
        'te': 'కేవలం మెమరీ ప్రాసెసింగ్ • క్లౌడ్ డేటా లేదు',
        'ml': 'മെമ്മറി പ്രോസസ്സിംഗ് മാത്രം • ക്ലൗഡ് ഇല്ല',
        'kn': 'ಮೆಮೊರಿ ಪ್ರಕ್ರಿಯೆ ಮಾತ್ರ • ಯಾವುದೇ ಕ್ಲೌಡ್ ಇಲ್ಲ',
      });

  // Smart Environment & Devices (Section 10 & 12)
  String get demoEnvironment => 'DEMO ENVIRONMENT';

  String get demoEnvironmentDesc => _get({
        'en': 'Virtual smart environment for demonstration',
        'hi': 'प्रदर्शन के लिए वर्चुअल स्मार्ट वातावरण',
        'ta': 'செயல்விளக்கத்திற்கான மெய்நிகர் ஸ்மார்ட் சூழல்',
        'te': 'ప్రదర్శన కోసం వర్చువల్ స్మార్ట్ స్పేస్',
        'ml': 'ഡെമോയ്ക്കായുള്ള വെർച്വൽ സ്മാർട്ട് പരിസ്ഥിതി',
        'kn': 'ಪ್ರಾತ್ಯಕ್ಷಿಕೆಗಾಗಿ ವರ್ಚುವಲ್ ಸ್ಮಾರ್ಟ್ ಪರಿಸರ',
      });

  String get realBleDevice => _get({
        'en': 'Real BLE Device',
        'hi': 'वास्तविक BLE डिवाइस',
        'ta': 'உண்மையான BLE சாதனம்',
        'te': 'నిజమైన BLE పరికరం',
        'ml': 'യഥാർത്ഥ BLE ഉപകരണം',
        'kn': 'ನೈಜ BLE ಸಾಧನ',
      });

  String get workstationCompanion => _get({
        'en': 'Workstation Companion',
        'hi': 'वर्कस्टेशन साथी',
        'ta': 'பணிநிலைய துணை சாதனம்',
        'te': 'వర్క్‌స్టేషన్ సహచరుడు',
        'ml': 'വർക്ക്സ്റ്റേഷൻ കൂട്ടാളി',
        'kn': 'ಕೆಲಸದ ಸ್ಥಳದ ಒಡನಾಡಿ',
      });

  String get smartLight => _get({
        'en': 'Smart Light',
        'hi': 'स्मार्ट लाइट',
        'ta': 'ஸ்மார்ட் விளக்கு',
        'te': 'స్మార్ట్ లైట్',
        'ml': 'സ്മാർട്ട് ലൈറ്റ്',
        'kn': 'ಸ್ಮಾರ್ಟ್ ಲೈಟ್',
      });

  String get airConditioner => _get({
        'en': 'Air Conditioner / Climate',
        'hi': 'एयर कंडीशनर / जलवायु',
        'ta': 'குளிரூட்டி / தட்பவெப்பநிலை',
        'te': 'ఎయిర్ కండీషనర్ / క్లైమేట్',
        'ml': 'എയർകണ്ടീഷണർ / കാലാവസ്ഥ',
        'kn': 'ಏರ್ ಕಂಡಿಷನರ್ / ಹವಾಮಾನ',
      });

  String get fan => _get({
        'en': 'Fan',
        'hi': 'पंखा',
        'ta': 'மின்விசிறி',
        'te': 'ఫ్యాన్',
        'ml': 'ഫാൻ',
        'kn': 'ಫ್ಯಾನ್',
      });

  String get speaker => _get({
        'en': 'Speaker',
        'hi': 'स्पीकर',
        'ta': 'ஸ்பீக்கர்',
        'te': 'స్పీకర్',
        'ml': 'സ്പീക്കർ',
        'kn': 'ಸ್ಪೀಕರ್',
      });

  String get smartSocket => _get({
        'en': 'Smart Socket',
        'hi': 'स्मार्ट सॉकेट',
        'ta': 'ஸ்மார்ட் சாக்கெட்',
        'te': 'స్మార్ట్ సాకెట్',
        'ml': 'സ്മാർട്ട് സോക്കറ്റ്',
        'kn': 'ಸ್ಮಾರ್ಟ್ ಸಾಕೆಟ್',
      });

  String get stateOn => _get({
        'en': 'ON',
        'hi': 'चालू',
        'ta': 'ஆன்',
        'te': 'ఆన్',
        'ml': 'ഓൺ',
        'kn': 'ಆನ್',
      });

  String get stateOff => _get({
        'en': 'OFF',
        'hi': 'बंद',
        'ta': 'ஆஃப்',
        'te': 'ఆఫ్',
        'ml': 'ഓഫ്',
        'kn': 'ಆಫ್',
      });

  String get stateConnected => _get({
        'en': 'CONNECTED',
        'hi': 'कनेक्टेड',
        'ta': 'இணைக்கப்பட்டது',
        'te': 'కనెక్ట్ అయింది',
        'ml': 'കണക്റ്റുചെയ്‌തു',
        'kn': 'ಸಂಪರ್ಕಗೊಂಡಿದೆ',
      });

  String get stateDisconnected => _get({
        'en': 'DISCONNECTED',
        'hi': 'डिस्कनेक्टेड',
        'ta': 'துண்டிக்கப்பட்டது',
        'te': 'డిస్‌కనెక్ట్ అయింది',
        'ml': 'വിച്ഛേദിച്ചു',
        'kn': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ',
      });

  String get stateAvailable => _get({
        'en': 'AVAILABLE',
        'hi': 'उपलब्ध',
        'ta': 'கிடைக்கிறது',
        'te': 'అందుబాటులో ఉంది',
        'ml': 'ലഭ്യമാണ്',
        'kn': 'ಲಭ್ಯವಿದೆ',
      });

  String get stateUnavailable => _get({
        'en': 'UNAVAILABLE',
        'hi': 'अनुपलब्ध',
        'ta': 'கிடைக்கவில்லை',
        'te': 'అందుబాటులో లేదు',
        'ml': 'ലഭ്യമല്ല',
        'kn': 'ಲಭ್ಯವಿಲ್ಲ',
      });

  String get statePendingAck => _get({
        'en': 'PENDING ACK',
        'hi': 'पुष्टि लंबित',
        'ta': 'ஒப்புதல் நிலுவையில் உள்ளது',
        'te': 'ధృవీకరణ పెండింగ్‌లో ఉంది',
        'ml': 'സ്ഥിരീകരണം കാത്തിരിക്കുന്നു',
        'kn': 'ದೃಢೀಕರಣ ಬಾಕಿ ಇದೆ',
      });

  String get stateAcknowledged => _get({
        'en': 'ACKNOWLEDGED',
        'hi': 'स्वीकृत',
        'ta': 'ஒப்புக்கொள்ளப்பட்டது',
        'te': 'ధృవీకరించబడింది',
        'ml': 'സ്ഥിരീകരിച്ചു',
        'kn': 'ದೃಢೀಕರಿಸಲಾಗಿದೆ',
      });

  String get manualOverrideLease => _get({
        'en': 'Manual Override Active',
        'hi': 'मैनुअल नियंत्रण सक्रिय',
        'ta': 'கைமுறை கட்டுப்பாடு செயலில் உள்ளது',
        'te': 'మాన్యువల్ నియంత్రణ సక్రియం',
        'ml': 'മാനുവൽ നിയന്ത്രണം സജീവം',
        'kn': 'ಹಸ್ತಚಾಲಿತ ನಿಯಂತ್ರಣ ಸಕ್ರಿಯ',
      });

  String get releaseOverride => _get({
        'en': 'RELEASE LOCK',
        'hi': 'नियंत्रण छोड़ें',
        'ta': 'பூட்டை விடுவிக்கவும்',
        'te': 'లాక్ విడుదల చేయండి',
        'ml': 'ലോക്ക് റിലീസ് ചെയ്യുക',
        'kn': 'ಲಾಕ್ ತೆರವುಗೊಳಿಸಿ',
      });

  String get resetCooldown => _get({
        'en': 'RESET COOLDOWN',
        'hi': 'कूलडाउन रीसेट करें',
        'ta': 'கூலிங் மீட்டமைக்க',
        'te': 'కూల్‌డౌన్ రీసెట్ చేయండి',
        'ml': 'കൂൾഡൗൺ റീസെറ്റ് ചെയ്യുക',
        'kn': 'ಕೂಲ್‌ಡೌನ್ ಮರುಹೊಂದಿಸಿ',
      });

  String get applyScene => _get({
        'en': 'APPLY NOW',
        'hi': 'अभी लागू करें',
        'ta': 'இப்போதே செயல்படுத்து',
        'te': 'ఇప్పుడే వర్తించు',
        'ml': 'ഇപ്പോൾ പ്രയോഗിക്കുക',
        'kn': 'ಈಗ ಅನ್ವಯಿಸಿ',
      });

  String get sceneApplied => _get({
        'en': 'Applied',
        'hi': 'लागू किया गया',
        'ta': 'செயல்படுத்தப்பட்டது',
        'te': 'వర్తించబడింది',
        'ml': 'പ്രയോഗിച്ചു',
        'kn': 'ಅನ್ವಯಿಸಲಾಗಿದೆ',
      });

  String get recommendedAutomation => _get({
        'en': 'Recommended Automation',
        'hi': 'अनुशंसित स्वचालन',
        'ta': 'பரிந்துரைக்கப்பட்ட தானியங்கு',
        'te': 'సిఫార్సు చేయబడిన ఆటోమేషన్',
        'ml': 'ശുപാർശ ചെയ്യുന്ന ഓട്ടോമേഷൻ',
        'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ಸ್ವಯಂಚಾಲಿತ',
      });

  String get connectedDevices => _get({
        'en': 'Connected Devices',
        'hi': 'कनेक्टेड डिवाइस',
        'ta': 'இணைக்கப்பட்ட சாதனங்கள்',
        'te': 'కనెక్ట్ చేయబడిన పరికరాలు',
        'ml': 'കണക്റ്റുചെയ്‌ത ഉപകരണങ്ങൾ',
        'kn': 'ಸಂಪರ್ಕಿತ ಸಾಧನಗಳು',
      });

  String get deviceControls => _get({
        'en': 'Device Controls',
        'hi': 'डिवाइस नियंत्रण',
        'ta': 'சாதனக் கட்டுப்பாடுகள்',
        'te': 'పరికర నియంత్రణలు',
        'ml': 'ഉപകരണ നിയന്ത്രണങ്ങൾ',
        'kn': 'ಸಾಧನ ನಿಯಂತ್ರಣಗಳು',
      });

  // History & Diagnostics
  String get auditLog => _get({
        'en': 'Audit Log',
        'hi': 'ऑडिट लॉग',
        'ta': 'தணிக்கை பதிவு',
        'te': 'ఆడిట్ లాగ్',
        'ml': 'ഓഡിറ്റ് ലോഗ്',
        'kn': 'ಆಡಿಟ್ ಲಾಗ್',
      });

  String get clearHistory => _get({
        'en': 'Clear History',
        'hi': 'इतिहास हटाएं',
        'ta': 'வரலாற்றை அழி',
        'te': 'చరిత్రను క్లియర్ చేయండి',
        'ml': 'ചരിത്രം മായ്ക്കുക',
        'kn': 'ಇತಿಹಾಸ ತೆರವುಗೊಳಿಸಿ',
      });

  String get historyEmpty => _get({
        'en': 'No automation events recorded yet',
        'hi': 'अभी तक कोई स्वचालन घटना दर्ज नहीं की गई है',
        'ta': 'இதுவரை எந்த நிகழ்வுகளும் பதிவாகவில்லை',
        'te': 'ఇంకా ఎలాంటి ఈవెంట్లు నమోదు కాలేదు',
        'ml': 'ഇതുവരെ ഇവന്റുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല',
        'kn': 'ಇನ್ನೂ ಯಾವುದೇ ಈವೆಂಟ್‌ಗಳು ದಾಖಲಾಗಿಲ್ಲ',
      });

  String get resumeAutomation => _get({
        'en': 'RESUME AUTOMATION',
        'hi': 'स्वचालन पुनः प्रारंभ करें',
        'ta': 'தானியங்கியைத் தொடரவும்',
        'te': 'ఆటోమేషన్‌ను పునఃప్రారంభించండి',
        'ml': 'ഓട്ടോമേഷൻ പുനരാരംഭിക്കുക',
        'kn': 'ಸ್ವಯಂಚಾಲಿತ ಪುನರಾರಂಭಿಸಿ',
      });

  String get pauseAutomation => _get({
        'en': 'PAUSE (✋)',
        'hi': 'रोकें (✋)',
        'ta': 'இடைநிறுத்து (✋)',
        'te': 'పాజ్ చేయండి (✋)',
        'ml': 'നിർത്തുക (✋)',
        'kn': 'ವಿರಾಮ (✋)',
      });

  String get confidence => _get({
        'en': 'Confidence',
        'hi': 'विश्वसनीयता',
        'ta': 'நம்பகத்தன்மை',
        'te': 'విశ్వసనీయత',
        'ml': 'വിശ്വാസ്യത',
        'kn': 'ವಿಶ್ವಾಸಾರ್ಹತೆ',
      });

  String get multimodalTelemetry => _get({
        'en': 'Multimodal Telemetry',
        'hi': 'मल्टीमॉडल टेलीमेट्री',
        'ta': 'பல்வகை தொலைநிலை அளவீடு',
        'te': 'మల్టీమోడల్ టెలిమెట్రీ',
        'ml': 'മൾട്ടിമോഡൽ ടെലിമെട്രി',
        'kn': 'ಮಲ್ಟಿಮೋಡಲ್ ಟೆಲಿಮೆಟ್ರಿ',
      });

  String get diagnosticTools => _get({
        'en': 'Developer Diagnostic Tools',
        'hi': 'डेवलपर निदान उपकरण',
        'ta': 'டெவலப்பர் கண்டறியும் கருவிகள்',
        'te': 'డెవలపర్ విశ్లేషణ సాధనాలు',
        'ml': 'ഡെവലപ്പർ ഡയഗ്നോസ്റ്റിക് ടൂളുകൾ',
        'kn': 'ಡೆವಲಪರ್ ರೋಗನಿರ್ಣಯ ಸಾಧನಗಳು',
      });

  String get rulesLocal => _get({
        'en': 'RULES: LOCAL',
        'hi': 'नियम: स्थानीय',
        'ta': 'விதிகள்: உள்ளூர்',
        'te': 'నియమాలు: లోకల్',
        'ml': 'നിയമങ്ങൾ: ലോക്കൽ',
        'kn': 'ನಿಯಮಗಳು: ಸ್ಥಳೀಯ',
      });

  String get zeroCloud => _get({
        'en': 'ZERO CLOUD',
        'hi': 'जीरो क्लाउड',
        'ta': 'கிளவுட் இல்லை',
        'te': 'క్లౌడ్ రహితం',
        'ml': 'ക്ലൗഡ് രഹിതം',
        'kn': 'ಕ್ಲೌಡ್ ರಹಿತ',
      });

  String get liveTelemetry => _get({
        'en': 'Live Telemetry',
        'hi': 'लाइव टेलीमेट्री',
        'ta': 'நேரடி அளவீடுகள்',
        'te': 'ప్రత్యక్ష టెలిమెట్రీ',
        'ml': 'തത്സമയ അളവുകൾ',
        'kn': 'ಲೈವ್ ಟೆಲಿಮೆಟ್ರಿ',
      });

  String get contextGuardTitle => _get({
        'en': 'SENSAURA CONTEXT GUARD',
        'hi': 'सेंसऑरा कॉन्टेक्स्ट गार्ड',
        'ta': 'சென்ஸாரா சூழல் காவலன்',
        'te': 'సెన్స్‌ఆరా కాంటెక్స్ట్ గార్డ్',
        'ml': 'സെൻസ്ഓറ കോൺടെക്സ്റ്റ് ഗാർഡ്',
        'kn': 'ಸೆನ್ಸ್‌ಆರಾ ಸನ್ನಿವೇಶ ರಕ್ಷಕ',
      });

  String get privacyLocalOnly => _get({
        'en': 'PRIVACY: LOCAL ONLY',
        'hi': 'गोपनीयता: केवल स्थानीय',
        'ta': 'தனியுரிமை: உள்ளூர் மட்டும்',
        'te': 'గోప్యత: స్థానికంగా మాత్రమే',
        'ml': 'സ്വകാര്യത: ലോക്കൽ മാത്രം',
        'kn': 'ಗೌಪ್ಯತೆ: ಸ್ಥಳೀಯ ಮಾತ್ರ',
      });

  String get signalsDetected => _get({
        'en': 'SIGNALS DETECTED',
        'hi': 'संकेत मिले',
        'ta': 'கண்டறியப்பட்ட சமிக்ஞைகள்',
        'te': 'గుర్తించిన సంకేతాలు',
        'ml': 'കണ്ടെത്തിയ സിഗ്നലുകൾ',
        'kn': 'ಪತ್ತೆಯಾದ ಸಂಕೇತಗಳು',
      });

  String get guardSafetyChecks => _get({
        'en': 'GUARD SAFETY CHECKS',
        'hi': 'गार्ड सुरक्षा जांच',
        'ta': 'காவலன் பாதுகாப்பு சோதனைகள்',
        'te': 'గార్డ్ భద్రతా తనిఖీలు',
        'ml': 'ഗാർഡ് സുരക്ഷാ പരിശോധനകൾ',
        'kn': 'ರಕ್ಷಕ ಸುರಕ್ಷತಾ ತಪಾಸಣೆಗಳು',
      });

  String get releaseLock => _get({
        'en': 'Release Lock',
        'hi': 'लॉक हटाएं',
        'ta': 'பூட்டை விடுவி',
        'te': 'లాక్ విడుదల',
        'ml': 'ലോക്ക് റിലീസ്',
        'kn': 'ಲಾಕ್ ತೆರವು',
      });

  String get resetTimer => _get({
        'en': 'Reset Timer',
        'hi': 'टाइमर रीसेट करें',
        'ta': 'டைமரை மீட்டமை',
        'te': 'టైమర్ రీసెట్',
        'ml': 'ടൈമർ റീസെറ്റ്',
        'kn': 'ಟೈಮರ್ ಮರುಹೊಂದಿಸಿ',
      });

  String get suggestedAutomation => _get({
        'en': 'SUGGESTED AUTOMATION',
        'hi': 'अनुशंसित स्वचालन',
        'ta': 'பரிந்துரைக்கப்பட்ட தானியங்கு',
        'te': 'సిఫార్సు చేయబడిన ఆటోమేషన్',
        'ml': 'ശുപാർശ ചെയ്യുന്ന ഓട്ടോമേഷൻ',
        'kn': 'ಶಿಫಾರಸು ಮಾಡಿದ ಸ್ವಯಂಚಾಲಿತ',
      });

  String get viewDevices => _get({
        'en': 'View Devices >',
        'hi': 'डिवाइस देखें >',
        'ta': 'சாதனங்களைக் காண்க >',
        'te': 'పరికరాలను చూడండి >',
        'ml': 'ഉപകരണങ്ങൾ കാണുക >',
        'kn': 'ಸಾಧನಗಳನ್ನು ವೀಕ್ಷಿಸಿ >',
      });

  String get signalsConflict => _get({
        'en': 'PAUSED • SIGNALS CONFLICT',
        'hi': 'रोका गया • विरोधी संकेत',
        'ta': 'இடைநிறுத்தப்பட்டது • முரண்பட்ட சமிக்ஞைகள்',
        'te': 'పాజ్ చేయబడింది • విరుద్ధ సంకేతాలు',
        'ml': 'നിർത്തിവെച്ചു • പരസ്പരവിരുദ്ധം',
        'kn': 'ಸ್ಥಗಿತಗೊಂಡಿದೆ • ವಿರುದ್ಧ ಸಂಕೇತಗಳು',
      });

  String get guardManualOverride => _get({
        'en': 'PAUSED • MANUAL OVERRIDE',
        'hi': 'रोका गया • मैन्युअल नियंत्रण',
        'ta': 'இடைநிறுத்தப்பட்டது • கைமுறை கட்டுப்பாடு',
        'te': 'పాజ్ చేయబడింది • మాన్యువల్ నియంత్రణ',
        'ml': 'നിർത്തിവെച്ചു • മാനുവൽ നിയന്ത്രണം',
        'kn': 'ಸ್ಥಗಿತಗೊಂಡಿದೆ • ಹಸ್ತಚಾಲಿತ ನಿಯಂತ್ರಣ',
      });

  String get guardLowConfidence => _get({
        'en': 'PAUSED • LOW CONFIDENCE',
        'hi': 'रोका गया • कम विश्वसनीयता',
        'ta': 'இடைநிறுத்தப்பட்டது • குறைந்த நம்பிக்கை',
        'te': 'పాజ్ చేయబడింది • తక్కువ విశ్వసనీయత',
        'ml': 'നിർത്തിവെച്ചു • കുറഞ്ഞ വിശ്വാസ്യത',
        'kn': 'ಸ್ಥಗಿತಗೊಂಡಿದೆ • ಕಡಿಮೆ ವಿಶ್ವಾಸಾರ್ಹತೆ',
      });

  String get actionApply => _get({
        'en': 'APPLY SCENE',
        'hi': 'दृश्य लागू करें',
        'ta': 'அமைப்பை செயல்படுத்து',
        'te': 'దృశ్యాన్ని వర్తించు',
        'ml': 'രംഗം പ്രയോഗിക്കുക',
        'kn': 'ದೃಶ್ಯ ಅನ್ವಯಿಸಿ',
      });

  String get sensorLight => _get({
        'en': 'Light',
        'hi': 'प्रकाश',
        'ta': 'ஒளி',
        'te': 'కాంతి',
        'ml': 'വെളിച്ചം',
        'kn': 'ಬೆಳಕು',
      });

  String get sensorMotion => _get({
        'en': 'Motion',
        'hi': 'गतिविधि',
        'ta': 'இயக்கம்',
        'te': 'కదలిక',
        'ml': 'ചലനം',
        'kn': 'ಚಲನೆ',
      });

  String get sensorProximity => _get({
        'en': 'Proximity',
        'hi': 'समीप्यता',
        'ta': 'அண்மை',
        'te': 'సామీప్యత',
        'ml': 'സാമീപ്യം',
        'kn': 'ಸಾಮೀಪ್ಯ',
      });

  String get stateStandby => _get({
        'en': 'Standby',
        'hi': 'स्टैंडबाय',
        'ta': 'காத்திருப்பு',
        'te': 'స్టాండ్‌బై',
        'ml': 'സ്റ്റാൻഡ്ബൈ',
        'kn': 'ಸ್ಟ್ಯಾಂಡ್‌ಬೈ',
      });

  String get liveHardware => _get({
        'en': 'LIVE HARDWARE',
        'hi': 'लाइव हार्डवेयर',
        'ta': 'நேரடி ஹார்டுவேர்',
        'te': 'లైవ్ హార్డ్‌వేర్',
        'ml': 'തത്സമയ ഹാർഡ്‌വെയർ',
        'kn': 'ಲೈವ್ ಹಾರ್ಡ್‌ವೇರ್',
      });

  String get demoSimulation => _get({
        'en': 'DEMO SIMULATION',
        'hi': 'डेमो सिमुलेशन',
        'ta': 'டெமோ உருவகப்படுத்துதல்',
        'te': 'డెమో సిమ్యులేషన్',
        'ml': 'ഡെമോ സിമുലേഷൻ',
        'kn': 'ಡೆಮೊ ಸಿಮ್ಯುಲೇಶನ್',
      });

  String get localAuditLog => _get({
        'en': 'LOCAL AUDIT LOG',
        'hi': 'स्थानीय ऑडिट लॉग',
        'ta': 'உள்ளூர் தணிக்கை பதிவு',
        'te': 'స్థానిక ఆడిట్ లాగ్',
        'ml': 'ലോക്കൽ ഓഡിറ്റ് ലോഗ്',
        'kn': 'ಸ್ಥಳೀಯ ಆಡಿಟ್ ಲಾಗ್',
      });

  String get clear => _get({
        'en': 'Clear',
        'hi': 'हटाएं',
        'ta': 'அழி',
        'te': 'క్లియర్',
        'ml': 'മായ്ക്കുക',
        'kn': 'ತೆರವುಗೊಳಿಸಿ',
      });

  String _get(Map<String, String> translations) {
    return translations[_code] ?? translations['en'] ?? '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocaleCodes
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
