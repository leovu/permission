import 'dart:io';

import 'package:flutter/services.dart';

class PermissionRequest {
  static openSetting() {
    MethodChannel("flutter.permission/requestPermission").invokeMethod('open_screen');
  }

  static Future<bool> request(PermissionRequestType type, Function onDontAskAgain) async {
    final channel = MethodChannel("flutter.permission/requestPermission");
    bool event = false;
    int? result = 0;

    try{
      if(type == PermissionRequestType.CAMERA){
        result = await channel.invokeMethod<int>('camera',{'isRequest':true});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await channel.invokeMethod<int>('location',{'isRequest':true});
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await channel.invokeMethod<int>('storage',{'isRequest':true});
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
    final channel = MethodChannel("flutter.permission/checkPermission");
    int? result = 0;
    try{
      if(type == PermissionRequestType.CAMERA){
        result = await channel.invokeMethod<int>('camera',{'isRequest':false});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await channel.invokeMethod<int>('location',{'isRequest':false});
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await channel.invokeMethod<int>('storage',{'isRequest':false});
      }
    }
    catch(_){}

    return result == 1?true:false;
  }
}

enum PermissionRequestType{
  CAMERA, LOCATION, STORAGE
}