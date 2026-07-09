import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/study_place.dart';
import '../providers/place_provider.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  String category = 'Biblioteca';
  bool wifi = false;
  bool sockets = false;
  String noise = 'Silenzioso';
  String? selectedRegion;
  String? selectedProvince;
  String? selectedCity;
  Map<String, dynamic> placesData = {};

  List<String> get regions => placesData.keys.toList();

  List<String> get provinces {
    if (selectedRegion == null || placesData[selectedRegion] == null) return [];
    return (placesData[selectedRegion] as Map<String, dynamic>).keys
        .map((e) => e.toString())
        .toList();
  }

  List<String> get cities {
    if (selectedRegion == null || selectedProvince == null) return [];
    final regionData = placesData[selectedRegion] as Map<String, dynamic>?;
    final cityList = regionData?[selectedProvince];
    if (cityList is List) {
      return List<String>.from(cityList);
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    loadPlacesData();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> loadPlacesData() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/italy.places.json',
      );

      if (!mounted) return;

      setState(() {
        placesData = jsonDecode(jsonString) as Map<String, dynamic>;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Non riesco a caricare regioni, province e comuni.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi posto'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome del posto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Indirizzo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Regione',
                border: OutlineInputBorder(),
              ),
              items: regions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRegion = value;
                  selectedProvince = null;
                  selectedCity = null;
                  cityController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Provincia',
                border: OutlineInputBorder(),
              ),
              items: provinces.map((province) {
                return DropdownMenuItem(value: province, child: Text(province));
              }).toList(),
              onChanged: selectedRegion == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedCity = null;
                        cityController.clear();
                      });
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedCity,
              decoration: const InputDecoration(
                labelText: 'Comune',
                border: OutlineInputBorder(),
              ),
              items: cities.map((city) {
                return DropdownMenuItem(value: city, child: Text(city));
              }).toList(),
              onChanged: selectedProvince == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedCity = value;
                        cityController.text = value ?? '';
                      });
                    },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Biblioteca',
                  child: Text('Biblioteca'),
                ),
                DropdownMenuItem(value: 'Bar', child: Text('Bar')),
                DropdownMenuItem(
                  value: 'Università',
                  child: Text('Università'),
                ),
                DropdownMenuItem(
                  value: 'Spazio coworking',
                  child: Text('Spazio coworking'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  category = value ?? 'Biblioteca';
                });
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Wi-Fi disponibile'),
              value: wifi,
              onChanged: (value) {
                setState(() {
                  wifi = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Prese elettriche disponibili'),
              value: sockets,
              onChanged: (value) {
                setState(() {
                  sockets = value;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Livello rumore',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioGroup<String>(
              groupValue: noise,
              onChanged: (value) {
                setState(() {
                  noise = value!;
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Silenzioso'),
                    value: 'Silenzioso',
                  ),
                  RadioListTile<String>(
                    title: const Text('Normale'),
                    value: 'Normale',
                  ),
                  RadioListTile<String>(
                    title: const Text('Rumoroso'),
                    value: 'Rumoroso',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final placeName = nameController.text.trim();
                  final placeAddress = addressController.text.trim();

                  if (placeName.isEmpty ||
                      placeAddress.isEmpty ||
                      selectedRegion == null ||
                      selectedProvince == null ||
                      selectedCity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compila tutti i campi obbligatori'),
                      ),
                    );
                    return;
                  }

                  final newPlace = StudyPlace(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: placeName,
                    address: placeAddress,
                    city: selectedCity!,
                    category: category,
                    description: '',
                    rating: 0,
                    reviewsCount: 0,
                    imageUrl: '',
                    hasWifi: wifi,
                    hasPowerOutlets: sockets,
                    isQuiet: noise == 'Silenzioso',
                    isFree: true,
                    isFavorite: false,
                    tags: [],
                  );

                  Provider.of<PlaceProvider>(
                    context,
                    listen: false,
                  ).addPlace(newPlace);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Posto aggiunto con successo'),
                    ),
                  );

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Salva posto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
