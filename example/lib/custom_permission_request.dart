import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:permission_example/custom_navigator.dart';

class CustomPermissionRequest {
  static Future<bool> request(BuildContext context, PermissionRequestType type,
      {required Function? onDontAskAgain}) async {
    return PermissionRequest.request(
        type,
        onDontAskAgain ??
                () {
              assert(context != null);
              String permission = "";
              if (type == PermissionRequestType.CAMERA) {
                permission = "camera required";
              } else if (type == PermissionRequestType.LOCATION) {
                permission = "location required";
              } else if (type == PermissionRequestType.BACKGROUND_LOCATION) {
                permission = "background location required";
              } else if (type == PermissionRequestType.STORAGE) {
                permission = "storage location required";
              }
              return CustomNavigator.showCustomAlertDialog(
                context, permission,
                title: permission,
                enableCancelButton: true,
                textSubmitted: "Ok",
                onSubmitted: () {
                  CustomNavigator.pop(context);
                  PermissionRequest.openSetting();
                },
              );
            });
  }

  static Future<bool> check(PermissionRequestType type,
      {bool checkAlways = false}) =>
      PermissionRequest.check(type, checkAlways: checkAlways);
}
