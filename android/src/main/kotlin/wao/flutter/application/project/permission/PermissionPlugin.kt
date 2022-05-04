package wao.flutter.application.project.permission

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** PermissionPlugin */
class PermissionPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private val REQUEST_PERMISSION = 100
  private val REQUEST_CAMERA_PERMISSION = 101
  private val REQUEST_LOCATION_PERMISSION = 102
  private val REQUEST_STORAGE_PERMISSION = 104
  private val RequestPermissionChannel = "flutter.permission/requestPermission"

  private lateinit var pendingResult: Result

  private lateinit var currentActivity: Activity


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, RequestPermissionChannel)
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    pendingResult = result
    when (call.method) {
      "open_screen" -> {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:${currentActivity.packageName}")
        currentActivity.startActivityForResult(intent, REQUEST_PERMISSION)
      }
      "camera" -> {
        handlePermission(result, arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA_PERMISSION)
      }
      "location" -> {
        handlePermission(result, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_LOCATION_PERMISSION)
      }
      "storage" -> {
        handlePermission(result, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), REQUEST_STORAGE_PERMISSION)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun handlePermission(result: Result, permissions: Array<String>, keyRequest: Int){
    var granted = true
    for(it: String in permissions){
      if (ContextCompat.checkSelfPermission(currentActivity, it) != PackageManager.PERMISSION_GRANTED) {
        granted = false
        break
      }
    }
    if (granted) {
      result.success(1)
    }
    else{
      if(keyRequest == 0){
        result.success(0)
      }
      else{
        ActivityCompat.requestPermissions(currentActivity,
          permissions,
          keyRequest)
      }
    }
  }

  private fun handleRequestPermissionsResult(permissions: Array<String>, grantResults: IntArray){
    val permissionGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
    if (!permissionGranted) {
      var shouldShowRequest = true
      for(it: String in permissions){
        if (!ActivityCompat.shouldShowRequestPermissionRationale(currentActivity, it)) {
          shouldShowRequest = false
          break
        }
      }

      if(shouldShowRequest)
        pendingResult.success(0)
      else
        pendingResult.success(-1)
    }
    else{
      pendingResult.success(1)
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    when (requestCode) {
      REQUEST_LOCATION_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), grantResults)
      }
      REQUEST_CAMERA_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.CAMERA), grantResults)
      }
      REQUEST_STORAGE_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), grantResults)
      }
    }

    return false;
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {

  }
}
