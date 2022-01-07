part of '../../msb_ekyc_id_card_detect_camera.dart';

///
/// IdCardDetectWidget
///
/// Supported android and ios platform face detect
// ignore: must_be_immutable
class IdCardDetectWidget extends StatefulWidget {
  ///
  /// Controller.
  IdCardDetectController? _idCardDetectController;

  ///
  /// UnsupportedDescription
  String? _unsupportedDescription;

  ///
  /// Constructor.
  IdCardDetectWidget({
    required IdCardDetectController idCardDetectController,
    String? unsupportedDescription,
  }) {
    _idCardDetectController = idCardDetectController;
    _unsupportedDescription = unsupportedDescription;
  }

  @override
  State<StatefulWidget> createState() {
    return _IdCardDetectWidgetState();
  }
}

///
/// _FaceDetectWidgetState
class _IdCardDetectWidgetState extends State<IdCardDetectWidget> {
  @override
  void initState() {
    super.initState();
    //Create
    MSBEkycCameraIdCardDetectPlatform.instance
        .addListener(_widgetCreatedListener);
    MSBEkycCameraIdCardDetectPlatform.instance.unsupportedPlatformDescription =
        widget._unsupportedDescription ?? "";
  }

  ///
  /// CreatedListener.
  _widgetCreatedListener() {
    if (widget._idCardDetectController != null) {
      if (widget._idCardDetectController?._idCardDetectViewCreated != null) {
        widget._idCardDetectController?._idCardDetectViewCreated();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    //Release
    MSBEkycCameraIdCardDetectPlatform.instance
        .removeListener(_widgetCreatedListener);
    widget._idCardDetectController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MSBEkycCameraIdCardDetectPlatform.instance
        .buildIdCardDetectView(context);
  }
}
