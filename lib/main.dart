import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String location = 'Нажмите определить местоположение';
  String Address = 'Поиск..';

  @override
  void initState() {
    super.initState();
    // ignore: cancel_subscriptions
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best)
            .listen((Position position) {
      location =
          'Широта: ${position.latitude} , Долгота: ${position.longitude}';
      GetAddressFromLatLong(position);
    });
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
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
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subThoroughfare}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Координаты',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              location,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // This is what you need!
                ),
                onPressed: () async {
                  Position position = await _getGeoLocationPosition();
                  MapsLauncher.launchCoordinates(
                      position.latitude, position.longitude);
                  // GetAddressFromLatLong(position);
                },
                child: Text('Открыть карту'),
                autofocus: false,
                clipBehavior: Clip.none),
            SizedBox(
              height: 10,
            ),
            Text(
              'Адрес',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '(точность от 0 до 50 метров)',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              '${Address}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
                icon: Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 70.0,
                ),
                label: Text('Вызвать 112'),
                onPressed: () async {
                  const number = '112'; //set the number here
                  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
                },
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(70.0),
                  ),
                )),
            // ElevatedButton(
            //     onPressed: () async {
            //       const number = '+79218790724'; //set the number here
            //       bool? res = await FlutterPhoneDirectCaller.callNumber(number);
            //     },
            //     child: Text('Вызвать 112'),
            //     autofocus: false,
            //     clipBehavior: Clip.none)
          ],
        ),
      ),
    );
  }
}
