import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_scaffold.dart';

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

class SensAuraApp extends StatelessWidget {
  const SensAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensAura AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}
