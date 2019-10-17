
package ltd.lujing.xibao;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.alibaba.sdk.android.vod.upload.VODUploadCallback;
import com.alibaba.sdk.android.vod.upload.VODUploadClient;
import com.alibaba.sdk.android.vod.upload.VODUploadClientImpl;
import com.alibaba.sdk.android.vod.upload.model.UploadFileInfo;
import com.alibaba.sdk.android.vod.upload.model.VodInfo;

import java.io.File;
import java.util.List;
import java.util.ArrayList;

public class AliyunVod extends CordovaPlugin {

    private static int REQUEST_PERMISSION_CODE = 2;
    public static String VOD_REGION = "cn-shanghai";
    public static boolean VOD_RECORD_UPLOAD_PROGRESS_ENABLED = true;
    public static final String TAG = "AliyunVod";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.i(TAG, "execute:  " + action);

        if ("upload".equals(action)) {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
                if (!this.cordova.hasPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    this.cordova.requestPermissions(this, REQUEST_PERMISSION_CODE, new String[] {
                            Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE });
                    Log.i(TAG, "request permissions, send an error result and return true");
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, "缺少文件读写权限");
                    callbackContext.sendPluginResult(result);
                    return true;
                }
            }
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() throws JSONException {
                    final JSONArray fileArray = args.getJSONArray(0);
                    final List<VodUploadFileModel> fileList = new ArrayList<VodUploadFileModel>();
                    for (int i = 0; i < fileArray.length(); i++) {
                        final JSONObject fileObj = fileArray.getJSONObject(i);
                        final String uploadAddress = fileObj.getString("uploadAddress");
                        final String uploadAuth = fileObj.getString("uploadAuth");
                        final String videoId = fileObj.getString("videoId");
                        String filePath = fileObj.getString("filePath");
                        if (filePath != null) {
                            if (!filePath.startsWith("/")) {
                                filePath = "/" + filePath;
                            }
                        }
                        Log.i(TAG, "add model to fileList from fileArray, " + videoId + ", filePath: " + filePath);
                        final VodUploadFileModel model = new VodUploadFileModel(uploadAddress, uploadAuth, videoId,
                                filePath);
                        fileList.add(model);
                    }
                    this.startUpload(fileList, callbackContext, cordova.getContext());
                }

                private void startUpload(List<VodUploadFileModel> fileList, CallbackContext callbackContext,
                        Context context) {
                    final VODUploadClient uploader = new VODUploadClientImpl(context);
                    uploader.setRegion(VOD_REGION);
                    uploader.setRecordUploadProgressEnabled(VOD_RECORD_UPLOAD_PROGRESS_ENABLED);
                    uploader.setPartSize(1024 * 1024);
                    final VODUploadCallback callback = new VODUploadCallback() {
                        @Override
                        public void onUploadSucceed(UploadFileInfo info) {
                            final String filePath = info.getFilePath();
                            final VodUploadFileModel model = fileList.stream().filter(f -> f.isFilePath(filePath))
                                    .findFirst().orElse(VodUploadFileModel.empty);
                            final JSONObject jsonObject = new JSONObject();
                            try {
                                jsonObject.put("filePath", filePath);
                                jsonObject.put("url", info.getVodInfo().getCoverUrl());
                                jsonObject.put("videoId", model.getVideoId());
                                jsonObject.put("status", info.getStatus());
                            } catch (JSONException e) {
                                Log.i(TAG, "onUploadSucceed: json error");
                            }
                            final PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                            result.setKeepCallback(true);
                            callbackContext.sendPluginResult(result);
                        }

                        @Override
                        public void onUploadFailed(UploadFileInfo info, String code, String message) {
                            final String filePath = info.getFilePath();
                            final VodUploadFileModel model = fileList.stream().filter(f -> f.isFilePath(filePath))
                                    .findFirst().orElse(VodUploadFileModel.empty);
                            final JSONObject jsonObject = new JSONObject();
                            try {
                                jsonObject.put("filePath", filePath);
                                jsonObject.put("videoId", model.getVideoId());
                                jsonObject.put("status", info.getStatus());
                                jsonObject.put("code", info.getStatus());
                                jsonObject.put("message", info.getStatus());
                            } catch (JSONException e) {
                                Log.i(TAG, "onUploadFailed: json error");
                            }
                            final PluginResult result = new PluginResult(PluginResult.Status.ERROR, jsonObject);
                            result.setKeepCallback(true);
                            callbackContext.sendPluginResult(result);
                        }

                        @Override
                        public void onUploadProgress(UploadFileInfo info, long uploadedSize, long totalSize) {
                            final String filePath = info.getFilePath();
                            final VodUploadFileModel model = fileList.stream().filter(f -> f.isFilePath(filePath))
                                    .findFirst().orElse(VodUploadFileModel.empty);
                            Log.i(TAG, "onUploadProgress: " + filePath + "," + uploadedSize + "/" + totalSize);
                            final JSONObject jsonObject = new JSONObject();
                            try {
                                jsonObject.put("filePath", filePath);
                                jsonObject.put("videoId", model.getVideoId());
                                jsonObject.put("uploadedSize", uploadedSize);
                                jsonObject.put("totalSize", totalSize);
                                jsonObject.put("status", info.getStatus());
                            } catch (JSONException e) {
                                Log.i(TAG, "onUploadProgress: json error");
                            }
                            final PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObject);
                            result.setKeepCallback(true);
                            callbackContext.sendPluginResult(result);
                        }

                        @Override
                        public void onUploadTokenExpired() {
                            Log.i(TAG, "onUploadTokenExpired");
                        }

                        @Override
                        public void onUploadRetry(String code, String message) {
                            Log.i(TAG, "onUploadRetry: " + code + "," + message);
                        }

                        @Override
                        public void onUploadRetryResume() {
                            Log.i(TAG, "onUploadRetryResume");
                        }

                        @Override
                        public void onUploadStarted(UploadFileInfo info) {
                            final String filePath = info.getFilePath();
                            Log.i(TAG, "onUploadStarted:  " + filePath);
                            final VodUploadFileModel model = fileList.stream().filter(f -> f.isFilePath(filePath))
                                    .findFirst().orElse(VodUploadFileModel.empty);
                            Log.i(TAG, "onUploadStarted: auth:" + model.getUploadAuth() + " , addr: "
                                    + model.getUploadAddress());
                            uploader.setUploadAuthAndAddress(info, model.getUploadAuth(), model.getUploadAddress());
                        }
                    };
                    Log.i(TAG, "call uploader.init");
                    uploader.init(callback);
                    Log.i(TAG, "call uploader.setPartSize");
                    uploader.setPartSize(1024 * 1024);
                    for (VodUploadFileModel model : fileList) {
                        final VodInfo vodInfo = new VodInfo();
                        vodInfo.setIsProcess(true);
                        Log.i(TAG, "call uploader.addFile, filePath: " + model.getFilePath());
                        uploader.addFile(model.getFilePath(), vodInfo);
                    }
                    Log.i(TAG, "call uploader.start");
                    uploader.start();
                }
            });
            return true;
        }
        return false;
    }
}