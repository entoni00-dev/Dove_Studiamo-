import 'package:flutter/material.dart';

/// Placeholder temporaneo della sezione Pomodoro.
///
/// Mantiene compilabile la navigazione principale mentre il timer vero e
/// proprio verrà implementato nella fase successiva del progetto.
class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pomodoro',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}
