import Flutter
import UIKit
import CoreLocation
import AVFoundation
import Photos

enum AppPermission
{
   case camera
   case location
   case record_audio
   case storage
   case notification
   case microphone
}

class Permission:NSObject,CLLocationManagerDelegate {
    static let shared = Permission()
    var pendingResultCamera:FlutterResult?
    var pendingResultLocation:FlutterResult?
    var pendingResultRecordAudio:FlutterResult?
    var pendingResultOpenScreen:FlutterResult?
    var pendingResultStorage:FlutterResult?
    var pendingResultNotification:FlutterResult?
    var pendingResultMicrophone:FlutterResult?
    var manager:CLLocationManager!
    
    func requestPermission(result: FlutterResult,type:AppPermission,isRequest:Bool,isAlways:Bool) {
        if type == .location {
            self.checkLocationPermission(result: result, type: type, isRequest: isRequest, isAlways: isAlways)
        }
        else if type == .camera {
            self.checkCameraPermission(result: result, type: type, isRequest: isRequest)
        }
        else if type == .storage {
            self.checkPhotoPermission(result: result, type: type, isRequest: isRequest)
        }
        else if type == .record_audio {
            self.checkMicrophonePermission(result: result, type: type, isRequest: isRequest)
        }
        else if type == .notification {
            self.checkNotificationPermission(result: result, type: type, isRequest: isRequest)
        }
        else if type == .microphone {
            self.checkMicrophonePermission(result: result, type: type, isRequest: isRequest)
        }
    }
    
    func checkNotificationPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                if(isRequest) {
                    let center  = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                        if error == nil{
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        if granted {
                            self.pendingResultNotification?(1)
                            self.pendingResultNotification = nil
                        }
                        else {
                            self.pendingResultNotification?(0)
                            self.pendingResultNotification = nil
                        }
                    }
                }
                else {
                    self.pendingResultNotification?(0)
                    self.pendingResultNotification = nil
                }
            }
            else if settings.authorizationStatus == .denied {
                self.pendingResultNotification?(-1)
                self.pendingResultNotification = nil
            }
            else {
                self.pendingResultNotification?(1)
                self.pendingResultNotification = nil
            }
        }
    }
    
    func checkMicrophonePermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.denied:
            if pendingResultRecordAudio != nil {
                pendingResultRecordAudio?(-1)
                pendingResultRecordAudio = nil
            }
            if pendingResultMicrophone != nil {
                pendingResultMicrophone?(-1)
                pendingResultMicrophone = nil
            }
        case AVAudioSession.RecordPermission.granted:
            if pendingResultRecordAudio != nil {
                pendingResultRecordAudio?(1)
                pendingResultRecordAudio = nil
            }
            if pendingResultMicrophone != nil {
                pendingResultMicrophone?(1)
                pendingResultMicrophone = nil
            }
        default:
            if isRequest {
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted {
                        if self.pendingResultRecordAudio != nil {
                            self.pendingResultRecordAudio?(1)
                            self.pendingResultRecordAudio = nil
                        }
                        if self.pendingResultMicrophone != nil {
                            self.pendingResultMicrophone?(1)
                            self.pendingResultMicrophone = nil
                        }
                    } else{
                        if self.pendingResultRecordAudio != nil {
                            self.pendingResultRecordAudio?(-1)
                            self.pendingResultRecordAudio = nil
                        }
                        if self.pendingResultMicrophone != nil {
                            self.pendingResultMicrophone?(-1)
                            self.pendingResultMicrophone = nil
                        }
                    }
                })
            }
            else {
                if self.pendingResultRecordAudio != nil {
                    self.pendingResultRecordAudio?(0)
                    self.pendingResultRecordAudio = nil
                }
                if self.pendingResultMicrophone != nil {
                    self.pendingResultMicrophone?(0)
                    self.pendingResultMicrophone = nil
                }
            }
        }
    }
    
    func checkCameraPermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied,.restricted:
            pendingResultCamera?(-1)
            pendingResultCamera = nil
        case .authorized:
            pendingResultCamera?(1)
            pendingResultCamera = nil
        case .notDetermined:
            if isRequest {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                    if response {
                        self.pendingResultCamera?(1)
                        self.pendingResultCamera = nil
                    } else {
                        self.pendingResultCamera?(-1)
                        self.pendingResultCamera = nil
                    }
                }
            }
            else {
                self.pendingResultCamera?(0)
                self.pendingResultCamera = nil
            }
        @unknown default:
            self.pendingResultCamera?(0)
            self.pendingResultCamera = nil
        }
    }
    
    func checkPhotoPermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            if isRequest {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        self.pendingResultStorage?(1)
                        self.pendingResultStorage = nil
                    }
                    else {
                        self.pendingResultStorage?(0)
                        self.pendingResultStorage = nil
                    }
                })
            }
            else {
                self.pendingResultStorage?(0)
                self.pendingResultStorage = nil
            }
        } else if photos == .authorized{
            self.pendingResultStorage?(1)
            self.pendingResultStorage = nil
        }
        else {
            pendingResultStorage?(-1)
            pendingResultStorage = nil
        }
    }
    
    func checkLocationPermission(result: FlutterResult,type:AppPermission,isRequest:Bool,isAlways:Bool) {
        if(!isRequest) {
            permission()
        }
        else {
            run(isAlways: isAlways)
        }
    }
    func permission() {
        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied:
            self.pendingResultLocation?(-1)
            self.pendingResultLocation = nil
            break
        case .authorizedAlways, .authorizedWhenInUse , .authorized:
            self.pendingResultLocation?(1)
            self.pendingResultLocation = nil
            break
        default:
            self.pendingResultLocation?(0)
            self.pendingResultLocation = nil
            break
        }
    }
    
    public func run(isAlways:Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse  || CLLocationManager.authorizationStatus() == .authorizedAlways {
            if isAlways {
                if CLLocationManager.authorizationStatus() == .authorizedAlways {
                    self.pendingResultLocation?(1)
                    self.pendingResultLocation = nil
                }
                else {
                    Permission.shared.manager.delegate = self
                    Permission.shared.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    Permission.shared.manager.requestAlwaysAuthorization()
                }
            }
            else {
                self.pendingResultLocation?(1)
                self.pendingResultLocation = nil
            }
        }
        else {
            Permission.shared.manager.delegate = self
            Permission.shared.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            Permission.shared.manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    var authStatus = CLAuthorizationStatus.notDetermined
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #unavailable(iOS 14) {
            if Permission.shared.pendingResultLocation != nil && status != authStatus {
                switch status {
                case .restricted, .denied:
                    authStatus = status
                    Permission.shared.pendingResultLocation?(-1)
                    Permission.shared.pendingResultLocation = nil
                case .authorizedAlways, .authorizedWhenInUse , .authorized:
                    authStatus = status
                    Permission.shared.pendingResultLocation?(1)
                    Permission.shared.pendingResultLocation = nil
                default:
                    authStatus = status
                    Permission.shared.pendingResultLocation?(0)
                    Permission.shared.pendingResultLocation = nil
                    break
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if Permission.shared.pendingResultLocation != nil {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                Permission.shared.pendingResultLocation?(-1)
                Permission.shared.pendingResultLocation = nil
            case .authorizedAlways, .authorizedWhenInUse , .authorized:
                Permission.shared.pendingResultLocation?(1)
                Permission.shared.pendingResultLocation = nil
            default:
                Permission.shared.pendingResultLocation?(0)
                Permission.shared.pendingResultLocation = nil
                break
            }
        }
    }
}

public class SwiftPermissionPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelRequest = FlutterMethodChannel(name: "flutter.permission/requestPermission",
                                               binaryMessenger: registrar.messenger())
    let channelCheck = FlutterMethodChannel(name: "flutter.permission/checkPermission",
                                               binaryMessenger: registrar.messenger())
    let instance = SwiftPermissionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channelRequest)
    registrar.addMethodCallDelegate(instance, channel: channelCheck)
  }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "open_screen" {
                      Permission.shared.pendingResultOpenScreen = result
                      if let url = URL(string: UIApplication.openSettingsURLString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                Permission.shared.pendingResultOpenScreen?(1)
                                Permission.shared.pendingResultOpenScreen = nil
                            })
                        } else {
                            // Fallback on earlier versions
                        }
                      }
                      else {
                        Permission.shared.pendingResultOpenScreen?(-1)
                        Permission.shared.pendingResultOpenScreen = nil
                      }
                  }
                  else {
                      var isRequest:Bool = false
                      if let dictionary = call.arguments as? [String: Any] {
                          if let iR = dictionary ["isRequest"] as? Bool {
                              isRequest = iR
                          }
                      }
                      if call.method == "camera" {
                        Permission.shared.pendingResultCamera = result
                        Permission.shared.requestPermission(result: result, type: .camera, isRequest: isRequest, isAlways: false)
                      }
                        else if call.method == "storage" {
                              Permission.shared.pendingResultStorage = result
                              Permission.shared.requestPermission(result: result, type: .storage, isRequest: isRequest, isAlways: false)
                        }
                      else if call.method == "location" {
                        Permission.shared.manager = CLLocationManager()
                        Permission.shared.pendingResultLocation = result
                        Permission.shared.requestPermission(result: result, type: .location, isRequest: isRequest, isAlways: false)
                      }
                      else if call.method == "background_location" {
                        Permission.shared.manager = CLLocationManager()
                        Permission.shared.pendingResultLocation = result
                        Permission.shared.requestPermission(result: result, type: .location, isRequest: isRequest, isAlways: true)
                      }
                      else if call.method == "record_audio" {
                        Permission.shared.pendingResultRecordAudio = result
                        Permission.shared.requestPermission(result: result, type: .record_audio, isRequest: isRequest, isAlways: false)
                      }
                      else if call.method == "notification" {
                        Permission.shared.pendingResultNotification = result
                        Permission.shared.requestPermission(result: result, type: .notification, isRequest: isRequest, isAlways: false)
                      }
                      else if call.method == "microphone" {
                        Permission.shared.pendingResultMicrophone = result
                        Permission.shared.requestPermission(result: result, type: .microphone, isRequest: isRequest, isAlways: false)
                      }
                }
    }
}
