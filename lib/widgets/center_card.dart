import 'package:flutter/material.dart';

import '../models/evacuation_center.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

/// A compact list card for one evacuation center.
class CenterCard extends StatelessWidget {
  const CenterCard({
    super.key,
    required this.center,
    required this.onTap,
    this.distanceMeters,
  });

  final EvacuationCenter center;
  final VoidCallback onTap;
  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final Color color = statusColor(center.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_outlined, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${center.barangay} • ${center.availableSlots} slots open',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: center.occupancyRate,
                        minHeight: 5,
                        backgroundColor: color.withValues(alpha: 0.15),
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: center.status),
                  if (distanceMeters != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          formatDistance(distanceMeters!),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
