import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/user_provider.dart';
import 'package:healthcare/screens/user/folder_screen.dart';
import 'package:healthcare/services/appwrite_service.dart';
import 'package:appwrite/models.dart';
import '/constants/app_colors.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _appwriteService = AppwriteService();
  bool _isLoading = true;
  double _usedStorage = 0;
  static const double _totalStorage = 100;
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
        totalSize += file.sizeOriginal / (1024 * 1024);
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
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageCard(),
            const SizedBox(height: 30),
            _buildFolderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    final percentUsed = _usedStorage / _totalStorage;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x22000000),
            offset: Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Usage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const LinearProgressIndicator()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: percentUsed,
                    backgroundColor: Colors.grey[200],
                    color: _getStorageColor(),
                  ),
                ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_usedStorage.toStringAsFixed(1)} MB used',
                style: const TextStyle(color: Colors.grey),
              ),
              const Text(
                '100 MB total',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStorageColor() {
    final usage = _usedStorage / _totalStorage;
    if (usage > 0.9) return Colors.redAccent;
    if (usage > 0.7) return Colors.orangeAccent;
    return AppColors.primary;
  }

  Widget _buildFolderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Folders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _folders.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return _FolderCard(folder: _folders[index]);
          },
        ),
      ],
    );
  }

  final List<DocumentFolder> _folders = [
    DocumentFolder(
        name: 'Medical Records',
        icon: Icons.medical_services,
        color: Colors.blue),
    DocumentFolder(
        name: 'Prescriptions', icon: Icons.receipt_long, color: Colors.green),
    DocumentFolder(
        name: 'Test Reports', icon: Icons.analytics, color: Colors.orange),
    DocumentFolder(
        name: 'Insurance', icon: Icons.health_and_safety, color: Colors.purple),
  ];
}

class DocumentFolder {
  final String name;
  final IconData icon;
  final Color color;

  DocumentFolder({required this.name, required this.icon, required this.color});
}

class _FolderCard extends StatelessWidget {
  final DocumentFolder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FolderScreen(folderName: folder.name)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: folder.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: folder.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(folder.icon, size: 30, color: folder.color),
            ),
            const SizedBox(height: 12),
            Text(
              folder.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
