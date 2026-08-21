import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'core/theme/nexus_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  setPathUrlStrategy();
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus',
      theme: NexusTheme.light,
      darkTheme: NexusTheme.dark,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
