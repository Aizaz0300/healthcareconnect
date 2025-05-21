import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/providers/user_provider.dart';
import 'package:healthcare/screens/user/folder_screen.dart';
import 'package:healthcare/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '/constants/app_colors.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _appwriteService = AppwriteService();
  bool _isLoading = true;
  double _usedStorage = 0; // in MB
  static const double _totalStorage = 100; // 100 MB total storage
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final FileList fileList = await _appwriteService.getFilesByUser(_userId);
      double totalSize = 0;
      for (var file in fileList.files) {
        totalSize += file.sizeOriginal / (1024 * 1024); // Convert bytes to MB
      }

      setState(() {
        _usedStorage = totalSize;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading storage info: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageInfo(),
            const SizedBox(height: 24),
            _buildFolders(),
            const SizedBox(height: 24),
            _buildRecentFiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Used',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const LinearProgressIndicator()
                : LinearProgressIndicator(
                    value: _usedStorage / _totalStorage,
                    backgroundColor: Colors.grey[200],
                    color: _getStorageColor(),
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_usedStorage.toStringAsFixed(1)} MB used',
                  style: const TextStyle(color: AppColors.textLight),
                ),
                const Text(
                  '100 MB total',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStorageColor() {
    final percentage = _usedStorage / _totalStorage;
    if (percentage > 0.9) {
      return Colors.red;
    } else if (percentage > 0.7) {
      return Colors.orange;
    }
    return AppColors.primary;
  }

  Widget _buildFolders() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Folders',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return _FolderCard(folder: folder);
        },
      ),
    ],
  );
}


  Widget _buildRecentFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Files',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentFiles.length,
          itemBuilder: (context, index) {
            final file = _recentFiles[index];
            return _FileListItem(file: file);
          },
        ),
      ],
    );
  }

  final List<DocumentFolder> _folders = [
    DocumentFolder(
      name: 'Medical Records',
      icon: Icons.medical_information,
      count: 12,
      color: Colors.blue,
    ),
    DocumentFolder(
      name: 'Prescriptions',
      icon: Icons.receipt_long,
      count: 8,
      color: Colors.green,
    ),
    DocumentFolder(
      name: 'Test Reports',
      icon: Icons.analytics,
      count: 5,
      color: Colors.orange,
    ),
    DocumentFolder(
      name: 'Insurance',
      icon: Icons.health_and_safety,
      count: 3,
      color: Colors.purple,
    ),
  ];

  final List<DocumentFile> _recentFiles = [
    DocumentFile(
      name: 'Blood Test Report.pdf',
      size: '2.4 MB',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'PDF',
    ),
    DocumentFile(
      name: 'X-Ray Scan.jpg',
      size: '5.1 MB',
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: 'Image',
    ),
    // Add more recent files
  ];
}

class DocumentFolder {
  final String name;
  final IconData icon;
  final int count;
  final Color color;

  DocumentFolder({
    required this.name,
    required this.icon,
    required this.count,
    required this.color,
  });
}

class DocumentFile {
  final String name;
  final String size;
  final DateTime date;
  final String type;

  DocumentFile({
    required this.name,
    required this.size,
    required this.date,
    required this.type,
  });
}

class _FolderCard extends StatelessWidget {
  final DocumentFolder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderScreen(
                folderName: folder.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: folder.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  folder.icon,
                  size: 50,
                  color: folder.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                folder.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  final DocumentFile file;

  const _FileListItem({required this.file});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileIcon(file.type),
            color: AppColors.primary,
          ),
        ),
        title: Text(file.name),
        subtitle: Text(
          '${file.size} • ${_formatDate(file.date)}',
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showFileOptions(context),
        ),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFileOptions(BuildContext context) {
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
              // TODO: Implement file view
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement file sharing
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement file deletion
            },
          ),
        ],
      ),
    );
  }
}
