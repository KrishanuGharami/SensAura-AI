import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_scaffold.dart';
import 'services/local_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E131B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SensAuraApp());
}

class SensAuraApp extends StatefulWidget {
  const SensAuraApp({super.key});

  /// Allows any widget in the app tree to change the locale instantly without app restart.
  static void setLocale(BuildContext context, Locale newLocale) {
    final _SensAuraAppState? state =
        context.findAncestorStateOfType<_SensAuraAppState>();
    state?.setLocale(newLocale);
  }

  /// Get currently active locale from context
  static Locale getLocale(BuildContext context) {
    final _SensAuraAppState? state =
        context.findAncestorStateOfType<_SensAuraAppState>();
    return state?._locale ?? const Locale('en');
  }

  @override
  State<SensAuraApp> createState() => _SensAuraAppState();
}

class _SensAuraAppState extends State<SensAuraApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedCode = LocalStorageService().getSavedLocale();
    if (savedCode != null &&
        AppLocalizations.supportedLocaleCodes.contains(savedCode)) {
      setState(() {
        _locale = Locale(savedCode);
      });
    }
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      setState(() {
        _locale = newLocale;
      });
      LocalStorageService().saveLocale(newLocale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensAura AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainScaffold(),
    );
  }
}
