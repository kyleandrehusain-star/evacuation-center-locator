/// Availability status of an evacuation center.
enum CenterStatus { open, limited, full }

/// Human readable label for a center status.
extension CenterStatusLabel on CenterStatus {
  String get label => switch (this) {
    CenterStatus.open => 'Open',
    CenterStatus.limited => 'Limited',
    CenterStatus.full => 'Full',
  };
}

/// A single evacuation center shown on the map and in the results list.
class EvacuationCenter {
  const EvacuationCenter({
    required this.id,
    required this.name,
    required this.barangay,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.occupied,
    required this.status,
    required this.contactNumber,
    required this.notes,
  });

  final String id;
  final String name;
  final String barangay;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;
  final int occupied;
  final CenterStatus status;
  final String contactNumber;
  final String notes;

  /// Remaining slots available at the center.
  int get availableSlots => (capacity - occupied).clamp(0, capacity);

  /// Portion of the total capacity that is currently occupied, from 0 to 1.
  double get occupancyRate => capacity == 0 ? 0 : occupied / capacity;
}
