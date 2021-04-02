package com.msb.msb_ekyc_id_card_detect_camera;

import android.content.Context;
import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.view.LayoutInflater;
import android.Manifest;
import android.os.CountDownTimer;
import android.util.Log;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;
import com.karumi.dexter.listener.single.PermissionListener;

import com.google.gson.Gson;
import com.otaliastudios.cameraview.CameraView;
import com.tst.ocr_module.Events.OcrEvents;
import com.tst.ocr_module.OcrManager;
import com.tst.ocr_module.OverlayView;
import org.json.JSONObject;
import android.graphics.Bitmap;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import butterknife.BindView;
import butterknife.ButterKnife;

public class AndroidIdCardDetectView implements PlatformView, MethodCallHandler, OcrEvents {

    private static final String TAG = "AndroidIdCardDetectView";

    private int viewId;
    private Context context;

    private Activity activity;
    private BinaryMessenger binaryMessenger;
    private View view;
    private MethodChannel channel;
    private boolean channelReady = false;
    private boolean permisstionGranted = false;
    private boolean onCapture = false;
    MethodChannel.Result captureResult;


    OcrManager ocrManager;

    @BindView(R2.id.cameraPreview)
    CameraView cameraPreview;

    @BindView(R2.id.overlay)
    OverlayView overlayView;

    private static Gson gson  = new Gson();

    @Nullable private EventChannel.EventSink eventSink;

    AndroidIdCardDetectView(Context context, Activity activity, BinaryMessenger binaryMessenger, int id) {
        this.context = context;
        this.activity = activity;
        this.binaryMessenger = binaryMessenger;
        this.viewId = id;
        this.view = LayoutInflater.from(activity).inflate(R.layout.ocr_preview, null);
        this.channelReady = false;
        this.permisstionGranted = false;

        ButterKnife.bind(this, view);

        channel = new MethodChannel(binaryMessenger, "id_card_detect_view_method_channel");
        channel.setMethodCallHandler(this);

        HardwarePermissionCheck();
    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.i(TAG, "onMethodCall " + call.method);
        switch (call.method) {
            case "initCamera":
                String idCardFaceType = call.argument("idCardFaceType");
                Log.i(TAG, "initCamera-idCardFaceType: " + idCardFaceType);
                // init ekyc id card orc
                ocrManager = new OcrManager(activity, cameraPreview, overlayView, this, idCardFaceType);
                init();
                result.success(String.valueOf(viewId));
                break;
            case "startCamera":
                ocrManager.startCamera();
                break;
            case "stopCamera":
                ocrManager.stopCamera();
                break;
            case "resumeCameraPreview":
                break;
            case "stopCameraPreview":
                break;
            case "openFlash":
                break;
            case "closeFlash":
                break;
            case "toggleFlash":
                break;
            case "captureImage":
                capture(result);
                break;
            default:
                result.notImplemented();
        }
    }

    /*
    @Override
    protected void onResume() {
        super.onResume();
        ocrManager.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        ocrManager.onPause();
    }*/

    @Override
    public void dispose() {
        channelReady = false;
        permisstionGranted = false;
    }

    /**
     * camera & audio permissions
     */
    private void HardwarePermissionCheck() {
        Dexter.withContext(context)
                .withPermissions(Manifest.permission.CAMERA/*,Manifest.permission.RECORD_AUDIO*/)
                .withListener(new MultiplePermissionsListener() {
                    @Override
                    public void onPermissionsChecked(MultiplePermissionsReport multiplePermissionsReport) {
                        if (multiplePermissionsReport.areAllPermissionsGranted()){
                            Log.i(TAG, "All permission granted!");
                            permisstionGranted = true;
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(List<PermissionRequest> list, PermissionToken permissionToken) {

                    }
                }).check();
    }

    /**
     * waiting init event channel
     */
    private CountDownTimer initTimer;
    private void init() {
        Log.i(TAG, "init() viewId: " + viewId);
        new EventChannel(binaryMessenger, "id_card_detect_view_event_channel_" + viewId)
                .setStreamHandler(
                        new EventChannel.StreamHandler() {
                            @Override
                            public void onListen(Object arguments, EventChannel.EventSink sink) {
                                eventSink = sink;
                                channelReady = true;
                                Log.i(TAG, "Create event stream success! onListen");
                            }

                            @Override
                            public void onCancel(Object arguments) {
                                eventSink = null;
                            }
                        });
        initTimer = new CountDownTimer(5*1000, 1000L) {
            public void onTick(long millisUntilFinished) {
                Log.i(TAG, "initTimer Ontick" + channelReady + permisstionGranted);
                if (channelReady && permisstionGranted) {
                    initSuccess();
                }
            }

            public void onFinish() {
            }
        };
        initTimer.start();
    }

    private void initSuccess () {
        initTimer.cancel();
        //String jsonString = gson.toJson(detectionParams.getGestureList());
        //Log.i(TAG,"Gesture list json: " + jsonString);
        Map<String, Object> event = new HashMap<>();
        event.put("eventType", "initSuccess");
        //event.put("eventData", jsonString);
        sendEventToDart("initSuccess", null);
    }

    public void capture(MethodChannel.Result result) {
        Log.i(TAG, "capture: onCapture" + onCapture);
        if (ocrManager != null && !onCapture) {
            onCapture = true;
            captureResult = result;
            Log.i(TAG, "capture: call ocrManager.capture()");
            ocrManager.capture();
        }
    }

    @Override
    public void OnCaptured(Bitmap image) {
        if (image != null) {
            Log.i(TAG, image.toString());
        }
    }

    @Override
    public void OnOcrProcessCompleted(JSONObject ocr_data) {
        Log.i(TAG, ocr_data.toString().replace("\\", ""));
        onCapture = false;
        if (captureResult != null) {
            captureResult.success(ocr_data.toString().replace("\\", ""));
            captureResult = null;
        }
    }

    void sendEventToDart(String eventType, @Nullable String eventData) {
        if (eventSink == null) {
            Log.e(TAG,"Send event fail: eventType: " + eventType + " event channel not ready!");
            return;
        }

        Map<String, String> event = new HashMap<>();
        event.put("eventType", eventType);
        if (!TextUtils.isEmpty(eventData)) {
            event.put("eventData", eventData);
        }
        eventSink.success(event);
    }
}