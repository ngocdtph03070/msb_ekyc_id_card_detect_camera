import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'msb_ekyc_camera_platform_id_card_detect_interface.dart';
import '../msb_ekyc_id_card_detect_camera_platform_interface.dart';

///
/// MSBEkycCameraIdCardDetectPlugin
class MSBEkycCameraIdCardDetectPlugin extends MSBEkycCameraIdCardDetectPlatform {
  @override
  Widget buildIdCardDetectView(BuildContext context) {
    return _cameraView(context);
  }

  /// Face Detect widget
  ///
  /// Support android and ios platform face detect
  Widget _cameraView(BuildContext context) {
    TargetPlatform targetPlatform = Theme.of(context).platform;

    if (targetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: MSBEkycIdCardDetectCameraPlatform.viewIdOfIdCardDetect,
        onPlatformViewCreated: (int id) {
          onPlatformIdCardDetectViewCreated(id);
        },
        creationParams: <String, dynamic>{},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (targetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: MSBEkycIdCardDetectCameraPlatform.viewIdOfIdCardDetect,
        onPlatformViewCreated: (int id) {
          onPlatformIdCardDetectViewCreated(id);
        },
        creationParams: <String, dynamic>{},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Center(
        child: Text(
          "$unsupportedPlatformDescription",
        ),
      );
    }
  }
}
