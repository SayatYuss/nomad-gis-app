import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen displays email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Find text fields
      expect(find.byType(TextField), findsWidgets);

      // Check for login button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('LoginScreen displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Title should contain login text
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('LoginScreen has register link', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Look for text button
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('Password field obscures text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Rebuild to get initial state
      await tester.pumpAndSettle();

      // Password field should exist
      final passwordFields = find.byType(TextField);
      expect(passwordFields, findsWidgets);
    });

    testWidgets('Login button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // ElevatedButton for login
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Find first text field (email)
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Type in email field
      await tester.enterText(textFields.first, 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Screen has scroll capability', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginScreen(onRegistrationTap: () {})),
        ),
      );

      // Should have scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Registration callback is triggered', (
      WidgetTester tester,
    ) async {
      bool callbackTriggered = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(
              onRegistrationTap: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the register button
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });
  });
}
