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

class Permission {
    static let shared = Permission()
    let getLocation = GetLocation()
    var pendingResultCamera:FlutterResult?
    var pendingResultLocation:FlutterResult?
    var pendingResultRecordAudio:FlutterResult?
    var pendingResultOpenScreen:FlutterResult?
    var pendingResultStorage:FlutterResult?
    var pendingResultNotification:FlutterResult?
    var pendingResultMicrophone:FlutterResult?
    
    func requestPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
            if type == .location {
                self.checkLocationPermission(result: result, type: type, isRequest: isRequest)
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

    func checkLocationPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
        if(!isRequest) {
            permission(isRequest: false)
        }
        else {
            Permission.shared.getLocation.run { location in
                if location != nil {
                    self.pendingResultLocation?(1)
                    self.pendingResultLocation = nil
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.permission(isRequest: true)
                    }
                }
            }
        }
    }
    var isCallingLocationRequest = false
    func permission(isRequest:Bool) {
        if isCallingLocationRequest {
            return
        }
        isCallingLocationRequest = true
        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied:
                self.isCallingLocationRequest = false
                self.pendingResultLocation?(-1)
                self.pendingResultLocation = nil
        case .authorizedAlways, .authorizedWhenInUse , .authorized:
            Permission.shared.getLocation.run { location in
                    if location != nil {
                        self.isCallingLocationRequest = false
                        self.pendingResultLocation?(1)
                        self.pendingResultLocation = nil
                    }
                    else {
                        self.isCallingLocationRequest = false
                        self.pendingResultLocation?(-1)
                        self.pendingResultLocation = nil
                    }
                }
        default:
                if(isRequest) {
                    let getLocation = GetLocation()
                    getLocation.run { location in
                        if location != nil {
                            self.isCallingLocationRequest = false
                            self.pendingResultLocation?(1)
                            self.pendingResultLocation = nil
                        }
                        else {
                            self.isCallingLocationRequest = false
                            self.pendingResultLocation?(-1)
                            self.pendingResultLocation = nil
                        }
                    }
                }
                else {
                    self.isCallingLocationRequest = false
                    self.pendingResultLocation?(-1)
                    self.pendingResultLocation = nil
                }
            break
        }
    }
}

public class SwiftPermissionPlugin: NSObject, FlutterPlugin {
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
                      var isAlways:Bool = false
                      if let dictionary = call.arguments as? [String: Any],
                            let iR = dictionary ["isRequest"] as? Bool , let iA = dictionary["isAlways"] as? Bool {
                          isRequest = iR
                          isAlways = iA
                      }
                      if isAlways {
                          if CLLocationManager.authorizationStatus() == .authorizedAlways {
                              result(1)
                          }
                          else {
                              result(0)
                          }
                      }
                      else {
                          if call.method == "camera" {
                            Permission.shared.pendingResultCamera = result
                            Permission.shared.requestPermission(result: result, type: .camera, isRequest: isRequest)
                          }
                            else if call.method == "storage" {
                              Permission.shared.pendingResultStorage = result
                              Permission.shared.requestPermission(result: result, type: .storage, isRequest: isRequest)
                            }
                          else if call.method == "location" {
                            Permission.shared.pendingResultLocation = result
                            Permission.shared.requestPermission(result: result, type: .location, isRequest: isRequest)
                          }
                          else if call.method == "record_audio" {
                            Permission.shared.pendingResultRecordAudio = result
                            Permission.shared.requestPermission(result: result, type: .record_audio, isRequest: isRequest)
                          }
                          else if call.method == "notification" {
                            Permission.shared.pendingResultNotification = result
                            Permission.shared.requestPermission(result: result, type: .notification, isRequest: isRequest)
                          }
                          else if call.method == "microphone" {
                            Permission.shared.pendingResultMicrophone = result
                            Permission.shared.requestPermission(result: result, type: .microphone, isRequest: isRequest)
                          }
                      }
                      
                }
    }
}

public class GetLocation: NSObject, CLLocationManagerDelegate {
    var manager:CLLocationManager!
    private var handler: ((CLLocation?) -> Void)?
    var didFailWithError: Error?

    override init() {
        manager = CLLocationManager()
    }
    
    public func run(handler: @escaping (CLLocation?) -> Void) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestLocation()
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        self.handler = handler
    }

   public func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        self.handler!(locations.last!)
        manager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError = error
        self.handler!(nil)
        manager.stopUpdatingLocation()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            if manager.authorizationStatus == .denied {
                self.handler!(nil)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            self.handler!(nil)
        }
    }

    deinit {
        manager.stopUpdatingLocation()
    }
}
