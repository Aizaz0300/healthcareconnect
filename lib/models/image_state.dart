import 'dart:io';

class ImageState {
  final String? remoteUrl;
  final File? localFile;
  final bool isDeleted;

  ImageState({
    this.remoteUrl,
    this.localFile,
    this.isDeleted = false,
  });

  bool get isLocal => localFile != null;
  bool get hasImage => localFile != null || (remoteUrl != null && !isDeleted);
  String? get displayUrl => remoteUrl;
  File? get uploadFile => localFile;

  ImageState markDeleted() {
    return ImageState(
      remoteUrl: remoteUrl,
      localFile: localFile,
      isDeleted: true,
    );
  }

  ImageState withLocalFile(File file) {
    return ImageState(
      remoteUrl: remoteUrl,
      localFile: file,
      isDeleted: false,
    );
  }
}
