import 'package:msb_ekyc_id_card_detect_camera/src/msb_ekyc_id_card_detect_camera_platform_interface.dart';
import 'package:flutter/material.dart';

import 'msb_ekyc_camera_id_card_detect_plugin.dart';

/// MSBEkycCameraIdCardDetectPlatform
abstract class MSBEkycCameraIdCardDetectPlatform extends ChangeNotifier
    with MSBEkycIdCardDetectCameraPlatform {
  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  static MSBEkycCameraIdCardDetectPlatform _instance = MSBEkycCameraIdCardDetectPlugin();

  bool _isStartCamera = false;
  bool _isStartCameraPreview = false;
  bool _isOpenFlash = false;

  /// The default instance of [MSBEkycCameraIdCardDetectPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [MSBEkycCameraIdCardDetectPlatform] when they
  /// register themselves.
  ///
  static MSBEkycCameraIdCardDetectPlatform get instance => _instance;

  ///
  /// Whether start camera
  bool get isStartCamera => _isStartCamera;

  ///
  /// Whether start camera preview or start to recognize
  bool get isStartCameraPreview => _isStartCameraPreview;

  ///
  /// Whether open the flash
  bool get isOpenFlash => _isOpenFlash;

  String _unsupportedPlatformDescription =
      "Unsupported platforms, working hard to support";

  String get unsupportedPlatformDescription => _unsupportedPlatformDescription;

  set unsupportedPlatformDescription(String text) {
    if (text == null || text.isEmpty) {
      return;
    }
    _unsupportedPlatformDescription = text;
  }

  ///
  /// Instance update
  static set instance(MSBEkycCameraIdCardDetectPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// Returns a widget displaying.
  Widget buildIdCardDetectView(BuildContext context) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  ///
  /// View created of id card detect widget
  onPlatformIdCardDetectViewCreated(int id) {
    notifyListeners();
  }

  ///
  /// Init camera without open id card Detect camera.
  initCamera(String idCardFaceType) async {
    return await MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("initCamera",
        <String, dynamic>{
          'idCardFaceType': idCardFaceType,
        });
  }

  ///
  /// Start camera without open id card Detect camera,this is just open camera.
  startCamera() async {
    _isStartCamera = true;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("startCamera");
  }

  ///
  /// Stop camera.
  stopCamera() async {
    _isStartCamera = false;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("stopCamera");
  }

  ///
  /// Start camera preview with open Face Detect camera,this is open code scanner.
  Future<String> startCameraPreview() async {
    _isStartCameraPreview = true;
    return await MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect
        .invokeMethod("resumeCameraPreview");
  }

  ///
  /// Stop camera preview.
  stopCameraPreview() async {
    _isStartCameraPreview = false;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("stopCameraPreview");
  }

  ///
  /// Open camera flash.
  openFlash() async {
    _isOpenFlash = true;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("openFlash");
  }

  ///
  /// Close camera flash.
  closeFlash() async {
    _isOpenFlash = false;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("closeFlash");
  }

  ///
  /// Toggle camera flash.
  toggleFlash() async {
    bool flash = isOpenFlash;
    _isOpenFlash = !flash;
    MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("toggleFlash");
  }

  ///
  /// Capture image.
  captureImage() async {
    return await MSBEkycIdCardDetectCameraPlatform.methodChannelIdCardDetect.invokeMethod("captureImage");
  }

  // This method makes sure that MSBEkycCamera isn't implemented with `implements`.
  //
  // See class doc for more details on why implementing this class is forbidden.
  //
  // This private method is called by the instance setter, which fails if the class is
  // implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}
}
