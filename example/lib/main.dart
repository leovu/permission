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

  Widget _buildItem(String text, GestureTapCallback onTap) {
    return InkWell(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildItem(
                "Check Camera", () => _check(PermissionRequestType.CAMERA)),
            _buildItem(
                "Request Camera", () => _request(PermissionRequestType.CAMERA)),
            _buildItem(
                "Check Location", () => _check(PermissionRequestType.LOCATION)),
            _buildItem("Request Location",
                () => _request(PermissionRequestType.LOCATION)),
            _buildItem("Check BackgroundLocation",
                () => _check(PermissionRequestType.BACKGROUND_LOCATION)),
            _buildItem("Request BackgroundLocation",
                () => _request(PermissionRequestType.BACKGROUND_LOCATION)),
            _buildItem(
                "Check Storage", () => _check(PermissionRequestType.STORAGE)),
            _buildItem("Request Storage",
                () => _request(PermissionRequestType.STORAGE)),
            _buildItem("Check Notification",
                () => _check(PermissionRequestType.NOTIFICATION)),
            _buildItem("Request Notification",
                () => _request(PermissionRequestType.NOTIFICATION)),
            _buildItem("Check Microphone",
                () => _check(PermissionRequestType.MICROPHONE)),
            _buildItem("Request Microphone",
                () => _request(PermissionRequestType.MICROPHONE)),
          ],
        ),
      ),
    );
  }

  _check(PermissionRequestType type) async {
    print("Check: $type");
    bool event = await CustomPermissionRequest.check(type);
    print("Check Value: $event");
    CustomNavigator.showCustomAlertDialog(
      context,
      event ? "Allowed" : "Dinied",
    );
  }

  _request(PermissionRequestType type) async {
    print("Request: $type");
    bool event = await CustomPermissionRequest.request(context, type,
        onDontAskAgain: () {
      CustomNavigator.showCustomAlertDialog(
        context,
        "onDontAskAgain",
      );
    });
    print("Request Value: $event");
    CustomNavigator.showCustomAlertDialog(
      context,
      event ? "Allowed" : "Dinied",
    );
  }
}
