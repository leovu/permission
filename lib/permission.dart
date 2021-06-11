import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionRequest {
  static const _channel = MethodChannel("flutter.io/permission");
  static const _cameraType = "camera";
  static const _locationType = "location";
  static const _storageType = "storage";
  static const _recordType = "record_audio";
  static const _openScreenType = "open_screen";
  static const _actionArgKey = "action";
  static const _requestArgValue = "request";
  static const _checkArgValue = "check";

  static openSetting() {
    _channel.invokeMethod(_openScreenType);
  }

  static Future<bool> request(BuildContext context, PermissionRequestType type, Function onDontAskAgain) async {

    bool event = false;
    int result = 0;

    try{
      if(type == PermissionRequestType.CAMERA){
        result = await _channel.invokeMethod<int>(_cameraType,{_actionArgKey: _requestArgValue});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await _channel.invokeMethod<int>(_locationType,{_actionArgKey: _requestArgValue});
      }
      else if(type == PermissionRequestType.STORAGE){
        if(Platform.isAndroid){
          result = await _channel.invokeMethod<int>(_storageType,{_actionArgKey: _requestArgValue});
        }
        else
          result = 1;
      }
      else if(type == PermissionRequestType.RECORD_AUDIO){
        result = await _channel.invokeMethod<int>(_recordType,{_actionArgKey: _requestArgValue});
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
    int result = 0;
    try{
      if(type == PermissionRequestType.CAMERA){
        result = await _channel.invokeMethod<int>(_cameraType,{_actionArgKey: _checkArgValue});
      }
      else if(type == PermissionRequestType.LOCATION){
        result = await _channel.invokeMethod<int>(_locationType,{_actionArgKey: _checkArgValue});
      }
      else if(type == PermissionRequestType.STORAGE){
        result = await _channel.invokeMethod<int>(_storageType,{_actionArgKey: _checkArgValue});
      }
      else if(type == PermissionRequestType.RECORD_AUDIO){
        result = await _channel.invokeMethod<int>(_recordType,{_actionArgKey: _checkArgValue});
      }
    }
    catch(_){}

    return result == 1?true:false;
  }
}

enum PermissionRequestType{
  CAMERA, LOCATION, STORAGE, RECORD_AUDIO
}