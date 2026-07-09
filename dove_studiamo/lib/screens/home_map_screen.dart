import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/study_place.dart';
import '../providers/place_provider.dart';
import 'favorites_screen.dart';
import 'add_place_screen.dart';
import 'profile_screen.dart';

// Schermata principale dell'app: mostra ricerca, categorie e lista dei luoghi.
// Fase 0: qui manteniamo la home stabile prima di aggiungere funzioni avanzate.
class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.watch<PlaceProvider>();

    return Scaffold(
      // Navbar superiore compatta con accesso rapido a Mappa, Preferiti e Profilo.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: const _TopNavigationBar(),
          ),
        ),
      ),
      // Se i luoghi sono ancora in caricamento mostriamo lo spinner,
      // altrimenti costruiamo la pagina con header, filtri e schede luogo.
      body: SafeArea(
        child: placeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(onSearch: placeProvider.searchPlaces),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryRow(
                      onCategorySelected: placeProvider.filterByCategory,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    sliver: SliverList.separated(
                      itemCount: placeProvider.places.length,
                      // Parametri espliciti per evitare warning del linter su underscore multipli.
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _PlaceCard(place: placeProvider.places[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
      // Pulsante rapido per aggiungere un nuovo luogo di studio.
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 6.0),
        child: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPlaceScreen()),
            );
          },
          tooltip: 'Aggiungi posto',
          child: const Icon(Icons.add_location_alt_rounded),
        ),
      ),
    );
  }
}

// Header della home: titolo dell'app, sottotitolo e barra di ricerca.
class _Header extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _Header({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F4FD8), Color(0xFF2F6FED), Color(0xFF20C997)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dove Studiamo?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trova biblioteche, aule studio e caffè perfetti per preparare i tuoi esami.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Cerca posto, città o tag...',
                prefixIcon: Icon(Icons.search_rounded),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Riga dei filtri principali. È Stateful perché deve ricordare la categoria selezionata.
class _CategoryRow extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;

  const _CategoryRow({required this.onCategorySelected});

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  final List<String> categories = const [
    'Tutti',
    'Biblioteche',
    'Aule studio',
    'Caffè',
    'Gratis',
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        // Parametri espliciti per evitare warning del linter su underscore multipli.
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onCategorySelected(categories[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Card singola di un luogo: mostra info principali e apre la scheda dettaglio al tap.
class _PlaceCard extends StatelessWidget {
  final StudyPlace place;

  const _PlaceCard({required this.place});

  // Apre il luogo su Google Maps usando una ricerca testuale.
  // Non usiamo una API Google Maps qui: è solo un link esterno aperto con url_launcher.
  Future<void> _openMap(BuildContext context) async {
    final query = Uri.encodeComponent('${place.address}, ${place.city}');
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    // Gestione sicura: se il link non può essere aperto, mostriamo un messaggio invece di fallire in silenzio.
    if (!await canLaunchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non riesco ad aprire Google Maps per questo luogo.'),
          ),
        );
      }
      return;
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(place.name)),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlaceImage(category: place.category),
                      const SizedBox(height: 20),
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${place.address}, ${place.city}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Text('Categoria: ${place.category}'),
                      const SizedBox(height: 8),
                      Text('Valutazione: ${place.rating} ⭐'),
                      const SizedBox(height: 8),
                      Text('Recensioni: ${place.reviewsCount}'),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        children: place.tags.map((tag) {
                          return Chip(label: Text(tag));
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      Consumer<PlaceProvider>(
                        builder: (context, provider, child) {
                          final updatedPlace = provider.places.firstWhere(
                            (p) => p.id == place.id,
                            orElse: () => place,
                          );

                          return SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                provider.toggleFavorite(place.id);
                              },
                              icon: Icon(
                                updatedPlace.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: updatedPlace.isFavorite
                                    ? Colors.red
                                    : null,
                              ),
                              label: Text(
                                updatedPlace.isFavorite
                                    ? 'Rimuovi dai preferiti'
                                    : 'Aggiungi ai preferiti',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openMap(context),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('Apri su Google Maps'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlaceImage(category: place.category),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF2F6FED),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _openMap(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Color(0xFF2F6FED),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${place.address}, ${place.city}',
                              style: const TextStyle(
                                color: Color(0xFF2F6FED),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB020),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${place.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '  (${place.reviewsCount} recensioni)',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: place.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Immagine/placeholder del luogo: per ora usa icone diverse in base alla categoria.
class _PlaceImage extends StatelessWidget {
  final String category;

  const _PlaceImage({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    if (category.toLowerCase().contains('biblioteca')) {
      icon = Icons.local_library_rounded;
    } else if (category.toLowerCase().contains('caff')) {
      icon = Icons.coffee_rounded;
    } else {
      icon = Icons.school_rounded;
    }

    return Container(
      width: 88,
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF1FF), Color(0xFFDFFBF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, size: 42, color: const Color(0xFF2F6FED)),
    );
  }
}

// Navbar superiore della home. Per ora seleziona sempre "Mappa" come tab attivo.
class _TopNavigationBar extends StatelessWidget {
  const _TopNavigationBar();

  @override
  Widget build(BuildContext context) {
    // Lista tipizzata di voci: testo + azione opzionale al tap.
    final items = <(String, VoidCallback?)>[
      ('Mappa', null),
      (
        'Preferiti',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        },
      ),
      (
        'Profilo',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == 0;
          return GestureDetector(
            onTap: items[index].$2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2F6FED)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                items[index].$1,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
