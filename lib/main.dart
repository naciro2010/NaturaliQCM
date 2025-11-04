import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/themes/app_theme.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const NaturaliQCMApp());
}

class NaturaliQCMApp extends StatelessWidget {
  const NaturaliQCMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaturaliQCM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
