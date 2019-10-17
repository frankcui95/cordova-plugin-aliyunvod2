#import "AliyunVod.h"
#import <VODUpload/VODUploadClient.h>

@implementation AliyunVod

- (void)upload:(CDVInvokedUrlCommand *)command {
  NSArray *files = [command.arguments firstObject];
  if (!files) {
    return;
  }
  // 是个文件信息的数组 可能有多个文件
  NSLog(files);
  // 初始化阿里云sdk
  VODUploadClient *uploader = [VODUploadClient new];

  [files enumerateObjectsUsingBlock:^(NSDictionary *file, NSUInteger index,
                                      BOOL *stop) {
    NSLog(file);
    NSString *filePath = file[@"filePath"];
    VodInfo *vodInfo = [[VodInfo alloc] init];
    [uploader addFile:filePath vodInfo:vodInfo];
  }];
  __weak NSArray *weakFiles = files;
  __weak VODUploadClient *weakUploader = uploader;

  OnUploadFinishedListener finishCallbackFunc =
      ^(UploadFileInfo *fileInfo, VodUploadResult *result) {
        NSString *theVideoId = nil;
        [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                                NSUInteger index, BOOL *stop) {
          NSString *theFilePath = file[@"filePath"];
          if ([theFilePath isEqualToString:fileInfo.filePath]) {
            theVideoId = file[@"videoId"];
            *stop = YES;
          }
        }];
        NSMutableDictionary model = [@{
          @"filePath" : fileInfo.filePath,
          @"status" : fileInfo.state,
          @"url" : result.imageUrl,
          @"videoId" : theVideoId,
        } mutableCopy];
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsDictionary:model];
        [result setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:result
                                    callbackId:command.callbackId];
      };

  OnUploadFailedListener failedCallbackFunc =
      ^(UploadFileInfo *fileInfo, NSString *code, NSString *message) {
        NSLog(@"failed code = %@, error message = %@", code, message);
        NSString *theVideoId = nil;
        [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                                NSUInteger index, BOOL *stop) {
          NSString *theFilePath = file[@"filePath"];
          if ([theFilePath isEqualToString:fileInfo.filePath]) {
            theVideoId = file[@"videoId"];
            *stop = YES;
          }
        }];
        NSMutableDictionary model = [@{
          @"filePath" : fileInfo.filePath,
          @"status" : fileInfo.state,
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
  OnUploadProgressListener progressCallbackFunc =
      ^(UploadFileInfo *fileInfo, long uploadedSize, long totalSize) {
        NSString *theVideoId = nil;
        [weakFiles enumerateObjectsUsingBlock:^(NSDictionary *file,
                                                NSUInteger index, BOOL *stop) {
          NSString *theFilePath = file[@"filePath"];
          if ([theFilePath isEqualToString:fileInfo.filePath]) {
            theVideoId = file[@"videoId"];
            *stop = YES;
          }
        }];
        NSMutableDictionary model = [@{
          @"filePath" : fileInfo.filePath,
          @"status" : fileInfo.state,
          @"videoId" : theVideoId,
          @"uploadedSize" : uploadedSize,
          @"totalSize" : totalSize,
        } mutableCopy];
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsDictionary:model];
        [result setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:result
                                    callbackId:command.callbackId];
      };
  OnUploadStartedListener uploadStartedCallbackFunc =
      ^(UploadFileInfo *fileInfo) {
        NSString *theVideoId = nil;
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
  VODUploadListener *listener = [[VODUploadListener alloc] init];
  listener.finish = finishCallbackFunc;
  listener.failure = failedCallbackFunc;
  listener.progress = progressCallbackFunc;
  listener.started = uploadStartedCallbackFunc;
  [uploader setListener:listener];
  [uploader start];
}

@end