import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'home_map_screen.dart';
import 'pomodoro_screen.dart';
import 'profile_screen.dart';

/// Contenitore principale dell'app.
///
/// Gestisce in un unico punto la navigazione tra le quattro sezioni principali.
/// La navbar rimane visibile mentre il PageView permette sia il cambio tramite
/// tap sia lo swipe orizzontale.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final PageController _pageController;

  // Indice della sezione attualmente visibile nel PageView.
  int _selectedIndex = 0;

  static const List<String> _labels = [
    'Mappa',
    'Pomodoro',
    'Preferiti',
    'Profilo',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Il controller va sempre rilasciato quando il contenitore viene distrutto.
    _pageController.dispose();
    super.dispose();
  }

  /// Cambia pagina quando l'utente seleziona una voce della navbar.
  void _selectPage(int index) {
    if (index == _selectedIndex) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Mantiene la navbar sincronizzata quando l'utente cambia pagina con swipe.
  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopNavigationBar(
              selectedIndex: _selectedIndex,
              labels: _labels,
              onSelected: _selectPage,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  HomeMapScreen(),
                  PomodoroScreen(),
                  FavoritesScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navbar condivisa dalle quattro sezioni principali.
///
/// Lo stato selezionato deriva esclusivamente dal PageView: in questo modo
/// tap sulla navbar e swipe rimangono sempre sincronizzati.
class _TopNavigationBar extends StatelessWidget {
  const _TopNavigationBar({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Row(
          children: List.generate(labels.length, (index) {
            final selected = index == selectedIndex;

            return Padding(
              padding: EdgeInsets.only(
                right: index == labels.length - 1 ? 0 : 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2F6FED)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
