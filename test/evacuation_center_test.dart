import 'package:evacuation_center_locator/data/sample_centers.dart';
import 'package:evacuation_center_locator/models/evacuation_center.dart';
import 'package:evacuation_center_locator/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EvacuationCenter', () {
    test('calculates available slots and occupancy', () {
      const EvacuationCenter center = EvacuationCenter(
        id: 'test',
        name: 'Test Center',
        barangay: 'Poblacion',
        address: 'Test Address',
        latitude: 10.1,
        longitude: 124.1,
        capacity: 200,
        occupied: 50,
        status: CenterStatus.open,
        contactNumber: '+63 900 000 0000',
        notes: 'Test',
      );

      expect(center.availableSlots, 150);
      expect(center.occupancyRate, 0.25);
    });

    test('never reports negative available slots', () {
      const EvacuationCenter center = EvacuationCenter(
        id: 'test',
        name: 'Test Center',
        barangay: 'Poblacion',
        address: 'Test Address',
        latitude: 10.1,
        longitude: 124.1,
        capacity: 100,
        occupied: 120,
        status: CenterStatus.full,
        contactNumber: '+63 900 000 0000',
        notes: 'Test',
      );

      expect(center.availableSlots, 0);
    });
  });

  group('formatDistance', () {
    test('formats meters and kilometers', () {
      expect(formatDistance(640), '640 m');
      expect(formatDistance(1540), '1.5 km');
    });
  });

  test('sample data contains unique identifiers', () {
    final Set<String> ids = sampleEvacuationCenters
        .map((EvacuationCenter c) => c.id)
        .toSet();

    expect(ids.length, sampleEvacuationCenters.length);
    expect(sampleEvacuationCenters, isNotEmpty);
  });
}
