# msb_ekyc_id_card_detect_camera
## LICENSE
    BSD 3-Clause License
    
    Copyright (c) 2020, topebox
    All rights reserved.

Step 1: Add dependence to flutter pubspec.yaml:
    	...
    	msb_ekyc_id_card_detect_camera:
    		path: ./msb_ekyc_id_card_detect_camera
    	...

Step 2: import 'package:msb_ekyc_id_card_detect_camera/msb_ekyc_id_card_detect_camera.dart';

Step 3: Declare controller: IdCardDetectController _idCardDetectController;

Step 4: Init camera + listening events
              Future<void> _initializeCamera() async {
                  startLoading();
                  _idCardDetectController = IdCardDetectController(context, 'front_image');
                  _idCardDetectController.addListener(() async {
                    if (_idCardDetectController.value.hasError) {
                      debugPrint(
                          'Camera error ${_idCardDetectController.value.errorDescription}');
                    }
                    if (_idCardDetectController.value.isInitialized != isCameraReady) {
                      isCameraReady = _idCardDetectController.value.isInitialized;
                      stopLoading();
                    }
                  });
                }

Step 5:  Using widget IdCardDetectWidget with controller to draw to screen
            ...
            IdCardDetectWidget(idCardDetectController: _idCardDetectController)
            ...

*** NOTE: + Need CAMERA_PERMISSION granted before calling IdCardDetectWidget

