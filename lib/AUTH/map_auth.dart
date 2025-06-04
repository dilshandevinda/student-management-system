// ignore_for_file: unused_import, unnecessary_import, unused_shown_name, deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart'
    show Size, rootBundle; // Import rootBundle

class MapAuth {
  final String googleAPIKey =
      "AIzaSyA0ZiiluGa5fe-h5jooUxgzk9y5HGc3BN0"; // Replace with your API Key

  // Predefined locations
  final Map<String, LatLng> predefinedLocations = {
    'Admin Block': const LatLng(8.361121113846295, 80.50345850782819),
    'IT Department': const LatLng(9.972724, 80.031392),
    'Civil Department': const LatLng(9.973014, 80.032287),
    'Canteen': const LatLng(9.971232, 80.031349),
    'Library': const LatLng(9.971893, 80.031817),
    'Play Ground': const LatLng(8.367688520691209, 80.51055137513652),
  };

  // Custom marker icons
  BitmapDescriptor? adminIcon;
  BitmapDescriptor? itDeptIcon;
  BitmapDescriptor? civilDeptIcon;
  BitmapDescriptor? canteenIcon;
  BitmapDescriptor? libraryIcon;
  BitmapDescriptor? playgroundIcon;

  final _locationController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;

  // Initialize and load assets
  Future<void> initialize() async {
    await loadCustomIcons();
    await _getCurrentLocation();
    // You might want to call _addMarkerForCurrentLocation() here if you want to show it initially
  }

  // Load custom marker icons
  Future<void> loadCustomIcons() async {
    adminIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png'); // Replace with your asset paths
    itDeptIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png');
    civilDeptIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png');
    canteenIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png');
    libraryIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png');
    playgroundIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(128, 128)),
        'assets/markers/icon.png');
  }

  // Get current location
  Future<LatLng?> _getCurrentLocation() async {
    try {
      loc.Location location = loc.Location();
      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;
      loc.LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          return null;
        }
      }

      locationData = await location.getLocation();
      final currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      _locationController.add(currentLocation);
      return currentLocation;
    } catch (e) {
      print("Error getting current location: $e");
      return null;
    }
  }

  // Get the icon for a location
  BitmapDescriptor? getIconForLocation(String locationKey) {
    switch (locationKey) {
      case 'Admin Block':
        return adminIcon;
      case 'IT Department':
        return itDeptIcon;
      case 'Civil Department':
        return civilDeptIcon;
      case 'Canteen':
        return canteenIcon;
      case 'Library':
        return libraryIcon;
      case 'Play Ground':
        return playgroundIcon;
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  // Fetch directions
  Future<Map<String, dynamic>> getDirections(LatLng start, LatLng end) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=walking&key=$googleAPIKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        return data;
      } else {
        print("No routes found");
        return {};
      }
    } else {
      print('Failed to load directions with status: ${response.statusCode}');
      throw Exception('Failed to load directions');
    }
  }

  void dispose() {
    _locationController.close();
  }
}
