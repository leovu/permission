package wao.flutter.application.project.permission

import android.Manifest
import android.annotation.TargetApi
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
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
  private val CHECK_PERMISSION = 0
  private val REQUEST_PERMISSION = 100
  private val REQUEST_CAMERA_PERMISSION = 101
  private val REQUEST_LOCATION_PERMISSION = 102
  private val REQUEST_BACKGROUND_LOCATION_PERMISSION = 103
  private val REQUEST_STORAGE_PERMISSION = 104
  private val REQUEST_NOTIFICATION_PERMISSION = 105
  private val REQUEST_MICROPHONE_PERMISSION = 106
  private val RequestPermissionChannel = "flutter.permission/requestPermission"

  private lateinit var pendingResult: Result
  private lateinit var context: Context
  private lateinit var currentActivity: Activity


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, RequestPermissionChannel)
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

  @TargetApi(33)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    pendingResult = result
    var isRequest = false
    if(call.argument<Boolean>("isRequest") != null){
      isRequest = call.argument<Boolean>("isRequest")!!
    }
    when (call.method) {
      "open_screen" -> {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:${currentActivity.packageName}")
        currentActivity.startActivityForResult(intent, REQUEST_PERMISSION)
      }
      "camera" -> {
        handlePermission(
          result,
          arrayOf(Manifest.permission.CAMERA),
          if(isRequest) REQUEST_CAMERA_PERMISSION else CHECK_PERMISSION
        )
      }
      "location" -> {
        handlePermission(
          result,
          arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION),
          if(isRequest) REQUEST_LOCATION_PERMISSION else CHECK_PERMISSION
        )
      }
      "background_location" -> {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
          handlePermission(
            result,
            arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
            if(isRequest) REQUEST_BACKGROUND_LOCATION_PERMISSION else CHECK_PERMISSION
          )
        }
        else{
          result.success(1)
        }
      }
      "storage" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
          handlePermission(result, arrayOf(
            Manifest.permission.READ_MEDIA_IMAGES,
            Manifest.permission.READ_MEDIA_VIDEO,
            Manifest.permission.READ_MEDIA_AUDIO
          ), if(isRequest) REQUEST_STORAGE_PERMISSION else CHECK_PERMISSION)
        }
        else {
          handlePermission(
            result,
            arrayOf(
              Manifest.permission.READ_EXTERNAL_STORAGE,
              Manifest.permission.WRITE_EXTERNAL_STORAGE
            ),
            if(isRequest) REQUEST_STORAGE_PERMISSION else CHECK_PERMISSION)
        }
      }
      "microphone" -> {
        handlePermission(
          result,
          arrayOf(Manifest.permission.RECORD_AUDIO),
          if(isRequest) REQUEST_MICROPHONE_PERMISSION else CHECK_PERMISSION
        )
      }
      "notification" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
          handlePermission(
            result,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            if(isRequest) REQUEST_NOTIFICATION_PERMISSION else CHECK_PERMISSION
          )
        }
        else {
          result.success(1)
        }
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
      if(keyRequest == CHECK_PERMISSION){
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

  @TargetApi(33)
  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    when (requestCode) {
      REQUEST_LOCATION_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), grantResults)
      }
      REQUEST_BACKGROUND_LOCATION_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION), grantResults)
      }
      REQUEST_CAMERA_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.CAMERA), grantResults)
      }
      REQUEST_STORAGE_PERMISSION -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
          handleRequestPermissionsResult(arrayOf(
            Manifest.permission.READ_MEDIA_IMAGES,
            Manifest.permission.READ_MEDIA_VIDEO,
            Manifest.permission.READ_MEDIA_AUDIO
          ), grantResults)
        }
        else{
          handleRequestPermissionsResult(arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE), grantResults)
        }
      }
      REQUEST_MICROPHONE_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.RECORD_AUDIO), grantResults)
      }
      REQUEST_NOTIFICATION_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.POST_NOTIFICATIONS), grantResults)
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
