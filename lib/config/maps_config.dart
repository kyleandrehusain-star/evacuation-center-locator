import 'package:flutter/foundation.dart';

/// Google Maps configuration for the evacuation center locator.
///
/// On Android, the API key is injected into `AndroidManifest.xml` by Gradle
/// from `GOOGLE_MAPS_API_KEY` in `android/local.properties`. That manifest
/// value is what the native Maps SDK consumes, so no `--dart-define` flag is
/// required. On other platforms the app shows a setup notice instead of a
/// blank map.
bool get isGoogleMapsConfigured =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
