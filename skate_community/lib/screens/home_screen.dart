// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skate_community/screens/settings/settings_sreen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:skate_community/screens/park/skatepark_detail_screen.dart';
import 'package:skate_community/services/skatepark_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/settings_service.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(51.053581, 3.722969), // Gent
    zoom: 11,
  );

  final Set<Marker> _markers = {};
  bool _locationPermissionGranted = false;
  bool _locationSharing = true; // Haal deze waarde op uit user_settings

  final SupabaseClient _client = Supabase.instance.client;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadUserSettings();
    _fetchSkateparks();
  }

  /// Controleert of locatie permissies zijn verleend
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationPermissionGranted = false);
        _showPermissionDeniedDialog();
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationPermissionGranted = false);
      _showPermissionDeniedDialog();
      return;
    }
    setState(() => _locationPermissionGranted = true);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Locatiepermissie vereist'),
        content: Text('Deze app heeft locatiepermissies nodig om correct te functioneren.'),
        actions: [
          TextButton(
            child: Text('Annuleren'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Instellingen'),
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Laadt gebruikersinstellingen (bijv. locatietoegang) uit de database
  Future<void> _loadUserSettings() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final settings = await _settingsService.loadUserSettings(userId);
      setState(() {
        _locationSharing = settings['location_sharing'] as bool? ?? true;
      });
    } catch (e) {
      // Als er een fout optreedt, gebruik dan een standaardwaarde
      setState(() {
        _locationSharing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij laden instellingen: $e')),
      );
    }
  }

  /// Haalt skateparken op en genereert markers
  Future<void> _fetchSkateparks() async {
    try {
      final SkateparkService skateparkService = SkateparkService();
      final List<dynamic> skateparks = await skateparkService.fetchSkateparks();

      // Laad het aangepaste marker-icoon
      final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'assets/images/marker.png',
      );

      final List<Marker> markers = skateparks
          .where((park) => park['latitude'] != null && park['longitude'] != null)
          .map<Marker>((park) {
        return Marker(
          markerId: MarkerId(park['id']),
          position: LatLng(park['latitude'], park['longitude']),
          infoWindow: InfoWindow(
            title: park['name'],
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SkateparkDetailScreen(skateparkId: park['id']),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          icon: customIcon,
        );
      }).toList();

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    } catch (error) {
      print('Error loading skatepark markers: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Skate Flow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ],
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: _locationPermissionGranted
          ? GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              // Gebruik de instelling van de gebruiker om te bepalen of de huidige locatie getoond wordt
              myLocationEnabled: _locationSharing,
              myLocationButtonEnabled: _locationSharing,
              zoomControlsEnabled: false,
              compassEnabled: true,
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Locatiepermissie is niet verleend.\nGa naar instellingen om permissies te beheren.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: FooterWidget(currentIndex: 0),
    );
  }
}
