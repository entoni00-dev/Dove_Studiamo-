import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/place_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlaceProvider()..loadPlaces(),
        ),
      ],
      child: const DoveStudianoApp(),
    ),
  );
}