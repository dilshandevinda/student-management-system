// ignore_for_file: unused_element, unused_field

import 'dart:async';
import 'dart:convert';
import 'package:educonnectfinal/UI/common/arview.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;

class navigationPage extends StatefulWidget {
  const navigationPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<navigationPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyA0ZiiluGa5fe-h5jooUxgzk9y5HGc3BN0";

  final Map<String, LatLng> _predefinedLocations = {
    'Old Faculty': const LatLng(8.354669251033755, 80.50369234168788),
    'Amaradewa Auditorium': const LatLng(8.362312679815329, 80.50308766419127),
    'New Faculty Auditorium': const LatLng(8.358702855769465, 80.5047400823526),
    'New Faculty Lecture Halls':
        const LatLng(8.358636765739483, 80.50439935206418),
    'Faculty of Applied Sciences':
        const LatLng(8.353306874560552, 80.50301231632997),
    'Admin Building': const LatLng(8.360863993247131, 80.50337733211785),
    'Faculty of Management Studies':
        const LatLng(8.36505804506911, 80.50249775918148),
    'Play Ground': const LatLng(8.366991469414641, 80.50948844121663),
    'Social Sciences & Humanities':
        const LatLng(8.365661570455007, 80.5067462389108),
  };

  String? _selectedStartLocation;
  String? _selectedEndLocation;

  BitmapDescriptor? adminIcon;
  BitmapDescriptor? itDeptIcon;
  BitmapDescriptor? civilDeptIcon;
  BitmapDescriptor? canteenIcon;
  BitmapDescriptor? libraryIcon;
  BitmapDescriptor? playgroundIcon;

  bool _navigationMode = false;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _selectedStartLocation = 'Current Location';
    _selectedEndLocation = 'Amaradewa Auditorium';
    _loadCustomIcons().then((_) {
      _getCurrentLocation().then((_) {
        if (_currentLocation != null) {
          _addMarkerForCurrentLocation();
        }
      });
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomIcons() async {
    adminIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );
    itDeptIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );
    civilDeptIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );
    canteenIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );
    libraryIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );
    playgroundIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(128, 128)),
      'assets/markers/icon.png',
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      loc.Location location = loc.Location();

      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;
      loc.LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _addMarkerForCurrentLocation() {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta),
        ),
      );
      setState(() {});
    }
  }

  void _addMarkers() {
    _markers.clear();
    if (_selectedStartLocation != null &&
        _selectedStartLocation != 'Current Location') {
      _addMarkerForLocation(_selectedStartLocation!);
    }
    if (_selectedEndLocation != null &&
        _selectedEndLocation != 'Current Location') {
      _addMarkerForLocation(_selectedEndLocation!);
    }
    setState(() {});
  }

  void _addMarkerForLocation(String locationKey) {
    LatLng? location = _predefinedLocations[locationKey];
    BitmapDescriptor? customIcon = _getIconForLocation(locationKey);
    if (location != null && customIcon != null) {
      _markers.add(
        Marker(
          markerId: MarkerId(locationKey),
          position: location,
          infoWindow: InfoWindow(title: locationKey),
          icon: customIcon,
        ),
      );
    }
  }

  void _getDirections() async {
    if (_selectedStartLocation == null || _selectedEndLocation == null) {
      print("Start or end location is not selected.");
      return;
    }

    LatLng start = _selectedStartLocation == 'Current Location'
        ? _currentLocation!
        : _predefinedLocations[_selectedStartLocation]!;
    LatLng end = _predefinedLocations[_selectedEndLocation]!;

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=walking&key=$googleAPIKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final overviewPolyline =
              data['routes'][0]['overview_polyline']['points'];
          final List<PointLatLng> points =
              polylinePoints.decodePolyline(overviewPolyline);

          setState(() {
            polylineCoordinates.clear();
            polylineCoordinates.addAll(
                points.map((point) => LatLng(point.latitude, point.longitude)));

            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("poly"),
                color: Colors.blue,
                width: 5,
                points: polylineCoordinates,
              ),
            );
            _navigationMode = true;
          });
          LatLngBounds bounds = _getBounds(start, end);
          await _animateCameraToBounds(bounds);
        } else {
          print("No routes found");
        }
      } else {
        print('Failed to load directions with status: ${response.statusCode}');
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      print("Error during _getDirections: $e");
    }
  }

  LatLngBounds _getBounds(LatLng start, LatLng end) {
    return LatLngBounds(
      southwest: LatLng(
        start.latitude <= end.latitude ? start.latitude : end.latitude,
        start.longitude <= end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude >= end.latitude ? start.latitude : end.latitude,
        start.longitude >= end.longitude ? start.longitude : end.longitude,
      ),
    );
  }

  Future<void> _animateCameraToBounds(LatLngBounds bounds) async {
    final GoogleMapController controller = await _controller.future;

    LatLngBounds currentBounds = await controller.getVisibleRegion();
    if (_boundsEquals(bounds, currentBounds)) return;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        50.0,
      ),
    );
  }

  bool _boundsEquals(LatLngBounds b1, LatLngBounds b2) {
    return b1.southwest.latitude == b2.southwest.latitude &&
        b1.southwest.longitude == b2.southwest.longitude &&
        b1.northeast.latitude == b2.northeast.latitude &&
        b1.northeast.longitude == b2.northeast.longitude;
  }

  void _onLocationSelected(String locationKey, LatLng location) async {
    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value != 'currentLocation');
    });

    _addMarkerForLocation(locationKey);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 18,
        ),
      ),
    );
  }

  BitmapDescriptor? _getIconForLocation(String locationKey) {
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

  void _startNavigation() {
    if (_currentLocation != null && _selectedEndLocation != null) {
      setState(() {
        _navigationMode = true;
      });

      _locationSubscription = loc.Location.instance.onLocationChanged
          .listen((loc.LocationData newLocation) {
        if (mounted) {
          setState(() {
            _currentLocation =
                LatLng(newLocation.latitude!, newLocation.longitude!);
            _markers.removeWhere(
                (marker) => marker.markerId.value == 'currentLocation');
            _addMarkerForCurrentLocation();
          });

          _controller.future.then((controller) {
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _currentLocation!,
                  zoom: 18,
                ),
              ),
            );
          });
        }
      });
    }
  }

  void _endNavigation() {
    _locationSubscription?.cancel();
    setState(() {
      _navigationMode = false;
      _selectedStartLocation = null;
      _selectedEndLocation = null;
      _markers.clear();
      _polylines.clear();
      polylineCoordinates.clear();
      _addMarkerForCurrentLocation();
    });

    _controller.future.then((controller) {
      if (_currentLocation != null) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    });
  }

  void _navigateToARMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArView(
          startLocation: _selectedStartLocation ??
              'Current Location', // Provide default values
          endLocation: _selectedEndLocation ?? 'Amaradewa Auditorium',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 65, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'From',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedStartLocation,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStartLocation = newValue;
                    });
                    if (newValue != 'Current Location') {
                      _onLocationSelected(
                          newValue!, _predefinedLocations[newValue]!);
                    }
                  },
                  items: ['Current Location', ..._predefinedLocations.keys]
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'To',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedEndLocation,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedEndLocation = newValue;
                    });
                    if (newValue != 'Current Location') {
                      _onLocationSelected(
                          newValue!, _predefinedLocations[newValue]!);
                    }
                  },
                  items: _predefinedLocations.keys
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _getDirections,
                  child: Text('Generate Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _currentLocation == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation!,
                        zoom: 18,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navigateToARMode, // Call the navigation function
              child: Text('AR Mode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
