import 'dart:io';

import 'package:flutter/services.dart';

class PermissionRequest {
  static openSetting() {
    MethodChannel("flutter.io/requestPermission").invokeMethod('open_screen');
  }

  static Future<bool> request(PermissionRequestType type, Function onDontAskAgain) async {
    final channel = MethodChannel("flutter.io/requestPermission");
    bool event = false;
    int? result = 0;

    try{
      if(type == PermissionRequestType.CAMERA){
        result = await channel.invokeMethod<int>('camera');
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await channel.invokeMethod<int>('location');
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await channel.invokeMethod<int>('storage');
      }
    }
    catch(_){}

    if(result == -1)
      onDontAskAgain();
    else if(result == 1)
      event = true;

    return event;
  }

  static Future<bool> check(PermissionRequestType type) async {
    final channel = MethodChannel("flutter.io/checkPermission");
    int? result = 0;
    try{
      if(type == PermissionRequestType.CAMERA){
        result = await channel.invokeMethod<int>('camera');
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await channel.invokeMethod<int>('location');
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await channel.invokeMethod<int>('storage');
      }
    }
    catch(_){}

    return result == 1?true:false;
  }
}

enum PermissionRequestType{
  CAMERA, LOCATION, STORAGE
}