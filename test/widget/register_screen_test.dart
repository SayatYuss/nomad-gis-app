import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/screens/auth/register_screen.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('RegisterScreen displays all form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      // Should have multiple text fields for email, username, password, etc.
      expect(find.byType(TextField), findsWidgets);

      // Check for register button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('RegisterScreen displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('RegisterScreen has login link', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      // Look for text button to go back to login
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Type in first field (email)
      await tester.enterText(textFields.first, 'newuser@example.com');
      expect(find.text('newuser@example.com'), findsOneWidget);
    });

    testWidgets('Password fields are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      // At least password and confirm password fields
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
    });

    testWidgets('Register button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Screen has scroll capability', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: RegisterScreen(onLoginTap: () {})),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Login callback is triggered', (WidgetTester tester) async {
      bool callbackTriggered = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(
              onLoginTap: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the login button
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(callbackTriggered, isTrue);
    });
  });
}
