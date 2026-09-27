import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const EvacuationLocatorApp());
}

/// Root application widget for the Cabadbaran evacuation center locator.
class EvacuationLocatorApp extends StatelessWidget {
  const EvacuationLocatorApp({super.key, this.forceMapsSetupNotice = false});

  /// Forces the Maps setup notice so widget tests never instantiate the
  /// native Google Maps platform view.
  final bool forceMapsSetupNotice;

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Color(0xFF0B6E4F);

    return MaterialApp(
      title: 'Cabadbaran Evacuation Locator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: HomeScreen(forceMapsSetupNotice: forceMapsSetupNotice),
    );
  }
}
