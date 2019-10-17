
var exec = require('cordova/exec');

var aliyunvod = {};
aliyunvod.upload = function (files, success, error) {
    success = success || function (obj) { console.dir(obj); };
    error = error || function (message) { console.log(message); };
    files = files || [];
    if (!files) {
        throw "待上传的文件列表对象无效";
    }
    if (!Array.isArray(files)) {
        throw "待上传的文件列表不是一个数组";
    }
    if (![].every.call(files, function (e) { return (!!e) && typeof e === 'object'; })) {
        throw "待上传的文件列表元素类型无效";
    }
    if (files.length === 0) {
        throw "待上传的文件列表是空的";
    }
    return exec(success, error, "aliyunvod", "upload", [files]);
};
module.exports = aliyunvod;