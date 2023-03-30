import 'dart:io';

import 'package:flutter/services.dart';

class PermissionRequest {
  static final _channel = MethodChannel("flutter.permission/requestPermission");

  static openSetting() {
    MethodChannel("flutter.permission/requestPermission").invokeMethod('open_screen');
  }

  static Future<bool> request(PermissionRequestType type, Function onDontAskAgain) async {
    bool event = false;
    int? result = 0;

    try{
      if(type == PermissionRequestType.CAMERA){
        result = await _channel.invokeMethod<int>('camera',{'isRequest':true});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await _channel.invokeMethod<int>('location',{'isRequest':true});
      }
      else if(type == PermissionRequestType.BACKGROUND_LOCATION){
        result = await _channel.invokeMethod<int>('background_location',{'isRequest':true});
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await _channel.invokeMethod<int>('storage',{'isRequest':true});
      }
      else if(type == PermissionRequestType.NOTIFICATION){
        result = await _channel.invokeMethod<int>('notification',{'isRequest':true});
      }
      else if(type == PermissionRequestType.MICROPHONE){
        result = await _channel.invokeMethod<int>('microphone',{'isRequest':true});
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
    int? result = 0;
    try{
      if(type == PermissionRequestType.CAMERA){
        result = await _channel.invokeMethod<int>('camera',{'isRequest':false});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await _channel.invokeMethod<int>('location',{'isRequest':false});
      }
      else if(type == PermissionRequestType.BACKGROUND_LOCATION){
        result = await _channel.invokeMethod<int>('background_location',{'isRequest':false});
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await _channel.invokeMethod<int>('storage',{'isRequest':false});
      }
      else if(type == PermissionRequestType.NOTIFICATION){
        result = await _channel.invokeMethod<int>('notification',{'isRequest':false});
      }
      else if(type == PermissionRequestType.MICROPHONE){
        result = await _channel.invokeMethod<int>('microphone',{'isRequest':false});
      }
    }
    catch(_){}

    return result == 1?true:false;
  }
}

enum PermissionRequestType{
  CAMERA, LOCATION, BACKGROUND_LOCATION, STORAGE, NOTIFICATION, MICROPHONE
}