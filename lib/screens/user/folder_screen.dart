import 'dart:math';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:healthcare/constants/api_constants.dart';
import 'package:healthcare/screens/user/pdf_viewer_page.dart';
import 'package:healthcare/services/pdf_download.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../services/appwrite_auth_service.dart';
import '../../providers/user_provider.dart';
import '/constants/app_colors.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;

  const FolderScreen({super.key, required this.folderName});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<File> _files = [];
  bool _isLoading = true;
  bool _isUploading = false;
  late String _userId;

  final _appwriteService = AppwriteService();

  final Set<String> _allowedExtensions = {
    'pdf',
    'jpg',    // JPEG image
    'jpeg',   // JPEG image (alternative)
    'png',    // Portable Network Graphics
    'gif',    // Graphics Interchange Format
    'bmp',    // Bitmap Image File
    'webp',   // WebP image format
    'tiff',   // Tagged Image File Format
    'svg',    // Scalable Vector Graphics
    'ico',    // Icon file format
    'heif',   // High Efficiency Image Format (used by Apple)
    'heic',   // High Efficiency Image Coding (Apple's photo format)
  };

  final Set<String> _allowedMimeTypes = {
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/gif',
  };

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    _loadFiles();
  }

  String _truncateFileName(String fileName) {
    if (fileName.length > 30) {
      return fileName.substring(0, 30);
    } else {
      return fileName;
    }
  }

  List<File> cleanFileNames(List<File> files, String prefix) {
    final RegExp numericPrefixPattern = RegExp(r'^\d+_');
    return files.map((file) {
      String newName = file.name.replaceFirst(prefix, '');
      newName = newName.replaceFirst(numericPrefixPattern, '');
      return File(
        $id: file.$id,
        bucketId: file.bucketId,
        $createdAt: file.$createdAt,
        $updatedAt: file.$updatedAt,
        $permissions: file.$permissions,
        name: newName,
        signature: file.signature,
        mimeType: file.mimeType,
        sizeOriginal: file.sizeOriginal,
        chunksTotal: file.chunksTotal,
        chunksUploaded: file.chunksUploaded,
      );
    }).toList();
  }

  Future<void> _loadFiles() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final FileList fileList =
          await _appwriteService.getFilesByCategory(_userId, widget.folderName);
      final updatedFiles =
          cleanFileNames(fileList.files, '$_userId/${widget.folderName}/');
      setState(() {
        _files = updatedFiles;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading files: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidFile(String path, String? mimeType) {
    final extension = path.split('.').last.toLowerCase();
    return _allowedExtensions.contains(extension) ||
        (mimeType != null && _allowedMimeTypes.contains(mimeType));
  }

  Future<void> _uploadFile(String path) async {
    if (!_isValidFile(path, null)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Only PDF and image files are allowed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_userId.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      await _appwriteService.uploadFile(
        _userId,
        widget.folderName,
        path,
      );
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _selectAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadFile(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _selectAndUploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        await _uploadFile(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Upload from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _selectAndUploadImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              _selectAndUploadImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_present),
            title: const Text('Upload Document'),
            onTap: () {
              Navigator.pop(context);
              _selectAndUploadDocument();
            },
          ),
        ],
      ),
    );
  }

  void _showFileOptions(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.remove_red_eye),
            title: const Text('View'),
            onTap: () {
              Navigator.pop(context);
              _viewFile(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _deleteFile(file);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    try {
      await _appwriteService.deleteFile(file.$id);
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file: $e')),
        );
      }
    }
  }

  Future<void> _viewFile(File file) async {
    try {
      final url =
          '${ApiConstants.endPoint}/storage/buckets/${file.bucketId}/files/${file.$id}/view?project=${ApiConstants.projectId}';

      if (file.mimeType?.startsWith('image/') ?? false) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: PhotoView(
                imageProvider: NetworkImage(url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ),
        );
      } else if (file.mimeType == 'application/pdf') {
        
        final localFile = await downloadFile(url, file.name);
      // Navigate to the PDF viewer page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfFile: localFile,
            fileName: file.name,
          ),
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported file type')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error viewing file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to access files'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Text(
                    'No files in ${widget.folderName}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getFileIcon(file.mimeType ?? ''),
                          color: AppColors.primary,
                        ),
                        title: Text(
                          _truncateFileName(file.name),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_formatFileSize(file.sizeOriginal)),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showFileOptions(file),
                        ),
                        onTap: () => _viewFile(file),
                      ),
                    );
                  },
                ),
      floatingActionButton: _isUploading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FloatingActionButton(
              onPressed: _showUploadOptions,
              child: const Icon(Icons.add),
            ),
    );
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    }
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
