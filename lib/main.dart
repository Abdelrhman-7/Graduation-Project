import 'package:flutter/material.dart';
import 'core/resources/theme_manager.dart';
import 'presentation/auth_choice/view/auth_choice_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Graduation Project',
      theme: ThemeManager.getApplicationTheme(),
      home: const AuthChoiceView(),
    );
  }
}
