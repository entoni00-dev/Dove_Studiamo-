import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/place_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<PlaceProvider>().favoritePlaces;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferiti'),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessun posto salvato',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aggiungi i luoghi che vuoi ritrovare velocemente',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final place = favorites[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(place.name),
                    subtitle: Text('${place.address}, ${place.city}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        context
                            .read<PlaceProvider>()
                            .toggleFavorite(place.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
