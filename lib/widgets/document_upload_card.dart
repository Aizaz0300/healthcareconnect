import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '/constants/app_colors.dart';

class DocumentUploadCard extends StatelessWidget {
  final String title;
  final String? description;
  final Function(File) onFileSelected;
  final VoidCallback onRemove;
  final File? initialFile;

  const DocumentUploadCard({
    Key? key,
    required this.title,
    this.description,
    required this.onFileSelected,
    required this.onRemove,
    this.initialFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (initialFile != null)
              _buildFilePreview(initialFile!)
            else
              _buildUploadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    return Row(
      children: [
        const Icon(Icons.description, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            file.path.split('/').last,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
        ),
      ],
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return InkWell(
      onTap: () => _pickFile(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: AppColors.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Click to upload',
                style: TextStyle(
                  color: AppColors.primary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        onFileSelected(File(result.files.single.path!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }
}
