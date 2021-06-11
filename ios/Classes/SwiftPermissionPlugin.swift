import Flutter
import UIKit
import CoreLocation
import AVFoundation

public class SwiftPermissionPlugin: NSObject, FlutterPlugin {
    static let _channel = "flutter.io/permission";
    let _cameraType = "camera";
    let _locationType = "location";
    let _recordType = "record_audio";
    let _openScreenType = "open_screen";
    let _actionArgKey = "action";
    let _requestArgValue = "request";
    var result:FlutterResult?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: _channel, binaryMessenger: registrar.messenger())
    let instance = SwiftPermissionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        if call.method == _openScreenType {
                      if let url = URL(string: UIApplication.openSettingsURLString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                self.result?(1)
                                self.result = nil
                            })
                        }
                        else {
                            UIApplication.shared.openURL(url)
                            self.result?(-1)
                            self.result = nil
                        }
                      }
                      else {
                        self.result?(-1)
                        self.result = nil
                      }
                  }
                  else {
                    guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
                                result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (start)") )
                                return
                            }
                            let action:String = args[_actionArgKey] as! String
                      if call.method == _cameraType {
                        if(action == _requestArgValue){
                            self.requestPermission(result: result, type: .camera, isRequest: true)
                        }
                        else{
                            self.requestPermission(result: result, type: .camera, isRequest: false)
                        }
                      }
                      else if call.method == _locationType {
                        if(action == _requestArgValue){
                            self.requestPermission(result: result, type: .location, isRequest: true)
                        }
                        else{
                            self.requestPermission(result: result, type: .location, isRequest: false)
                        }
                      }
                      else if call.method == _recordType {
                        if(action == _requestArgValue){
                            self.requestPermission(result: result, type: .record_audio, isRequest: true)
                        }
                        else{
                            self.requestPermission(result: result, type: .record_audio, isRequest: false)
                        }
                      }
                  }
    }
    
    func requestPermission(result: @escaping FlutterResult,type:AppPermission,isRequest:Bool) {
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


        func checkMicrophonePermission(result: @escaping FlutterResult,type:AppPermission,isRequest:Bool){
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.denied:
                result(-1)
                self.result = nil
            case AVAudioSession.RecordPermission.granted:
                result(-1)
                self.result = nil
            default:
               if isRequest {
                let session: AVAudioSession = AVAudioSession.sharedInstance()
                    if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            if granted {
                                result(1)
                                self.result = nil
                            } else{
                                result(-1)
                                self.result = nil
                            }
                        }
                    }
                    else {
                        result(0)
                        self.result = nil
                    }
                }
                else {
                    result(0)
                    self.result = nil
                }
            }
        }

    func checkCameraPermission(result: @escaping FlutterResult,type:AppPermission,isRequest:Bool){
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied,.restricted:
                result(-1)
                self.result = nil
            case .authorized:
                result(1)
                self.result = nil
            case .notDetermined:
                if isRequest {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                        if response {
                            result(1)
                            self.result = nil
                        } else {
                            result(-1)
                            self.result = nil
                        }
                    }
                }
                else {
                    result(0)
                    self.result = nil
                }
            @unknown default:
                result(-1)
                self.result = nil
            }
        }

        func checkLocationPermission(result: FlutterResult,type:AppPermission,isRequest:Bool) {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .restricted, .denied:
                        result(-1)
                    self.result = nil
                    case .authorizedAlways, .authorizedWhenInUse:
                        result(1)
                        self.result = nil
                    default:
                        result(0)
                        self.result = nil
                    break
                }
                } else {
                    result(0)
                    self.result = nil
            }
        }
}

enum AppPermission
{
   case camera
   case location
   case record_audio
}
