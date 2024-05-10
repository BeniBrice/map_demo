import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/controllers/map_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final mapController = Get.put(MapController());
  Position? _currentPosition;
  bool locationOpen = false;

  @override
  void initState() {
    super.initState();
    mapController.showCurrentLatd.value = true;
    _getCurrentPosition();
    _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    locationOpen = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        mapController.latitude.value = _currentPosition?.latitude;
        mapController.longitude.value = _currentPosition?.longitude;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  bool hybridView = false;
  bool showDialoge = false;

  void changeView() {
    setState(() {
      if (hybridView) {
        hybridView = false;
      } else {
        hybridView = true;
      }
    });
  }

  // void showDialogText() {
  //   if (showDialoge) {
  //     showDialoge = true;
  //   }
  // }

  onTapUpdate(LatLng argument) {
    mapController.stateLatitude.value = argument.latitude;
    mapController.stateLongitude.value = argument.longitude;
    mapController.showCurrentLatd.value = false;
    setState(() {});
  }

  LatLng latLng() {
    return LatLng(
      mapController.showCurrentLatd.value
          ? mapController.latitude.value!
          : mapController.stateLatitude.value!,
      mapController.showCurrentLatd.value
          ? mapController.longitude.value!
          : mapController.stateLongitude.value!,
    );
  }

  CameraPosition cameraPosition() {
    return CameraPosition(
      target: latLng(),
      zoom: 14.4746,
    );
  }

  // Future<void> changeLocation() async {
  //   final GoogleMapController controller = await _controller.future;
  //   await controller
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition()));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: Get.width,
            child: mapController.latitude.value == null &&
                    mapController.longitude.value == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GoogleMap(
                    compassEnabled: true,
                    initialCameraPosition: cameraPosition(),
                    mapType: hybridView ? MapType.hybrid : MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,

                    onMapCreated: (controller) {
                      _controller.complete(controller);
                    },
                    onTap: ((argument) => onTapUpdate(argument)),

                    // adding marker
                    markers: {
                      Marker(
                        markerId: const MarkerId('marchantLoc'),
                        draggable: true,
                        onDrag: (value) {},
                        position: latLng(),
                        infoWindow: const InfoWindow(
                          title: 'Marchant Location',
                          snippet: "Marchant zone",
                        ),
                      ),
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => changeView(),
        child: Icon(
          Icons.remove_red_eye,
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        mini: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
    );
  }
}
