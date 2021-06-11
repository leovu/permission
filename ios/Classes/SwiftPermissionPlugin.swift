import Flutter
import UIKit
import CoreLocation
import AVFoundation

public class SwiftPermissionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelRequest = FlutterMethodChannel(name: "flutter.io/requestPermission",
                                               binaryMessenger: registrar.messenger())
    let channelCheck = FlutterMethodChannel(name: "flutter.io/checkPermission",
                                               binaryMessenger: registrar.messenger())
    
    channelCheck.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if call.method == "open_screen" {
                    Permission.shared.pendingResultOpenScreen = result
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                            Permission.shared.pendingResultOpenScreen?(1)
                            Permission.shared.pendingResultOpenScreen = nil
                        })
                    }
                    else {
                        Permission.shared.pendingResultOpenScreen?(-1)
                        Permission.shared.pendingResultOpenScreen = nil
                    }
                }
                else if call.method == "camera" || call.method == "location" || call.method == "record_audio"  {
                    if call.method == "camera" {
                        Permission.shared.pendingResultCamera = result
                        self?.requestPermission(result: result, type: .camera, isRequest: false)
                    }
                    else if call.method == "location" {
                        Permission.shared.pendingResultLocation = result
                        self?.requestPermission(result: result, type: .location, isRequest: false)
                    }
                    else if call.method == "record_audio" {
                        Permission.shared.pendingResultRecordAudio = result
                        self?.requestPermission(result: result, type: .record_audio, isRequest: false)
                    }
                }
            })
    
    let instance = SwiftPermissionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channelRequest)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "open_screen" {
                      Permission.shared.pendingResultOpenScreen = result
                      if let url = URL(string: UIApplication.openSettingsURLString) {
                          UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                              Permission.shared.pendingResultOpenScreen?(1)
                              Permission.shared.pendingResultOpenScreen = nil
                          })
                      }
                      else {
                          Permission.shared.pendingResultOpenScreen?(-1)
                          Permission.shared.pendingResultOpenScreen = nil
                      }
                  }
                  else if call.method == "camera" || call.method == "location" || call.method == "record_audio"  {
                      if call.method == "camera" {
                          Permission.shared.pendingResultCamera = result
                          self?.requestPermission(result: result, type: .camera, isRequest: true)
                      }
                      else if call.method == "location" {
                          Permission.shared.pendingResultLocation = result
                          self?.requestPermission(result: result, type: .location, isRequest: true)
                      }
                      else if call.method == "record_audio" {
                          Permission.shared.pendingResultRecordAudio = result
                          self?.requestPermission(result: result, type: .record_audio, isRequest: true)
                      }
                  }
    }
    
    func requestPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
            if type == .location {
                self.checkLocationPermission(result: result, type: type, isRequest: isRequest)
            }
            else if type == .camera {
                self.checkCameraPermission(result: result, type: type, isRequest: isRequest)
            }
            else if type == .record_audio {
                self.checkMicrophonePermission(result: result, type: type, isRequest: isRequest)
            }
        }


        func checkMicrophonePermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.denied:
                Permission.shared.pendingResultRecordAudio?(-1)
                Permission.shared.pendingResultRecordAudio = nil
            case AVAudioSession.RecordPermission.granted:
                Permission.shared.pendingResultRecordAudio?(1)
                Permission.shared.pendingResultRecordAudio = nil
            default:
               if isRequest {
                let session: AVAudioSession = AVAudioSession.sharedInstance()
                    if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                            if granted {
                                Permission.shared.pendingResultRecordAudio?(1)
                                Permission.shared.pendingResultRecordAudio = nil
                            } else{
                                Permission.shared.pendingResultRecordAudio?(-1)
                                    Permission.shared.pendingResultRecordAudio = nil
                            }
                        })
                    }
                    else {
                        Permission.shared.pendingResultRecordAudio?(0)
                        Permission.shared.pendingResultRecordAudio = nil
                    }
                }
                else {
                    Permission.shared.pendingResultRecordAudio?(0)
                    Permission.shared.pendingResultRecordAudio = nil
                }
            }
        }

        func checkCameraPermission(result: FlutterResult,type:AppPermission,isRequest:Bool){
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied,.restricted:
                Permission.shared.pendingResultCamera?(-1)
                Permission.shared.pendingResultCamera = nil
            case .authorized:
            Permission.shared.pendingResultCamera?(1)
                Permission.shared.pendingResultCamera = nil
            case .notDetermined:
                if isRequest {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                        if response {
                            Permission.shared.pendingResultCamera?(1)
                            Permission.shared.pendingResultCamera = nil
                        } else {
                            Permission.shared.pendingResultCamera?(-1)
                                Permission.shared.pendingResultCamera = nil
                        }
                    }
                }
                else {
                    Permission.shared.pendingResultCamera?(0)
                    Permission.shared.pendingResultCamera = nil
                }
            }
        }

        func checkLocationPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .restricted, .denied:
                        Permission.shared.pendingResultLocation?(-1)
                        Permission.shared.pendingResultLocation = nil
                    case .authorizedAlways, .authorizedWhenInUse:
                        Permission.shared.pendingResultLocation?(1)
                        Permission.shared.pendingResultLocation = nil
                    default:
                        Permission.shared.pendingResultLocation?(0)
                        Permission.shared.pendingResultLocation = nil
                    break
                }
                } else {
                    Permission.shared.pendingResultLocation?(0)
                    Permission.shared.pendingResultLocation = nil
            }
        }
}
