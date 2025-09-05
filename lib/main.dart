// lib/main.dart
import 'package:flutter/material.dart';

import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardLinkProApp());
}

class CardLinkProApp extends StatelessWidget {
  const CardLinkProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardLink Pro',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ProfileScreen(),
    );
  }
}
