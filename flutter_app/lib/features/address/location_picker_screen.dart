import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../core/theme/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLatitude = 10.4806,
    this.initialLongitude = -66.9036,
  });

  final double initialLatitude;
  final double initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  gmaps.GoogleMapController? _googleMapController;
  final MapController _osmMapController = MapController();
  
  late ll.LatLng _selectedLocation;
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLocating = true;
  bool _useGoogleMaps = false; // Default to OpenStreetMap for guaranteed 100% visibility without API key blocks

  @override
  void initState() {
    super.initState();
    _selectedLocation = ll.LatLng(widget.initialLatitude, widget.initialLongitude);
    _addressController.text = 'Av. Principal (Lat ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng ${_selectedLocation.longitude.toStringAsFixed(4)})';
    _centerOnCurrentLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _googleMapController?.dispose();
    _osmMapController.dispose();
    super.dispose();
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newLatLng = ll.LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLatLng;
        _addressController.text = 'Ubicación GPS (${newLatLng.latitude.toStringAsFixed(4)}, ${newLatLng.longitude.toStringAsFixed(4)})';
      });

      _osmMapController.move(newLatLng, 16.0);
      _googleMapController?.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(target: gmaps.LatLng(newLatLng.latitude, newLatLng.longitude), zoom: 16.5),
        ),
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _isLocating = false);
    }
  }

  void _onLocationSelected(double lat, double lng) {
    setState(() {
      _selectedLocation = ll.LatLng(lat, lng);
      _addressController.text = 'Punto Seleccionado en Mapa (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
            tooltip: 'Centrar en GPS',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View: OpenStreetMap (Default guaranteed visible) or Google Maps
          if (_useGoogleMaps)
            gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: gmaps.LatLng(_selectedLocation.latitude, _selectedLocation.longitude),
                zoom: 16.0,
              ),
              onMapCreated: (controller) => _googleMapController = controller,
              onTap: (pos) => _onLocationSelected(pos.latitude, pos.longitude),
              markers: {
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('delivery_pin'),
                  position: gmaps.LatLng(_selectedLocation.latitude, _selectedLocation.longitude),
                  draggable: true,
                  onDragEnd: (pos) => _onLocationSelected(pos.latitude, pos.longitude),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            )
          else
            FlutterMap(
              mapController: _osmMapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 16.0,
                onTap: (tapPos, point) => _onLocationSelected(point.latitude, point.longitude),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.food_delivery_flutter',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Top Map Provider Toggle Selector
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: const Text('🗺️ OpenStreetMap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        selected: !_useGoogleMaps,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        onSelected: (selected) {
                          if (selected) setState(() => _useGoogleMaps = false);
                        },
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('📍 Google Maps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        selected: _useGoogleMaps,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        onSelected: (selected) {
                          if (selected) setState(() => _useGoogleMaps = true);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Banner
          if (_isLocating)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Detectando posición GPS...', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),

          // Bottom Confirmation Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coordenadas: Lat ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng ${_selectedLocation.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Dirección o Punto de Referencia',
                      hintText: 'Ej. Av. Principal, frente al supermercado',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'address': _addressController.text.trim(),
                          'latitude': _selectedLocation.latitude,
                          'longitude': _selectedLocation.longitude,
                        });
                      },
                      child: const Text(
                        'Confirmar Ubicación de Entrega',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
