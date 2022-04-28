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
}

class Permission {
    static let shared = Permission()
    var pendingResultCamera:FlutterResult?
    var pendingResultLocation:FlutterResult?
    var pendingResultRecordAudio:FlutterResult?
    var pendingResultOpenScreen:FlutterResult?
    var pendingResultStorage:FlutterResult?
    
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
        }


        func checkMicrophonePermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.denied:
                pendingResultRecordAudio?(-1)
                pendingResultRecordAudio = nil
            case AVAudioSession.RecordPermission.granted:
                pendingResultRecordAudio?(1)
                pendingResultRecordAudio = nil
            default:
               if isRequest {
                let session: AVAudioSession = AVAudioSession.sharedInstance()
                    if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                            if granted {
                                self.pendingResultRecordAudio?(1)
                                self.pendingResultRecordAudio = nil
                            } else{
                                self.pendingResultRecordAudio?(-1)
                                self.pendingResultRecordAudio = nil
                            }
                        })
                    }
                    else {
                        self.pendingResultRecordAudio?(0)
                        self.pendingResultRecordAudio = nil
                    }
                }
                else {
                    self.pendingResultRecordAudio?(0)
                    self.pendingResultRecordAudio = nil
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
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .restricted, .denied:
                        self.pendingResultLocation?(-1)
                        self.pendingResultLocation = nil
                    case .authorizedAlways, .authorizedWhenInUse:
                        self.pendingResultLocation?(1)
                        self.pendingResultLocation = nil
                    default:
                        self.pendingResultLocation?(0)
                        self.pendingResultLocation = nil
                    break
                }
                } else {
                    self.pendingResultLocation?(0)
                    self.pendingResultLocation = nil
            }
        }
}

public class SwiftPermissionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelRequest = FlutterMethodChannel(name: "flutter.io/requestPermission",
                                               binaryMessenger: registrar.messenger())
    let channelCheck = FlutterMethodChannel(name: "flutter.io/checkPermission",
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
                  else if call.method == "camera" || call.method == "location" || call.method == "record_audio" || call.method == "storage"{
                      if call.method == "camera" {
                        Permission.shared.pendingResultCamera = result
                        Permission.shared.requestPermission(result: result, type: .camera, isRequest: true)
                      }
                        else if call.method == "storage" {
                          Permission.shared.pendingResultStorage = result
                          Permission.shared.requestPermission(result: result, type: .storage, isRequest: true)
                        }
                      else if call.method == "location" {
                        Permission.shared.pendingResultLocation = result
                        Permission.shared.requestPermission(result: result, type: .location, isRequest: true)
                      }
                      else if call.method == "record_audio" {
                        Permission.shared.pendingResultRecordAudio = result
                        Permission.shared.requestPermission(result: result, type: .record_audio, isRequest: true)
                      }
                  }
    }
}
