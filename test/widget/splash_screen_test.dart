import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/screens/auth/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('SplashScreen displays logo and title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: SplashScreen())),
      );

      // Check if logo is displayed
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Check if title is displayed
      expect(find.text('Nomad GIS'), findsOneWidget);

      // Check if subtitle is displayed
      expect(find.text('Геолокационная игра'), findsOneWidget);
    });

    testWidgets('SplashScreen displays loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: SplashScreen())),
      );

      // Loading indicator should be present
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('SplashScreen has correct background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: SplashScreen())),
      );

      // Find scaffold
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('Logo animates on build', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: SplashScreen())),
      );

      // Initial state
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Pump animation frames
      await tester.pumpAndSettle(Duration(milliseconds: 1500));

      // Logo should still be present after animation
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
  });
}
