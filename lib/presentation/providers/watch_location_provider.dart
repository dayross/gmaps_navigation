

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final watchLocationProvider = StreamProvider.autoDispose<(double, double)>((ref) async*{
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled) {
    throw Future.error('Location services are disabled');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();
  } else if (permission == LocationPermission.deniedForever){
    openAppSettings();
  }

  // assumming now that we have the permission given
  await for (final location in Geolocator.getPositionStream()){
    // whatever we're going to do wit the given location
    // print({location.latitude,' , ', location.longitude});
    yield (location.latitude, location.longitude);
  }
});