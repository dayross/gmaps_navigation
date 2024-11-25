// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmaps_cloneish/presentation/providers/map_controller_provider.dart';
import 'package:gmaps_cloneish/presentation/providers/trip_provider.dart';
import 'package:gmaps_cloneish/presentation/providers/watch_location_provider.dart';
import 'package:gmaps_cloneish/presentation/shared/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LocationRecieverScreen extends ConsumerWidget {
  const LocationRecieverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchUserLocation = ref.watch(watchLocationProvider);

    return PopScope(
      child: Scaffold(
        body: watchUserLocation.when(
          data: (data) => HomeScreen(latitud: data.$1, longitud: data.$2,), 
          error: (error, stackTrace) => const HomeScreen(), 
          loading: () => const Center(child: CircularProgressIndicator(),)),
      ),
      onPopInvoked: (didPop)  {
        ref.read(mapControllerProvider.notifier).followUser(stop: true);
      },);
  }
}




class HomeScreen extends ConsumerStatefulWidget {
  final double latitud;
  final double longitud;

  const HomeScreen({
    this.latitud = 0.0, 
    this.longitud = 0.0, 
    super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  late GoogleMapController mapController;

  final _center = const LatLng(40.6735566313035, -73.952959115342087);

  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tripProv = ref.watch(tripProvider);
    


    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child:  Container(
                width: size.width,
                height: size.height*0.8,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14.0),
                  markers: {
                    ref.watch(tripProvider).origin != null 
                      ? Marker(markerId: MarkerId('origin'),
                          position: tripProv.origin!,
                          onTap: () => ref.watch(tripProvider.notifier).deleteMarker('origin'),
                          consumeTapEvents: true
                          )
                      : Marker(markerId: MarkerId('origin')),

                    ref.watch(tripProvider).destination != null 
                      ? Marker(markerId: MarkerId('destination'),
                          position: tripProv.destination!,
                          onTap: () => ref.read(tripProvider.notifier).deleteMarker('destination'),
                          consumeTapEvents: true
                          )
                      : Marker(markerId: MarkerId('destination')),
                  },
                  onLongPress: (position){
                    ref.watch(tripProvider.notifier).addMarker(position);

                  },
                ),
              ),
            ),
            // area to enter the origin and destination
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: size.width,
                height: size.height*0.24,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 252, 252, 252),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomTextField(
                        hintText: 'Origin', 
                        controller: TextEditingController(
                          text: tripProv.origin != null ? '${tripProv.origin!.latitude},${tripProv.origin!.longitude}' : ''
                        ),
                        onPressed: () {
                          ref.watch(tripProvider.notifier).getLocation();
                        },),
                      SizedBox(height: 4,),
                      CustomTextField(
                        hintText: 'Destination',
                        controller: TextEditingController(
                          text: tripProv.destination != null ? '${tripProv.destination!.latitude},${tripProv.destination!.longitude}' : ''
                        )),
                      
                    ],
                  ),
                ),)),
          ]
        ),
      ),
    );
  }
}