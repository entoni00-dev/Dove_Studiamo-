import 'package:flutter/material.dart';

import '../screens/main_navigation_screen.dart';

class DoveStudianoApp extends StatelessWidget {
  const DoveStudianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dove Studiano?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6FED),
          primary: const Color(0xFF2F6FED),
          secondary: const Color(0xFF20C997),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),

      // MainNavigationScreen è ora il contenitore principale dell'app.
      // Gestisce le quattro sezioni, la navbar persistente e lo swipe.
      home: const MainNavigationScreen(),
    );
  }
}
