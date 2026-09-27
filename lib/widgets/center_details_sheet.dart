import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/evacuation_center.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

/// Displays full details and actions for one evacuation center.
class CenterDetailsSheet extends StatelessWidget {
  const CenterDetailsSheet({
    super.key,
    required this.center,
    this.distanceMeters,
  });

  final EvacuationCenter center;
  final double? distanceMeters;

  Future<void> _openDirections(BuildContext context) async {
    final Uri navigationUri = Uri.parse(
      'google.navigation:q=${center.latitude},${center.longitude}',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${center.latitude},${center.longitude}',
    );

    try {
      if (await canLaunchUrl(navigationUri)) {
        await launchUrl(navigationUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  Future<void> _callCenter(BuildContext context) async {
    final String phoneNumber = center.contactNumber.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    try {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This device cannot place calls.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(center.status);
    final double occupancyPercent = center.occupancyRate * 100;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    center.name,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(status: center.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('${center.barangay} • ${center.address}'),
            if (distanceMeters != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.near_me_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('${formatDistance(distanceMeters!)} from you'),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Capacity',
                    value: '${center.capacity}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Occupied',
                    value: '${center.occupied}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Available',
                    value: '${center.availableSlots}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: center.occupancyRate,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.15),
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text('${occupancyPercent.toStringAsFixed(0)}% occupied'),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.info_outline,
              label: 'Facilities / notes',
              value: center.notes,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: center.contactNumber,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openDirections(context),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callCenter(context),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Demonstration record. Verify details with the local '
              'government before traveling.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
