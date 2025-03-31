import 'dart:io';
import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/utils/document_handler.dart';

class DocumentUploadCard extends StatefulWidget {
  final String title;
  final String description;
  final void Function(File file) onFileSelected;
  final VoidCallback? onRemove;
  final File? initialFile;

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.description,
    required this.onFileSelected,
    this.onRemove,
    this.initialFile,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFile != null)
              _buildSelectedFile()
            else
              _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile() {
    final fileName = DocumentHandler.getFileName(_selectedFile!);
    final extension = DocumentHandler.getFileExtension(_selectedFile!);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(extension),
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  extension.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _removeFile,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
            ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);

    try {
      final file = await DocumentHandler.pickDocument();
      if (file != null) {
        setState(() => _selectedFile = file);
        widget.onFileSelected(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeFile() {
    setState(() => _selectedFile = null);
    widget.onRemove?.call();
  }
}
