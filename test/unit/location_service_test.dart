import 'package:flutter_test/flutter_test.dart';
import 'package:nomad_gis_app/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    test('Distance calculation between same points is zero', () {
      final distance = LocationService.calculateDistance(
        55.75,
        37.62,
        55.75,
        37.62,
      );
      expect(distance, equals(0));
    });

    test('Distance calculation between Moscow and St. Petersburg', () {
      // Moscow and St. Petersburg are approximately 600 km apart
      final distance = LocationService.calculateDistance(
        55.75, // Moscow lat
        37.62, // Moscow lon
        59.93, // St. Petersburg lat
        30.36, // St. Petersburg lon
      );

      // Distance should be approximately 600-700 km
      expect(distance, greaterThan(500000));
      expect(distance, lessThan(800000));
    });

    test('Distance calculation is symmetric', () {
      final distance1 = LocationService.calculateDistance(0.0, 0.0, 1.0, 1.0);
      final distance2 = LocationService.calculateDistance(1.0, 1.0, 0.0, 0.0);

      expect(distance1, equals(distance2));
    });

    test('Distance calculation for small differences', () {
      // Points very close together (1 degree difference = ~111 km)
      final distance = LocationService.calculateDistance(0.0, 0.0, 0.0, 0.01);

      expect(distance, isPositive);
      expect(distance, lessThan(2000)); // Less than 2 km
    });

    test('Distance calculation for maximum distance (antipodal points)', () {
      // North Pole to South Pole
      final distance = LocationService.calculateDistance(90.0, 0.0, -90.0, 0.0);

      // Distance should be approximately half Earth's circumference
      expect(distance, greaterThan(20000000)); // Greater than 20,000 km
    });

    test('User is within unlock radius', () {
      // Point at (55.75, 37.62), user at (55.751, 37.621)
      // This should be within default radius of 50m
      final distance = LocationService.calculateDistance(
        55.750,
        37.620,
        55.751,
        37.621,
      );

      expect(distance, lessThan(200)); // Less than 200 meters
    });

    test('User is outside unlock radius', () {
      // Points 1 km apart
      final distance = LocationService.calculateDistance(
        55.750,
        37.620,
        55.759,
        37.629,
      );

      expect(distance, greaterThan(1000)); // More than 1 km
    });
  });
}
