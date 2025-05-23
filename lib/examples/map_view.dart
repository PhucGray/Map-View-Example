import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  CameraPosition? _cameraPosition;
  CameraPosition? _tempCameraPosition;
  bool _moving = false;
  GoogleMapController? _controller;

  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  late AnimationController _animationController2;
  late Animation<Offset> _offsetAnimation2;

  Future<bool> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // return Future.error(
      //   'Location permissions are permanently denied, we cannot request permissions.',
      // );
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();
    return true;
  }

  void setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1, curve: Curves.bounceIn),
        reverseCurve: const Interval(0.0, 1, curve: Curves.bounceIn),
      ),
    );

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _offsetAnimation2 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.5),
    ).animate(
      CurvedAnimation(
        parent: _animationController2,
        curve: const Interval(0.0, 1, curve: Curves.bounceIn),
        reverseCurve: const Interval(0.0, 1, curve: Curves.bounceIn),
      ),
    );
  }

  Future<void> init() async {
    setupAnimation();

    //

    final allowLocation = await _determinePosition();

    if (allowLocation) {
      final pos = await Geolocator.getCurrentPosition();

      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
        );

        _tempCameraPosition = _cameraPosition;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _cameraPosition?.target == null
                ? CircularProgressIndicator()
                : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _cameraPosition!.target,
                        zoom: 5,
                      ),
                      onMapCreated: (controller) {
                        _controller = controller;
                      },
                      onCameraIdle: () {
                        setState(() {
                          _moving = false;
                        });

                        _animationController.reverse();
                        _animationController2.reverse();
                      },
                      onCameraMoveStarted: () {
                        setState(() {
                          _moving = true;
                        });

                        _animationController.forward();
                        _animationController2.forward();
                      },
                      onCameraMove: (pos) {
                        _tempCameraPosition = pos;
                      },
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: SlideTransition(
                              position: _offsetAnimation,
                              child: Transform.translate(
                                offset: Offset(0, -30),
                                child: Icon(
                                  Icons.location_on,
                                  size: 60,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Center(
                          child: SlideTransition(
                            position: _offsetAnimation2,
                            child: Transform.translate(
                              offset: Offset(0, -1.5),
                              child: Container(
                                height: 3,
                                width: 3,
                                decoration: BoxDecoration(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 50,
                      left: 20,
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: AnimatedCrossFade(
                          crossFadeState:
                              _moving
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 1),
                          reverseDuration: const Duration(milliseconds: 350),
                          secondChild: const SizedBox.shrink(),
                          firstChild: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "${_tempCameraPosition?.target.latitude ?? 0}, ${_tempCameraPosition?.target.longitude ?? 0}",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class DotIcon extends StatelessWidget {
  const DotIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 1)),
          child: Transform.translate(
            offset: Offset(0, -1.5),
            child: SizedBox(height: 3, width: 3),
          ),
        ),
      ),
    );
  }
}

class LocationIcon extends StatelessWidget {
  const LocationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          decoration: BoxDecoration(),

          child: Transform.translate(
            offset: Offset(0, -30),
            child: Icon(Icons.location_on, size: 60, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
