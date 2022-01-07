part of '../../msb_ekyc_id_card_detect_camera.dart';

///
/// FaceDetectController
class IdCardDetectController
    extends ValueNotifier<IdCardDetectControllerValue> {
  ///
  /// Event
  late Function(dynamic event) _idCardDetectEventHandler;
  late Function() _idCardDetectViewCreated;

  late BuildContext _context;
  late String _idCardFaceType;
  StreamSubscription<dynamic>? _eventSubscription;

  late String _viewId;

  ///
  /// Constructor.
  IdCardDetectController(
    BuildContext context,
    String idCardFaceType, {
    idCardDetectEventHandler(dynamic event)?,
    idCardDetectViewCreated()?,
  }) : super(const IdCardDetectControllerValue.uninitialized()) {
    _context = context;
    _idCardFaceType = idCardFaceType;
    _idCardDetectEventHandler = idCardDetectEventHandler ?? eventHandler;
    _idCardDetectViewCreated = idCardDetectViewCreated ?? viewCreated;
  }

  Function() get idCardDetectViewCreated => _idCardDetectViewCreated;

  bool get isStartCamera =>
      MSBEkycCameraIdCardDetectPlatform.instance.isStartCamera;
  bool get isStartCameraPreview =>
      MSBEkycCameraIdCardDetectPlatform.instance.isStartCameraPreview;

  bool get isOpenFlash =>
      MSBEkycCameraIdCardDetectPlatform.instance.isOpenFlash;

  eventHandler(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    print(
        'id_card_detect_view_event_channel event receive: ' + event.toString());
    switch (map['eventType']) {
      case 'initSuccess':
        if (value.isInitialized == null || !value.isInitialized!) {
          Future.delayed(Duration(seconds: 2), () {
            startCamera();
            startCameraPreview();
          });
          Future.delayed(Duration(seconds: 3), () {
            value = value.copyWith(isInitialized: true, onCapture: false);
          });
        }
        /*TargetPlatform platform = Theme
            .of(_context)
            .platform;
        if (TargetPlatform.iOS == platform) {
          Future.delayed(Duration(seconds: 2), () {
            startCamera();
            startCameraPreview();
          });
        } else {
          startCamera();
          startCameraPreview();
        }*/
        break;
      case 'id_card_detect_event':
        print('Dart IdCard Detect event recieved: ${event['eventData']}');
        Map<String, dynamic> eventData = json.decode(event['eventData']);
        if (eventData['status'] != null && eventData['status']) {
        } else {}
        break;
    }
  }

  viewCreated() {
    print('Dart IdCardDetectController: View created!!!');
    initCamera();
  }

  dispose() {
    super.dispose();
    _eventSubscription?.cancel();
    stopCamera();
    stopCameraPreview();
  }

  ///
  /// Init camera without open face detect.
  initCamera() async {
    _viewId = await MSBEkycCameraIdCardDetectPlatform.instance
        .initCamera(_idCardFaceType);
    print('Dart IdCard Detect Controller InitCamera respsone: ${_viewId}');
    if (_viewId.isNotEmpty) {
      _eventSubscription =
          EventChannel('id_card_detect_view_event_channel_$_viewId')
              .receiveBroadcastStream()
              .listen(_idCardDetectEventHandler);
    }
  }

  ///
  /// Start camera without open face detect,this is just open camera.
  startCamera() {
    MSBEkycCameraIdCardDetectPlatform.instance.startCamera();
  }

  ///
  /// Stop camera.
  stopCamera() async {
    MSBEkycCameraIdCardDetectPlatform.instance.stopCamera();
  }

  ///
  /// Start camera preview with open Face detect,this is open code scanner.
  startCameraPreview() async {
    MSBEkycCameraIdCardDetectPlatform.instance.startCameraPreview();
  }

  ///
  /// Stop camera preview.
  stopCameraPreview() async {
    MSBEkycCameraIdCardDetectPlatform.instance.stopCameraPreview();
  }

  ///
  /// Open camera flash.
  openFlash() async {
    MSBEkycCameraIdCardDetectPlatform.instance.openFlash();
  }

  ///
  /// Close camera flash.
  closeFlash() async {
    MSBEkycCameraIdCardDetectPlatform.instance.closeFlash();
  }

  ///
  /// Toggle camera flash.
  toggleFlash() async {
    MSBEkycCameraIdCardDetectPlatform.instance.toggleFlash();
  }

  ///
  /// Capture image.
  Future<String> captureImage() async {
    value = value.copyWith(onCapture: true);
    var result =
        await MSBEkycCameraIdCardDetectPlatform.instance.captureImage();
    if (result != null) {
      //Get captured image path
      late Map<String, dynamic> resultData;
      try {
        resultData = json.decode(result);
      } catch (ex) {
        print('idCardDetectController: error parsing result to json: ' +
            ex.toString());
      }
      print('idCardDetectController capture result: ' + result);
      value = value.copyWith(onCapture: false);

      String? idCardImage = resultData['idcard_image'];
      bool isValid = false;
      if (idCardImage != null && idCardImage.isNotEmpty) isValid = true;
      /*if (resultData['card_data'] != null) {
        if (_idCardFaceType == 'front_image') {
          String validity = resultData['card_data']['validity'];
          isValid = validity != null && validity == 'Valid';
        } else {
          String issue_date = resultData['card_data']['issue_date'];
          isValid = issue_date != null && issue_date.isNotEmpty;
        }
      }*/

      if (isValid && idCardImage != null && idCardImage.isNotEmpty) {
        return idCardImage;
      }
      return '';
    }
    return '';
  }
}

/// The state of a [IdCardDetectController].
class IdCardDetectControllerValue {
  const IdCardDetectControllerValue(
      {this.isInitialized,
      this.errorDescription,
      this.previewSize,
      this.onCapture,
      this.captureResult});

  const IdCardDetectControllerValue.uninitialized()
      : this(
          isInitialized: false,
        );

  /// True after [IdCardDetectController.initialize] has completed successfully.
  final bool? isInitialized;

  final String? errorDescription;

  /// The size of the preview in pixels.
  ///
  /// Is `null` until  [isInitialized] is `true`.
  final Size? previewSize;
  final bool? onCapture;
  final String? captureResult;

  /// Convenience getter for `previewSize.height / previewSize.width`.
  ///
  /// Can only be called when [initialize] is done.
  double get aspectRatio => previewSize!.height / previewSize!.width;

  bool get hasError => errorDescription != null;

  IdCardDetectControllerValue copyWith(
      {bool? isInitialized,
      String? errorDescription,
      Size? previewSize,
      bool? onCapture,
      String? captureResult}) {
    return IdCardDetectControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
      errorDescription: errorDescription,
      previewSize: previewSize ?? this.previewSize,
      onCapture: onCapture ?? this.onCapture,
      captureResult: captureResult ?? this.captureResult,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized, '
        'errorDescription: $errorDescription, '
        'previewSize: $previewSize, '
        'onCapture: $onCapture, '
        'captureResult: $captureResult)';
  }
}
