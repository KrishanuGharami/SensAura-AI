import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/l10n/app_localizations.dart';
import 'package:sensaura_ai/models/ambient_context.dart';
import 'package:sensaura_ai/models/context_guard_result.dart';
import 'package:sensaura_ai/models/vision_context_sample.dart';
import 'package:sensaura_ai/services/local_storage_service.dart';
import 'package:sensaura_ai/widgets/status_app_bar.dart';

void main() {
  group('1. AppLanguage & Locales Validation', () {
    test('All 6 languages defined with proper codes and native script names', () {
      expect(AppLanguage.values.length, 6);

      final en = AppLanguage.fromCode('en');
      expect(en.code, 'en');
      expect(en.englishName, 'English');
      expect(en.nativeName, 'English');

      final hi = AppLanguage.fromCode('hi');
      expect(hi.code, 'hi');
      expect(hi.englishName, 'Hindi');
      expect(hi.nativeName, 'हिन्दी');

      final ta = AppLanguage.fromCode('ta');
      expect(ta.code, 'ta');
      expect(ta.englishName, 'Tamil');
      expect(ta.nativeName, 'தமிழ்');

      final te = AppLanguage.fromCode('te');
      expect(te.code, 'te');
      expect(te.englishName, 'Telugu');
      expect(te.nativeName, 'తెలుగు');

      final ml = AppLanguage.fromCode('ml');
      expect(ml.code, 'ml');
      expect(ml.englishName, 'Malayalam');
      expect(ml.nativeName, 'മലയാളം');

      final kn = AppLanguage.fromCode('kn');
      expect(kn.code, 'kn');
      expect(kn.englishName, 'Kannada');
      expect(kn.nativeName, 'ಕನ್ನಡ');
    });

    test('Fallback to English for unsupported locale codes', () {
      final unknown = AppLanguage.fromCode('fr');
      expect(unknown, AppLanguage.english);
    });
  });

  group('2. AppLocalizations Completeness across all 6 Languages', () {
    const codes = ['en', 'hi', 'ta', 'te', 'ml', 'kn'];

    for (final code in codes) {
      test('Complete string definitions for locale [$code]', () {
        final l10n = AppLocalizations(Locale(code));

        // App & Shell
        expect(l10n.appName, 'SensAura AI');
        expect(l10n.appTagline.isNotEmpty, true);
        expect(l10n.offlineNotice.isNotEmpty, true);
        expect(l10n.hardware.isNotEmpty, true);
        expect(l10n.demoMode.isNotEmpty, true);
        expect(l10n.statusLocal.isNotEmpty, true);
        expect(l10n.statusSensorStream.isNotEmpty, true);
        expect(l10n.selectLanguage.isNotEmpty, true);
        expect(l10n.languageChanged.isNotEmpty, true);

        // Navigation Tabs
        expect(l10n.tabHome.isNotEmpty, true);
        expect(l10n.tabSensors.isNotEmpty, true);
        expect(l10n.tabEnvironment.isNotEmpty, true);
        expect(l10n.tabAiContext.isNotEmpty, true);
        expect(l10n.tabHistory.isNotEmpty, true);

        // Context States
        expect(l10n.contextFocus.isNotEmpty, true);
        expect(l10n.contextRest.isNotEmpty, true);
        expect(l10n.contextBreak.isNotEmpty, true);
        expect(l10n.contextArriving.isNotEmpty, true);
        expect(l10n.contextLeaving.isNotEmpty, true);
        expect(l10n.contextSleep.isNotEmpty, true);
        expect(l10n.contextNeutral.isNotEmpty, true);
        expect(l10n.contextUncertain.isNotEmpty, true);

        // Context Guard States
        expect(l10n.guardAutoSafe.isNotEmpty, true);
        expect(l10n.guardAskUser.isNotEmpty, true);
        expect(l10n.guardNoAction.isNotEmpty, true);
        expect(l10n.guardAutomationPaused.isNotEmpty, true);
        expect(l10n.guardConflictingSignals.isNotEmpty, true);
        expect(l10n.guardManualOverrideActive.isNotEmpty, true);
        expect(l10n.guardCooldownActive.isNotEmpty, true);

        // Hand Gestures
        expect(l10n.gestureOpenPalm.isNotEmpty, true);
        expect(l10n.gestureClosedFist.isNotEmpty, true);
        expect(l10n.gestureThumbUp.isNotEmpty, true);
        expect(l10n.gestureThumbDown.isNotEmpty, true);
        expect(l10n.gestureVictory.isNotEmpty, true);
        expect(l10n.gesturePointingUp.isNotEmpty, true);
        expect(l10n.gestureNone.isNotEmpty, true);

        // Gesture Actions
        expect(l10n.gestureActionPause.isNotEmpty, true);
        expect(l10n.gestureActionConfirm.isNotEmpty, true);
        expect(l10n.gestureActionReject.isNotEmpty, true);
        expect(l10n.gestureActionFocus.isNotEmpty, true);
        expect(l10n.gestureActionRest.isNotEmpty, true);

        // Observable Expression Signals
        expect(l10n.signalCalm.isNotEmpty, true);
        expect(l10n.signalEngaged.isNotEmpty, true);
        expect(l10n.signalPositive.isNotEmpty, true);
        expect(l10n.signalLowActivity.isNotEmpty, true);
        expect(l10n.signalElevatedActivity.isNotEmpty, true);
        expect(l10n.signalEyesClosed.isNotEmpty, true);
        expect(l10n.signalNotDetected.isNotEmpty, true);

        // Camera UI
        expect(l10n.cameraLive.isNotEmpty, true);
        expect(l10n.cameraConnected.isNotEmpty, true);
        expect(l10n.cameraUnavailable.isNotEmpty, true);
        expect(l10n.cameraSensorOnly.isNotEmpty, true);
        expect(l10n.cameraHardwareActive.isNotEmpty, true);
        expect(l10n.cameraRetry.isNotEmpty, true);
        expect(l10n.showAiOverlay.isNotEmpty, true);
        expect(l10n.hideAiOverlay.isNotEmpty, true);

        // Smart Space & Actuators
        expect(l10n.demoEnvironment.isNotEmpty, true);
        expect(l10n.demoEnvironmentDesc.isNotEmpty, true);
        expect(l10n.workstationCompanion.isNotEmpty, true);
        expect(l10n.smartLight.isNotEmpty, true);
        expect(l10n.airConditioner.isNotEmpty, true);
        expect(l10n.fan.isNotEmpty, true);
        expect(l10n.speaker.isNotEmpty, true);
        expect(l10n.smartSocket.isNotEmpty, true);
        expect(l10n.stateOn.isNotEmpty, true);
        expect(l10n.stateOff.isNotEmpty, true);
        expect(l10n.stateConnected.isNotEmpty, true);
        expect(l10n.statePendingAck.isNotEmpty, true);
        expect(l10n.stateAcknowledged.isNotEmpty, true);
        expect(l10n.manualOverrideLease.isNotEmpty, true);
        expect(l10n.releaseOverride.isNotEmpty, true);
        expect(l10n.applyScene.isNotEmpty, true);

        // History & Telemetry
        expect(l10n.auditLog.isNotEmpty, true);
        expect(l10n.clearHistory.isNotEmpty, true);
        expect(l10n.historyEmpty.isNotEmpty, true);
        expect(l10n.resumeAutomation.isNotEmpty, true);
        expect(l10n.confidence.isNotEmpty, true);
      });
    }
  });

  group('3. Model Localization Extensions', () {
    test('AmbientContextType localization helpers', () {
      final l10nHi = AppLocalizations(const Locale('hi'));
      final l10nTa = AppLocalizations(const Locale('ta'));

      expect(AmbientContextType.focus.getLocalizedName(l10nHi), 'गहरा ध्यान');
      expect(AmbientContextType.focus.getLocalizedName(l10nTa), 'ஆழ்ந்த கவனம்');
      expect(AmbientContextType.relaxation.getLocalizedName(l10nHi), 'विश्राम मोड');
      expect(AmbientContextType.relaxation.getLocalizedName(l10nTa), 'ஓய்வு பயன்முறை');
      expect(AmbientContextType.uncertain.getLocalizedName(l10nHi), 'अनिश्चित संदर्भ');
      expect(AmbientContextType.uncertain.getLocalizedName(l10nTa), 'உறுதியற்ற சூழல்');
    });

    test('ContextGuardDecision localization helpers', () {
      final l10nTe = AppLocalizations(const Locale('te'));
      final l10nMl = AppLocalizations(const Locale('ml'));
      final l10nKn = AppLocalizations(const Locale('kn'));

      expect(ContextGuardDecision.autoSafe.getLocalizedUserBadge(l10nTe), 'సురక్షిత చర్య');
      expect(ContextGuardDecision.askUser.getLocalizedUserBadge(l10nMl), 'ഉപയോക്തൃ സ്ഥിരീകരണം ആവശ്യമാണ്');
      expect(ContextGuardDecision.noAction.getLocalizedUserBadge(l10nKn), 'ಸ್ವಯಂಚಾಲಿತ ಸ್ಥಗಿತಗೊಂಡಿದೆ');
      expect(ContextGuardDecision.noAction.getLocalizedName(l10nKn), 'ಯಾವುದೇ ಕ್ರಮವಿಲ್ಲ');
    });

    test('HandGesture localization helpers', () {
      final l10nTa = AppLocalizations(const Locale('ta'));
      final l10nHi = AppLocalizations(const Locale('hi'));

      expect(HandGesture.openPalm.getLocalizedName(l10nTa), 'திறந்த உள்ளங்கை (✋)');
      expect(HandGesture.openPalm.getLocalizedAction(l10nTa), 'தானியங்கியை நிறுத்து / தற்போதைய சூழலை பூட்டு');
      expect(HandGesture.thumbUp.getLocalizedName(l10nHi), 'अंगूठा ऊपर (👍)');
      expect(HandGesture.thumbUp.getLocalizedAction(l10nHi), 'अनुशंसित दृश्य की पुष्टि करें');
    });

    test('VisibleExpressionSignal localization helpers', () {
      final l10nKn = AppLocalizations(const Locale('kn'));
      expect(VisibleExpressionSignal.calm.getLocalizedName(l10nKn), 'ಶಾಂತ ಸಂಕೇತ');
      expect(VisibleExpressionSignal.engaged.getLocalizedName(l10nKn), 'ತೊಡಗಿಸಿಕೊಂಡ ಏಕಾಗ್ರತೆ');
    });
  });

  group('4. Persistence Layer (LocalStorageService)', () {
    test('Saves and retrieves locale seamlessly', () async {
      final storage = LocalStorageService();
      // Test saving Tamil
      await storage.saveLocale('ta');
      expect(storage.getSavedLocale(), 'ta');

      // Test saving Hindi
      await storage.saveLocale('hi');
      expect(storage.getSavedLocale(), 'hi');

      // Test saving Kannada
      await storage.saveLocale('kn');
      expect(storage.getSavedLocale(), 'kn');
    });
  });

  group('5. StatusAppBar Language Selector Widget Tests', () {
    testWidgets('Renders language button and opens bottom sheet with all 6 native languages',
        (tester) async {
      Locale currentLocale = const Locale('en');

      await tester.pumpWidget(
        MaterialApp(
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          home: const Scaffold(
            appBar: StatusAppBar(
              isHardware: true,
              hardwareAvailable: true,
              isSensorAvailable: true,
              isBleAvailable: true,
            ),
            body: Center(child: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the language switch button (Globe emoji)
      final langButton = find.text('🌐');
      expect(langButton, findsOneWidget);

      // Tap the button to open modal bottom sheet
      await tester.tap(langButton);
      await tester.pumpAndSettle();

      // Verify modal sheet opened with title and 6 language options with native names
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('తెలుగు'), findsOneWidget);
      expect(find.text('മലയാളം'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ'), findsOneWidget);

      // Tap Tamil
      final tamilOption = find.text('தமிழ்');
      await tester.tap(tamilOption);
      await tester.pumpAndSettle();

      // Modal is dismissed
      expect(find.text('Select Language'), findsNothing);
    });
  });
}
