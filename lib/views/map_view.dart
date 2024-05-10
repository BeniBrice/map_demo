import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/controllers/map_controller.dart';
import 'package:map_demo/widgets/google_map_widget.dart';
import 'package:sizer/sizer.dart';

class MapViews extends StatefulWidget {
  const MapViews({super.key});

  @override
  State<MapViews> createState() => _MapViewsState();
}

class _MapViewsState extends State<MapViews> with TickerProviderStateMixin {
  final _key = GlobalKey<FormState>();
  final mapController = Get.put(MapController());
  late final TabController _tabController;
  Position? _currentPosition;
  bool locationOpen = false;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> imageUrls = [
    'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGhvdGVsfGVufDB8fDB8fHww',
    'https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjN8fGhvdGVsfGVufDB8fDB8fHww',
    'https://images.unsplash.com/photo-1541971875076-8f970d573be6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjh8fGhvdGVsfGVufDB8fDB8fHww',
    'https://images.unsplash.com/photo-1541971875076-8f970d573be6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjh8fGhvdGVsfGVufDB8fDB8fHww',
    'https://plus.unsplash.com/premium_photo-1661964326936-831e134bef7d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjl8fGhvdGVsfGVufDB8fDB8fHww',
    'https://images.unsplash.com/photo-1521783988139-89397d761dce?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mzl8fGhvdGVsfGVufDB8fDB8fHww',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8aG90ZWx8ZW58MHx8MHx8fDA%3D'
  ];
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  //   WidgetsBinding.instance.addPostFrameCallback(
  //     (_) {
  //       showModalBottomSheet(
  //         isDismissible: false,
  //         context: context,
  //         builder: _buildBottomSheet,
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _determinePosition();
    _tabController = TabController(length: 3, vsync: this);
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

  onTapUpdate(LatLng argument) {
    mapController.stateLatitude.value = argument.latitude;
    mapController.stateLongitude.value = argument.longitude;
    mapController.showCurrentLatd.value = false;
    setState(() {});
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: _buildBottomSheet,
    );
  }

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

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

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

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      height: _tabController.index == 2
          ? Get.size.height / 2
          : Get.size.height / 1.6,
      color: Colors.white, // Adjust color as needed
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: TabBar(
              controller: _tabController,
              tabs: const [
                Text('Decouvrir'),
                Text('Direction'),
                Text('Information'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Marchant Ihela',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: Get.size.height * 0.01,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Avenue de la victoire',
                      ),
                    ),
                    SizedBox(
                      height: Get.size.height * 0.01,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: imageUrls.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(imageUrls[index]))),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: Get.size.height * 0.02,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('Decouvrez les nouveaux marchants'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 90,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(imageUrls[0]),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Marchant Twiteze Imbere',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.size.height * 0.02,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Avenue de la victoire',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),

              //second composant of tabbarview
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 105, 102, 102)),
                        ),
                        SizedBox(
                          width: Get.size.width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Votre position',
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                const Icon(
                                  Icons.more_horiz,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                Text(
                                  'Merchant Ihela',
                                ),
                              ],
                            ),
                            const Text(
                              '9min(5km)',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Get.size.height * 0.03,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 105, 102, 102)),
                        ),
                        SizedBox(
                          width: Get.size.width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Votre position',
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                const Icon(
                                  Icons.more_horiz,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                Text(
                                  'Merchant Ihela',
                                ),
                              ],
                            ),
                            const Text(
                              '39min(5km)',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Get.size.height * 0.03,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 105, 102, 102)),
                        ),
                        SizedBox(
                          width: Get.size.width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Votre position',
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                const Icon(
                                  Icons.more_horiz,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                Text(
                                  'Merchant Ihela',
                                ),
                              ],
                            ),
                            const Text(
                              '7min(5km)',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Get.size.height * 0.03,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 105, 102, 102)),
                        ),
                        SizedBox(
                          width: Get.size.width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Votre position',
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                const Icon(
                                  Icons.more_horiz,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: Get.size.width * 0.01,
                                ),
                                Text(
                                  'Merchant Ihela',
                                ),
                              ],
                            ),
                            const Text(
                              '19min(5km)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //third composant of tabbarview
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        SizedBox(
                          width: Get.size.width * 0.10,
                        ),
                        const Text(
                          'Avenue,Gisozi,Mwaro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: Get.size.height * 0.05,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.public),
                        SizedBox(
                          width: Get.size.width * 0.10,
                        ),
                        const Text(
                          'http://marchantihela.com/',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: Get.size.height * 0.05,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone),
                        SizedBox(
                          width: Get.size.width * 0.10,
                        ),
                        const Text(
                          '+257 71 200 200',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(179, 143, 139, 139),
      appBar: AppBar(
        title: const Text('Google map exemple'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Form(
            key: _key,
            child: Column(
              children: [
                SizedBox(
                  height: Get.size.height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            //put some logic here
                            if (_key.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'donnees invalide',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.search),
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: Get.size.height * 0.02,
          ),
          Expanded(
            child: Container(
              child: GoogleMap(
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
          ),
        ],
      ),
    );
  }
}
