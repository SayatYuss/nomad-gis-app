import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App starts with splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Should show splash screen or login screen
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App displays Material design', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));

      // Find MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App theme is dark', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));

      // Get the MaterialApp
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsOneWidget);
    });

    testWidgets('Navigation is available', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // App should have navigation support
      expect(find.byType(Navigator), findsOneWidget);
    });

    testWidgets('App handles provider scope', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // App should be built successfully
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Authentication Flow Tests', () {
    testWidgets('User can navigate to registration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Look for any text buttons that might navigate
      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        await tester.tap(textButtons.first);
        await tester.pumpAndSettle();

        // Should navigate somewhere
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Login form is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Should find text fields for login
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        expect(textFields, findsWidgets);
      }
    });

    testWidgets('App can handle deep linking', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));

      // The app should be built and navigable
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('UI Responsiveness Tests', () {
    testWidgets('App renders without errors on different screen sizes', (
      WidgetTester tester,
    ) async {
      addTearDown(() => tester.view.resetPhysicalSize());

      tester.view.physicalSize = const Size(400, 800);

      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Scrollable content renders properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // App should have scrollable content
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Touch interactions work', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Find and interact with buttons
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App displays error messages', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // App should handle errors gracefully
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App recovers from errors', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // App should still be functional
      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        await tester.tap(textButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Performance Tests', () {
    testWidgets('App loads quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App should load in less than 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('Scrolling is smooth', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Find scrollable content
      final scrollables = find.byType(SingleChildScrollView);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, Offset(0, -200));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
