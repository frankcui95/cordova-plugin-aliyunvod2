# 简单使用方式

```javascript
aliyunvod.upload(
    [{
        uploadAddress :"CreateUploadVideo接口返回给你的同名参数",
        uploadAuth :"服务返回给你的同名参数",
        videoId :"服务返回给你的同名参数",
        filePath : "你拿到的文件路径"
    }],
    function(obj){
     //成功之后
     console.dir(obj);
     // 安卓的状态是这样，ios的不知道
     // obj.status是SUCCESS是传完了
     // obj.status应该是有个UPLOADING代表上传中 上传中有uploadedSize和totalSize写进度条
     // obj.status是FAILED 有obj.code有obj.message
}, function(message){
    // message没有安卓读写外置存储权限时是个字符串错误信息 或者是个上传失败的描述Object
});
```
