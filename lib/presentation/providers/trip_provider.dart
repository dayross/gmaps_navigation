

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmaps_cloneish/config/constants/environment.dart';
import 'package:gmaps_cloneish/presentation/providers/map_controller_provider.dart';
import 'package:google_maps_directions/google_maps_directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final tripProvider = StateNotifierProvider.autoDispose<TripNotifier, TripState>((ref){
  final mapProvider = ref.watch(mapControllerProvider.notifier);
  
  return TripNotifier(mapNotifier: mapProvider);
});

class TripNotifier extends StateNotifier<TripState>{
  TripNotifier({
    required this.mapNotifier
  }) : super( TripState());

  final MapNotifier mapNotifier;

  void setOrigin(LatLng? value) async{
    // new list with the content of the current markers
    List<Marker> temporaryList = state.markers;

    // we make new marker based on if the value is null or not
    Marker newMarker;
    value == null
    ? newMarker = Marker(markerId: MarkerId('origin'))
    : newMarker = Marker(markerId: const MarkerId('origin'), position: value);


    if (temporaryList.isNotEmpty) deleteMarkersByType('origin', temporaryList);

    temporaryList.insert(0, newMarker);

    state = state.copyWith(
      markers: [...temporaryList],
      origin: value ?? LatLng(0,0)
    );
  }

  void setDestination(LatLng? value) async{

    // new list with the content of the current markers
    List<Marker> temporaryList = state.markers;

    // we make new marker based on if the value is null or not
    Marker newMarker;
    value == null
    ? newMarker = Marker(markerId: MarkerId('destination'))
    : newMarker = Marker(markerId: const MarkerId('destination'), position: value);


    if (temporaryList.isNotEmpty) deleteMarkersByType('destination', temporaryList);

    temporaryList.add(newMarker);

    state = state.copyWith(
      markers: [...temporaryList],
      destination: value ?? LatLng(0,0)
    );
  }

  List<Marker> deleteMarkersByType(String type, List<Marker> list){
    list.removeWhere((e)=> e.markerId.value == type);
    return list;
  }

  double getDistance({required LatLng origin, required LatLng destination,}){
      return Geolocator.distanceBetween(
        origin.latitude, 
        origin.longitude,
        destination.latitude, 
        destination.longitude,
        );
    }

   getDirection(LatLng from, LatLng to) async{
    GoogleMapsDirections.init(googleAPIKey: Environment.apiKey);
    state = state.copyWith(
      origin: from,
      destination: to
    );
    try{
      Directions directions = await getDirections(
        state.origin!.latitude, 
        state.origin!.longitude, 
        state.destination!.latitude,
        state.destination!.longitude, 
        language: 'es-mx'
        );
      directions.shortestRoute.shortestLeg.steps;
      state = state.copyWith(
        polylines: getPolylines(directions.shortestRoute),
        instructions: directions.shortestRoute.shortestLeg.steps
      );

    } catch (e) { debugPrint(e.toString()); }
  }

  getNextDirection({required LatLng from}) {
    if (state.instructions.isNotEmpty) {
      var lista = state.instructions;

      // Initialize the first step if not set
      if (state.currentInstruction == null) {
        state = state.copyWith(
          currentInstruction: lista.first,
          instructions: lista.sublist(1)
        );
        return;
      }

      // Calculate the distance to the end location of the current step
      var distanceToEnd = getDistance(
        origin: from,
        destination: LatLng(state.currentInstruction!.endLocation.lat, state.currentInstruction!.endLocation.lng)
      );

      // If the distance to the end location is within a threshold, move to the next step
      if (distanceToEnd < 10) {
        if (lista.isNotEmpty) {
          state = state.copyWith(
            currentInstruction: lista.first,
            instructions: lista.sublist(1)
          );
        } else {
          // No more steps left
          state = state.copyWith(currentInstruction: null);
        }
        return;
      }

      // For long steps, check if the user is far from the start location to avoid premature changes
      var distanceToStart = getDistance(
        origin: from,
        destination: LatLng(state.currentInstruction!.startLocation.lat, state.currentInstruction!.startLocation.lng)
      );

      // If the user is still close to the start location, keep the current step
      if (distanceToStart < 80) {
        return;
      }

      state = state.copyWith(currentInstruction: state.currentInstruction);
    }
  }

  getPolylines(DirectionRoute route){
    List<LatLng> points = PolylinePoints().decodePolyline(route.overviewPolyline.points)
   .map((point) => LatLng(point.latitude, point.longitude))
                 .toList();
                 
    if (points.isEmpty) return [];

    List<Polyline> polylines = [
    Polyline(
        width: 5,
        polylineId: const PolylineId('polyline'),
        color: Colors.green,
        points: points,
      ),
    ];
    
    return polylines;
  }

  Future<Position> getLocation() async {
    try{
      final position = await Geolocator.getCurrentPosition(
      locationSettings: Platform.isAndroid
          ? AndroidSettings(accuracy: LocationAccuracy.high)
          : AppleSettings(accuracy: LocationAccuracy.high),
    );

    return position;
    } catch (e) {
      return Position(
        longitude: 0.0, 
        latitude: 0.0, 
        timestamp: DateTime.now(), 
        accuracy: 0.0, 
        altitude: 0.0, 
        altitudeAccuracy: 0.0, 
        heading: 0.0, 
        headingAccuracy: 0.0, 
        speed: 0.0, 
        speedAccuracy: 0.0);
    }
    
  }

  void addMarker(LatLng position){
    state.origin == null
    ? state = state.copyWith(origin: position)
    : state = state.copyWith(destination: position);
  }



  // void addMarker2(LatLng position){
  //   // we work on temporary list for mutations
  //   var temporaryList = state.markers;

  //   if(state.markers.isEmpty){
  //     // if no items, first one is origin

  //     final newMarker = Marker(
  //       markerId: const MarkerId('origin'),
  //       position: position);

  //     state = state.copyWith(
  //       markers: [newMarker],
  //       origin: position
  //       );

  //   } else {
  //     // check if origin is present in list
  //     bool isOriginPresent = state.markers.any((e)=> e.markerId.value == 'origin');
  //     final point = isOriginPresent ? 'destination' : 'origin';

  //     // if origin is present,  next one is destination
  //     deleteMarkersByType(point, temporaryList);

  //     Marker newMarker = Marker(
  //       markerId: MarkerId(point),
  //       position: position);

  //     // we add the marker
  //     temporaryList.add(newMarker);

  //     state = state.copyWith(
  //       markers: [...temporaryList]
  //       );
      
  //     // if origin is present, then we set the position to destination.
  //     // otherwise, to origin
  //     isOriginPresent
  //     ? state = state.copyWith(destination: position)
  //     : state = state.copyWith(origin: position);

  //   }
    
  //   return;
  // }
}




class TripState{
  final List<DirectionLegStep> instructions;
  final List<Polyline>? polylines;
  final DirectionLegStep? currentInstruction;
  final LatLng? origin;
  final LatLng? destination;
  final List<Marker> markers;

  TripState({
    this.instructions = const [], 
    this.polylines = const [], 
    this.currentInstruction, 
    this.origin, 
    this.destination,
    this.markers = const []
    });

  TripState copyWith({
    List<DirectionLegStep>? instructions,
    List<Polyline>? polylines,
    DirectionLegStep? currentInstruction,
    LatLng? origin,
    LatLng? destination,
    List<Marker>? markers
  }) => TripState(
    instructions : instructions ?? this.instructions,
    polylines : polylines ?? this.polylines,
    currentInstruction : currentInstruction ?? this.currentInstruction,
    // origin : origin ?? this.origin,
    origin : origin?.latitude == 0 ? null : origin ?? this.origin,
    // destination : destination,
    destination : destination?.latitude == 0 ? null : destination ?? this.destination,
    markers : markers ?? [],
  );
}