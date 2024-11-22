

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapControllerProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});

class MapNotifier extends StateNotifier<MapState>{

  MapNotifier() : super(MapState());

  StreamSubscription? userLocation;

  setMapController(GoogleMapController controller){
    state = state.copyWith(
      controller: controller,
    );
  }

  Stream<(double, double, double)> trackUser() async*{
    await for(final position in Geolocator.getPositionStream()){
      yield(position.latitude, position.longitude, position.heading);
    }
  }

  goToLocation({
    required double latitud,
    required double longitud,
    double? bearing,
    double? tilt,
    double? zoom
  }) {
    final newPosition = CameraPosition(
      target: LatLng(latitud, longitud),
      zoom: zoom ?? 14.0,
      tilt: tilt ?? 0,
      bearing: bearing ?? 0);
    Future.delayed(const Duration(seconds: 3));
    state.controller?.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  followUser({bool? stop}){

    state = state.copyWith(loading: true);

    if(stop == true){
      state = state.copyWith(followUser: false);
    } else{
      state = state.copyWith(followUser: true);
    }

    if(state.followUser){
      userLocation = trackUser().listen((event){
        state = state.copyWith(currentPosition: LatLng(event.$1, event.$2));
        goToLocation(latitud: event.$1, longitud: event.$2, bearing: event.$3, tilt: 50, zoom: 20);
      });
    } else {
      userLocation?.cancel();
    }
  }


}

class MapState{
  final bool loading;
  final GoogleMapController? controller;
  final bool followUser;
  final LatLng? currentPosition;

  MapState({
    this.loading = false, 
    this.controller, 
    this.followUser = false,
    this.currentPosition
    });

  MapState copyWith ({
    bool? loading,
    GoogleMapController? controller,
    bool? followUser,
    LatLng? currentPosition
  }) => MapState(
    loading : loading ?? this.loading,
    controller : controller ?? this.controller,
    followUser : followUser ?? this.followUser,
    currentPosition : currentPosition ?? this.currentPosition,
  );

}