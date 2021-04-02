import 'package:flutter/services.dart';

///
/// Channel
const MethodChannel _methodChannelIdCardDetect =
    MethodChannel("id_card_detect_view_method_channel");

const EventChannel _eventChannelIdCardDetect =
      EventChannel("id_card_detect_view_event_channel");

/// View id widget
const String _viewIdOfIdCardDetect= "id_card_detect_view";


///MSBEkycCameraPlatform
///
abstract class MSBEkycIdCardDetectCameraPlatform {
  ///
  /// MethodChannel
  static MethodChannel get methodChannelIdCardDetect => _methodChannelIdCardDetect;

  ///
  /// EventChannel
  static EventChannel get eventChannelIdCardDetect => _eventChannelIdCardDetect;

  ///
  /// ViewId detect widget
  static String get viewIdOfIdCardDetect => _viewIdOfIdCardDetect;
}
