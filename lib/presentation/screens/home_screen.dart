

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
                  target: LatLng(widget.latitud, widget.longitud),
                  zoom: 14.0),
                  myLocationEnabled: true,
                  markers: { 
                    // ...ref.watch(tripProvider).markers
                    if (ref.watch(tripProvider).origin != null)
                      Marker(
                        markerId: const MarkerId('origin'),
                        position: ref.watch(tripProvider).origin!,
                        onTap: () => ref.read(tripProvider.notifier).setOrigin(null),
                      ),
                    if (ref.watch(tripProvider).destination != null)
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: ref.watch(tripProvider).destination!,
                        onTap: () => ref.read(tripProvider.notifier).setDestination(null),
                      ),
                                       

                    // tripProv.origin != null 
                    // ref.watch(tripProvider).origin != null
                    //   ? Marker(markerId: const MarkerId('origin'),
                    //       position: tripProv.origin!,
                    //       // onTap: () => ref.watch(tripProvider.notifier).setOrigin(null),
                    //       // consumeTapEvents: true
                    //       )
                    //   : Marker(markerId: MarkerId('origin')),

                    // ref.watch(tripProvider).destination != null 
                    //   ? Marker(markerId: const MarkerId('destination'),
                    //       position: tripProv.destination!,
                    //       // onTap: () => ref.read(tripProvider.notifier).setDestination(null),
                    //       // consumeTapEvents: true
                    //       )
                    //   : Marker(markerId: MarkerId('destination')),
                      
                    // tripProv.destination == null 
                    //   ? Marker(markerId: MarkerId('destination'))
                    //   : Marker(markerId: const MarkerId('destination'),
                    //       position: tripProv.destination!,
                    //       // onTap: () => ref.read(tripProvider.notifier).setDestination(null),
                    //       // consumeTapEvents: true
                    //       ),
                      
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
                        text: tripProv.origin != null ? '${tripProv.origin!.latitude},${tripProv.origin!.longitude}' : '',
                        locationOnPressed: () async{
                          Position position = await ref.watch(tripProvider.notifier).getLocation();
                          ref.watch(tripProvider.notifier).setOrigin(LatLng(position.latitude, position.longitude));
                          setState(() {});
                        },
                        deleteOnPressed: (){
                          ref.watch(tripProvider.notifier).setOrigin(null);
                          setState(() {});
                        },),
                      const SizedBox(height: 4,),
                      CustomTextField(
                        hintText: 'Destination',
                        text: tripProv.destination != null ? '${tripProv.destination!.latitude},${tripProv.destination!.longitude}' : '',
                        locationOnPressed: () async{
                          Position position = await ref.watch(tripProvider.notifier).getLocation();
                          ref.watch(tripProvider.notifier).setDestination(LatLng(position.latitude, position.longitude));
                          // setState(() {});
                        },
                        deleteOnPressed: (){
                          print('delete PRESIONADO');
                          // print('valor ahora mismo: ${ref.watch(tripProvider).destination}');
                          ref.watch(tripProvider.notifier).setDestination(null);
                          // print('valor actualizado: ${ref.watch(tripProvider).destination}');
                          // setState(() {});
                        },),
                      
                    ],
                  ),
                ),)),
          ]
        ),
      ),
    );
  }
}