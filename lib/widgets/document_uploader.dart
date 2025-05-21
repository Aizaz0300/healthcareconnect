import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import 'dart:io';

class DocumentUploader extends StatelessWidget {
  final String title;
  final File? document;
  final VoidCallback onPickDocument;
  final VoidCallback? onRemove;
  final List<String> allowedExtensions;

  const DocumentUploader({
    super.key,
    required this.title,
    required this.document,
    required this.onPickDocument,
    this.onRemove,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        if (document == null)
          InkWell(
            onTap: onPickDocument,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload $title',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allowedExtensions.map((e) => e.toUpperCase()).join(', '),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              leading: Icon(
                document!.path.endsWith('.pdf')
                    ? Icons.picture_as_pdf
                    : Icons.image,
                color: AppColors.primary,
              ),
              title: Text(
                document!.path.split('/').last,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: onRemove != null
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onRemove,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
