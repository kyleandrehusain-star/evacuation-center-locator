import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/maps_config.dart';
import '../data/sample_centers.dart';
import '../models/evacuation_center.dart';
import '../services/location_service.dart';
import '../widgets/center_card.dart';
import '../widgets/center_details_sheet.dart';
import '../widgets/status_badge.dart';

/// Main screen that displays the evacuation center map and search results.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.forceMapsSetupNotice = false});

  /// Shows the Maps setup notice instead of the native map. Used by tests.
  final bool forceMapsSetupNotice;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _cabadbaranCoordinates = LatLng(10.1296, 124.0667);

  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  Position? _userPosition;
  Map<String, double> _distances = const {};
  CenterStatus? _statusFilter;
  bool _isLocating = false;

  List<EvacuationCenter> get _filteredCenters {
    final String query = _searchController.text.trim().toLowerCase();

    return sampleEvacuationCenters.where((EvacuationCenter center) {
      final bool matchesQuery =
          query.isEmpty ||
          center.name.toLowerCase().contains(query) ||
          center.barangay.toLowerCase().contains(query) ||
          center.address.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == null || center.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearchResults);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearchResults)
      ..dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _refreshSearchResults() {
    setState(() {});
  }

  void _showCenterDetails(EvacuationCenter center) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => CenterDetailsSheet(
        center: center,
        distanceMeters: _distances[center.id],
      ),
    );
  }

  void _fitVisibleCenters() {
    final List<EvacuationCenter> centers = _filteredCenters;
    if (_mapController == null || centers.isEmpty) {
      return;
    }

    double minLatitude = centers.first.latitude;
    double maxLatitude = centers.first.latitude;
    double minLongitude = centers.first.longitude;
    double maxLongitude = centers.first.longitude;

    for (final EvacuationCenter center in centers) {
      minLatitude = center.latitude < minLatitude
          ? center.latitude
          : minLatitude;
      maxLatitude = center.latitude > maxLatitude
          ? center.latitude
          : maxLatitude;
      minLongitude = center.longitude < minLongitude
          ? center.longitude
          : minLongitude;
      maxLongitude = center.longitude > maxLongitude
          ? center.longitude
          : maxLongitude;
    }

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  Future<void> _findNearestCenter() async {
    if (_isLocating) {
      return;
    }

    setState(() => _isLocating = true);

    try {
      final Position? position = await _locationService.getCurrentPosition();
      if (!mounted) {
        return;
      }

      if (position == null) {
        _showMessage(
          'Location is unavailable. Enable location services and allow '
          'access in Android settings.',
        );
        return;
      }

      final Map<String, double> distances = {
        for (final EvacuationCenter center in sampleEvacuationCenters)
          center.id: Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            center.latitude,
            center.longitude,
          ),
      };

      final List<EvacuationCenter> sortedCenters =
          sampleEvacuationCenters.toList()..sort(
            (EvacuationCenter a, EvacuationCenter b) =>
                distances[a.id]!.compareTo(distances[b.id]!),
          );
      final EvacuationCenter nearest = sortedCenters.first;

      setState(() {
        _userPosition = position;
        _distances = distances;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(nearest.latitude, nearest.longitude),
          15,
        ),
      );
      _showCenterDetails(nearest);
    } on Exception {
      if (mounted) {
        _showMessage('Could not determine your current location.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Cabadbaran Evacuation Locator',
      applicationVersion: '1.0.0',
      children: const [
        Text(
          'A GIS demonstration app for evacuation centers in Cabadbaran '
          'City, Bohol. All center records and contact numbers shown are '
          'sample data.',
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers(List<EvacuationCenter> centers) {
    return centers.map((EvacuationCenter center) {
      return Marker(
        markerId: MarkerId(center.id),
        position: LatLng(center.latitude, center.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          statusMarkerHue(center.status),
        ),
        infoWindow: InfoWindow(
          title: center.name,
          snippet:
              '${center.status.label} • ${center.availableSlots} slots open',
        ),
        onTap: () => _showCenterDetails(center),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final List<EvacuationCenter> centers = _filteredCenters;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cabadbaran Evacuation Locator'),
            Text(
              'Sample GIS data • Bohol',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'About this sample app',
            onPressed: _showAboutDialog,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterBar(context),
          Expanded(child: _buildMapArea(centers)),
          _buildResultsPanel(centers),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search center or barangay',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () => _searchController.clear(),
                  icon: const Icon(Icons.close),
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _statusFilter == null,
            onSelected: (_) => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          for (final CenterStatus status in CenterStatus.values) ...[
            ChoiceChip(
              avatar: CircleAvatar(
                radius: 5,
                backgroundColor: statusColor(status),
              ),
              label: Text(status.label),
              selected: _statusFilter == status,
              onSelected: (bool selected) {
                setState(() => _statusFilter = selected ? status : null);
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildMapArea(List<EvacuationCenter> centers) {
    if (widget.forceMapsSetupNotice || !isGoogleMapsConfigured) {
      return const _MissingApiKeyNotice();
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _cabadbaranCoordinates,
            zoom: 13.5,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: _buildMarkers(centers),
          myLocationEnabled: _userPosition != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: true,
          compassEnabled: true,
        ),
        const Positioned(top: 12, left: 12, child: _MapLegend()),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: 'nearestCenterButton',
            tooltip: 'Find nearest center',
            onPressed: _findNearestCenter,
            child: _isLocating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPanel(List<EvacuationCenter> centers) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SizedBox(
        height: 248,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${centers.length} evacuation '
                      '${centers.length == 1 ? 'center' : 'centers'}',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _fitVisibleCenters,
                    icon: const Icon(Icons.fit_screen_outlined, size: 18),
                    label: const Text('Fit map'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: centers.isEmpty
                  ? const Center(child: Text('No centers match your search.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: centers.length,
                      itemBuilder: (BuildContext context, int index) {
                        final EvacuationCenter center = centers[index];
                        return CenterCard(
                          center: center,
                          distanceMeters: _distances[center.id],
                          onTap: () => _showCenterDetails(center),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final CenterStatus status in CenterStatus.values) ...[
              CircleAvatar(radius: 5, backgroundColor: statusColor(status)),
              const SizedBox(width: 4),
              Text(status.label, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissingApiKeyNotice extends StatelessWidget {
  const _MissingApiKeyNotice();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Google Maps API key required',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add GOOGLE_MAPS_API_KEY to android/local.properties, then '
                'restart the app. The sample center list still works without '
                'a key.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
