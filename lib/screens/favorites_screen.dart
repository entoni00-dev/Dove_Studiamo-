import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/place_provider.dart';

/// Contenuto della sezione Preferiti.
///
/// La navigazione principale e la navbar persistente sono gestite da
/// MainNavigationScreen, quindi qui non usiamo Scaffold o AppBar dedicati.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<PlaceProvider>().favoritePlaces;

    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 70,
                color: Color(0xFF2F6FED),
              ),
              SizedBox(height: 16),
              Text(
                'Nessun posto salvato',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aggiungi i luoghi che vuoi ritrovare velocemente',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), height: 1.35),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final place = favorites[index];

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF2F6FED),
              ),
            ),
            title: Text(
              place.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${place.address}, ${place.city}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            trailing: IconButton(
              tooltip: 'Rimuovi dai preferiti',
              icon: const Icon(Icons.favorite_rounded, color: Colors.red),
              onPressed: () {
                context.read<PlaceProvider>().toggleFavorite(place.id);
              },
            ),
          ),
        );
      },
    );
  }
}
