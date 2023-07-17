import 'dart:io';

import 'package:flutter/material.dart';

import 'package:permission/permission.dart';
import 'package:permission_example/custom_navigator.dart';
import 'package:permission_example/custom_permission_request.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  bool _isAllow = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: _isAllow?Text("Allowed Location Permission"):MaterialButton(
              child: Text(
                  "Request Location Permission"
              ),
              onPressed: () async {
                await PermissionRequest.request(PermissionRequestType.CAMERA, (){});
                await _checkLocationPermission();
                // _openSetting();
                // _checkLocationPermission();
                // _isAllow = await PermissionRequest.request(PermissionRequestType.LOCATION, (){
                //   showDialog(
                //       context: context,
                //       builder: (_){
                //         return AlertDialog(
                //           title: Text("Allowed to access"),
                //           content: Text("Select Settings to App Information, select (Permissions), enable access and re-enter this screen to use Storage"),
                //           actions: [
                //             TextButton(
                //                 child: Text("Allow"),
                //                 onPressed: (){
                //                   Navigator.of(context).pop();
                //                   PermissionRequest.openSetting();
                //                 }
                //             )
                //           ],
                //         );
                //       }
                //   );
                // });
                // setState(() {});
              }
          )
      ),
    );
  }

  void _openSetting() {
    CustomNavigator.showCustomAlertDialog(
      context, "Xin quyền",
      title: "Vị trí",
      enableCancelButton: true,
      textSubmitted: "Ok",
      onSubmitted: () {
        CustomNavigator.pop(context);
        // PermissionRequest.openSetting();
      },
    );
  }


  Future<bool> _checkBackgroundLocationPermission() async {
    if (Platform.isAndroid) {
      return CustomPermissionRequest.check(
          PermissionRequestType.BACKGROUND_LOCATION);
    } else {
      return CustomPermissionRequest.check(PermissionRequestType.LOCATION,
          checkAlways: true);
    }
  }

  _checkLocationPermission() async {
    bool value = await CustomPermissionRequest.check(
      PermissionRequestType.LOCATION,
    );

    if (value) {
      value = await _checkBackgroundLocationPermission();

      if (!value) {
        await CustomNavigator.showCustomAlertDialog(
            context, "back ground request",
            textSubmitted: "ok",
            cancelable: false,
            onSubmitted: () => CustomNavigator.pop(context, object: true));

        _requestBackgroundLocationPermission();
      } else {
        init();
      }
    } else {
      await CustomNavigator.showCustomAlertDialog(
          context, "back ground request",
          textSubmitted: "ok",
          cancelable: false,
          onSubmitted: () => CustomNavigator.pop(context, object: true));

      await CustomPermissionRequest.request(
          context, PermissionRequestType.LOCATION, onDontAskAgain: () {
        // PermissionRequest.openSetting();
      });

      _checkLocationPermission();
    }
  }



  Future<void> init() async {
    print("heelolllloooo");
  }


  _requestBackgroundLocationPermission() async {
    if (Platform.isAndroid) {
      bool value = await CustomPermissionRequest.request(
          context, PermissionRequestType.BACKGROUND_LOCATION,
          onDontAskAgain: () => (){});
      if (!value) {
        _checkLocationPermission();
      }
    } else {
      // PermissionRequest.openSetting();
      _checkLocationPermission();
    }
  }



}
