package ltd.lujing.xibao;

public final class VodUploadFileModel {
    private String uploadAddress;
    private String uploadAuth;
    private String videoId;
    private String filePath;

    public VodUploadFileModel(String uploadAddress, String uploadAuth, String videoId, String filePath) {
        this.uploadAddress = uploadAddress;
        this.uploadAuth = uploadAuth;
        this.videoId = videoId;
        this.filePath = filePath;
    }

    public String getUploadAddress() {
        return uploadAddress;
    }

    public String getUploadAuth() {
        return uploadAuth;
    }

    public String getVideoId() {
        return videoId;
    }

    public String getFilePath() {
        return filePath;
    }

    public Boolean isFilePath(String path) {
        if (this.filePath == null || path == null) {
            return false;
        }
        return this.filePath.equals(path);
    }

    public static final VodUploadFileModel empty = new VodUploadFileModel("empty", "empty", "empty", "empty");
}