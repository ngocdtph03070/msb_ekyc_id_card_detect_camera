import Flutter
import UIKit

public class SwiftMSBEkycIdCardDetectCameraPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    /*let channel = FlutterMethodChannel(name: "msb_ekyc_id_card_detect_camera_method_channel", binaryMessenger: registrar.messenger())
    let instance = SwiftSwiftMSBEkycIdCardDetectCameraPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)*/
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
