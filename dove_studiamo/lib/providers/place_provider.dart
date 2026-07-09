import 'package:flutter/material.dart';

import '../models/study_place.dart';
import '../services/place_service.dart';
import '../services/google_places_service.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  List<StudyPlace> _places = [];
  List<StudyPlace> _filteredPlaces = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<StudyPlace> get places => _filteredPlaces;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<StudyPlace> get favoritePlaces =>
      _places.where((place) => place.isFavorite).toList();

  Future<void> loadPlaces() async {
    _isLoading = true;
    notifyListeners();

    _places = await _placeService.fetchPlaces();

    for (int i = 0; i < _places.length; i++) {
      final place = _places[i];

      if (place.googlePlaceId != null) {
        final details = await _googlePlacesService.getPlaceDetails(
          place.googlePlaceId!,
        );

        if (details != null) {
          _places[i] = place.copyWith(
            rating: (details['rating'] ?? 0).toDouble(),
            reviewsCount: details['user_ratings_total'] ?? 0,
          );
        }
      }
    }

    _filteredPlaces = _places;

    _isLoading = false;
    notifyListeners();
  }

  void searchPlaces(String query) {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _filteredPlaces = _places;
    } else {
      final lowerQuery = query.toLowerCase();

      _filteredPlaces = _places.where((place) {
        return place.name.toLowerCase().contains(lowerQuery) ||
            place.city.toLowerCase().contains(lowerQuery) ||
            place.category.toLowerCase().contains(lowerQuery) ||
            place.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    notifyListeners();
  }

  void filterByCategory(String category) {
    if (category == 'Tutti') {
      _filteredPlaces = _places;
    } else if (category == 'Gratis') {
      _filteredPlaces = _places.where((place) => place.isFree).toList();
    } else if (category == 'Biblioteche') {
      _filteredPlaces = _places.where((place) {
        return place.category.toLowerCase().contains('biblioteca');
      }).toList();
    } else if (category == 'Aule studio') {
      _filteredPlaces = _places.where((place) {
        return place.category.toLowerCase().contains('aula');
      }).toList();
    } else if (category == 'Caffè') {
      _filteredPlaces = _places.where((place) {
        return place.category.toLowerCase().contains('caff');
      }).toList();
    } else {
      _filteredPlaces = _places.where((place) {
        return place.category.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    notifyListeners();
  }

  void addPlace(StudyPlace place) {
    _places.add(place);
    _filteredPlaces = _places;
    notifyListeners();
  }

  void toggleFavorite(String placeId) {
    final index = _places.indexWhere((place) => place.id == placeId);

    if (index == -1) return;

    final place = _places[index];

    _places[index] = place.copyWith(isFavorite: !place.isFavorite);

    _filteredPlaces = _places;
    notifyListeners();
  }
}
