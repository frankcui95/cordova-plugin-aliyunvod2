#import "AliyunVod.h"
#import <VODUpload/VODUploadClient.h>

@implementation AliyunVod

- (void)upload:(CDVInvokedUrlCommand *)command {
  NSLog(@"AliyunVod call upload %@", command.callbackId);
  NSArray *files = [command.arguments firstObject];
  if (!files) {
    NSLog(@"AliyunVod no files %@", command.callbackId);
    CDVPluginResult *result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                          messageAsString:@"no files"];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
    return;
  }
  // 是个文件信息的数组 可能有多个文件
  // 初始化阿里云sdk
  NSLog(@"AliyunVod new uploader %@", command.callbackId);
  VODUploadClient *uploader = [VODUploadClient new];
  NSLog(@"AliyunVod add files %@", command.callbackId);
  [files enumerateObjectsUsingBlock:^(NSDictionary *file, NSUInteger index,
                                      BOOL *stop) {
    NSString *filePath = file[@"filePath"];
    NSLog(@"AliyunVod add file %@ path =  %@", command.callbackId, filePath);
    if (filePath == nil) {
      *stop = YES;
      CDVPluginResult *result =
          [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                            messageAsString:@"at least one filePath is null"];
      [self.commandDelegate sendPluginResult:result

                                  callbackId:command.callbackId];
      return;
    }
    VodInfo *vodInfo = [[VodInfo alloc] init];
    [uploader addFile:filePath vodInfo:vodInfo];
  }];
  __weak NSArray *weakFiles = files;
  __weak VODUploadClient *weakUploader = uploader;
  NSLog(@"AliyunVod define finishCallbackFunc %@", command.callbackId);
  OnUploadFinishedListener finishCallbackFunc = ^(UploadFileInfo *fileInfo,
                                                  VodUploadResult *result) {
    NSLog(@"AliyunVod callback finishCallbackFunc %@", command.callbackId);
    __block NSString *theVideoId = nil;
    [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                            NSUInteger index, BOOL *stop) {
      NSString *theFilePath = file[@"filePath"];
      if ([theFilePath isEqualToString:fileInfo.filePath]) {
        theVideoId = file[@"videoId"];
        *stop = YES;
      }
    }];
    NSString *statusStr = [[NSString alloc] init];
    switch (fileInfo.state) {
    case VODUploadFileStatusUploading:
      statusStr = @"UPLOADING";
      break;
    case VODUploadFileStatusSuccess:
      statusStr = @"SUCCESS";
      break;
    case VODUploadFileStatusReady:
      statusStr = @"READY";
      break;
    case VODUploadFileStatusPaused:
      statusStr = @"PAUSED";
      break;
    case VODUploadFileStatusFailure:
      statusStr = @"FAIlURE";
      break;
    case VODUploadFileStatusCanceled:
      statusStr = @"CANCELED";
      break;
    default:
      break;
    }
    NSLog(
        @"AliyunVod callback finishCallbackFunc %@ video id = %@ imageUrl = %@",
        command.callbackId, theVideoId, result.imageUrl);
    NSMutableDictionary *model = [@{
      @"filePath" : fileInfo.filePath,
      @"status" : statusStr,
      @"url" : result.imageUrl,
      @"videoId" : theVideoId,
    } mutableCopy];
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                      messageAsDictionary:model];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
  };
  NSLog(@"AliyunVod define failedCallbackFunc %@", command.callbackId);
  OnUploadFailedListener failedCallbackFunc =
      ^(UploadFileInfo *fileInfo, NSString *code, NSString *message) {
        NSLog(@"AliyunVod callback failedCallbackFunc %@ code = %@, error "
              @"message = %@",
              command.callbackId, code, message);
        __block NSString *theVideoId = nil;
        [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                                NSUInteger index, BOOL *stop) {
          NSString *theFilePath = file[@"filePath"];
          if ([theFilePath isEqualToString:fileInfo.filePath]) {
            theVideoId = [file[@"videoId"] stringValue];
            *stop = YES;
          }
        }];
        NSString *statusStr = [[NSString alloc] init];
        switch (fileInfo.state) {
        case VODUploadFileStatusUploading:
          statusStr = @"UPLOADING";
          break;
        case VODUploadFileStatusSuccess:
          statusStr = @"SUCCESS";
          break;
        case VODUploadFileStatusReady:
          statusStr = @"READY";
          break;
        case VODUploadFileStatusPaused:
          statusStr = @"PAUSED";
          break;
        case VODUploadFileStatusFailure:
          statusStr = @"FAIlURE";
          break;
        case VODUploadFileStatusCanceled:
          statusStr = @"CANCELED";
          break;
        default:
          break;
        }
        NSMutableDictionary *model = [@{
          @"filePath" : fileInfo.filePath,
          @"status" : statusStr,
          @"videoId" : theVideoId,
          @"code" : code,
          @"message" : message,
        } mutableCopy];
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                          messageAsDictionary:model];
        [result setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:result
                                    callbackId:command.callbackId];
      };
  NSLog(@"AliyunVod define progressCallbackFunc %@", command.callbackId);
  OnUploadProgressListener progressCallbackFunc = ^(
      UploadFileInfo *fileInfo, long uploadedSize, long totalSize) {
    NSLog(@"AliyunVod callback progressCallbackFunc %@", command.callbackId);
    __block NSString *theVideoId = nil;
    [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                            NSUInteger index, BOOL *stop) {
      NSString *theFilePath = file[@"filePath"];
      if ([theFilePath isEqualToString:fileInfo.filePath]) {
        theVideoId = file[@"videoId"];
        *stop = YES;
      }
    }];
    NSString *statusStr = [[NSString alloc] init];
    switch (fileInfo.state) {
    case VODUploadFileStatusUploading:
      statusStr = @"UPLOADING";
      break;
    case VODUploadFileStatusSuccess:
      statusStr = @"SUCCESS";
      break;
    case VODUploadFileStatusReady:
      statusStr = @"READY";
      break;
    case VODUploadFileStatusPaused:
      statusStr = @"PAUSED";
      break;
    case VODUploadFileStatusFailure:
      statusStr = @"FAIlURE";
      break;
    case VODUploadFileStatusCanceled:
      statusStr = @"CANCELED";
      break;
    default:
      break;
    }
    NSMutableDictionary *model = [@{
      @"filePath" : fileInfo.filePath,
      @"status" : statusStr,
      @"videoId" : theVideoId,
      @"uploadedSize" : [NSNumber numberWithLong:uploadedSize],
      @"totalSize" : [NSNumber numberWithLong:totalSize],
    } mutableCopy];
    CDVPluginResult *result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                      messageAsDictionary:model];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
  };
  NSLog(@"AliyunVod define uploadStartedCallbackFunc %@", command.callbackId);
  OnUploadStartedListener uploadStartedCallbackFunc =
      ^(UploadFileInfo *fileInfo) {
        NSLog(@"AliyunVod callback uploadStartedCallbackFunc %@", command.callbackId);
        [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                                NSUInteger index, BOOL *stop) {
          NSString *theFilePath = file[@"filePath"];
          if ([theFilePath isEqualToString:fileInfo.filePath]) {
            NSString *uploadAuth = file[@"uploadAuth"];
            NSString *uploadAddress = file[@"uploadAddress"];
            [weakUploader setUploadAuthAndAddress:fileInfo
                                       uploadAuth:uploadAuth
                                    uploadAddress:uploadAddress];
            *stop = YES;
          }
        }];
      };
  NSLog(@"AliyunVod new listener %@", command.callbackId);
  VODUploadListener *listener = [[VODUploadListener alloc] init];
  listener.finish = finishCallbackFunc;
  listener.failure = failedCallbackFunc;
  listener.progress = progressCallbackFunc;
  listener.started = uploadStartedCallbackFunc;
  NSLog(@"AliyunVod set listener %@", command.callbackId);
  [uploader setListener:listener];
  NSLog(@"AliyunVod start %@", command.callbackId);
  [uploader start];
}

@end
