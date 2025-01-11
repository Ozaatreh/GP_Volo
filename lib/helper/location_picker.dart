// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  LocationPickerPageState createState() => LocationPickerPageState();
}

class LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedLocation;
  LatLng? currentLocation;
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services'.tr())),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied'.tr())),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied'.tr())),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Event Location'.tr()),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          // TextField to display the selected location
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: locationController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected Location'.tr(),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(31.9686, 35.9342), // Default location is Amman
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (currentLocation != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: currentLocation!,
                            color: Colors.blue.withOpacity(0.5),
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.blue,
                            radius: 50, // Radius in meters
                          ),
                        ],
                      ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: selectedLocation!,
                            child: Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
                if (selectedLocation != null)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      onPressed: _assignLocation,
                      child: Icon(Icons.check , color: Theme.of(context).colorScheme.inversePrimary,),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

void _assignLocation() {
  if (selectedLocation != null) {
    setState(() {
      locationController.text = '${selectedLocation!.latitude}, ${selectedLocation!.longitude}';
    });
     Navigator.pop(context , selectedLocation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location assigned to the event'.tr())),
    );
    
    // Navigate to NgoPage with the selected location
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => NgoPage(eventLocation: selectedLocation),
    //   ),
    // );
  }
}


}
