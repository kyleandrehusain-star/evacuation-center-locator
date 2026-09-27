import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/evacuation_center.dart';

/// Returns the UI color used for a center status.
Color statusColor(CenterStatus status) => switch (status) {
  CenterStatus.open => const Color(0xFF1B8A5A),
  CenterStatus.limited => const Color(0xFFE08A00),
  CenterStatus.full => const Color(0xFFC53B3B),
};

/// Returns the Google Maps marker hue used for a center status.
double statusMarkerHue(CenterStatus status) => switch (status) {
  CenterStatus.open => BitmapDescriptor.hueGreen,
  CenterStatus.limited => BitmapDescriptor.hueOrange,
  CenterStatus.full => BitmapDescriptor.hueRed,
};

/// A compact colored label that shows the availability of a center.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final CenterStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
