import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthcare/models/image_state.dart';
import 'package:healthcare/services/appwrite_provider_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/constants/app_colors.dart';
import '/models/service_provider.dart';
import '/providers/service_provider_provider.dart';
import 'dart:convert';
import 'package:healthcare/screens/auth/provider/provider_login_screen.dart';

class EditProviderProfileScreen extends StatefulWidget {
  final ServiceProvider provider;

  const EditProviderProfileScreen({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ServiceProviderProvider _providerProvider;
  bool _isEditing = false;
  bool _isLoading = false;

  // Controllers
  final _appwriteProviderService = AppwriteProviderService();
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _addressController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _issuingAuthorityController;
  late final TextEditingController _hourlyRateController;

  // Data
  String? _profileImageUrl;
  String? _profileImagePath;
  File? _profileImageFile;
  File? _licenseImage;
  String? _licenseImagePath;
  
  List<String> _services = [];
  List<ImageState> _gallery = [];
  List<ImageState> _certifications = [];
  

  @override
  void initState() {
    super.initState();
    _providerProvider = context.read<ServiceProviderProvider>();
    _initializeData();
  }

  void _initializeData() {
    // Initialize controllers
    _nameController = TextEditingController(text: widget.provider.name);
    _aboutController = TextEditingController(text: widget.provider.about);
    _addressController = TextEditingController(text: widget.provider.address);
    _licenseNumberController = TextEditingController(text: widget.provider.licenseInfo.licenseNumber);
    _issuingAuthorityController = TextEditingController(text: widget.provider.licenseInfo.issuingAuthority);
    _hourlyRateController = TextEditingController(text: widget.provider.hourlyRate.toString());

    // Initialize data
    _profileImageUrl = widget.provider.imageUrl;
    _services = List.from(widget.provider.services);
    _gallery = widget.provider.gallery
        .map((url) => ImageState(remoteUrl: url))
        .toList();
    _certifications = widget.provider.certifications
        .map((url) => ImageState(remoteUrl: url))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _issuingAuthorityController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
        _profileImageFile = File(image.path);
      });
    }
  }

  Future<void> _pickLicenseImage() async {
    // Show warning dialog first
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
          'Uploading a new license image will replace the existing one and cannot be recovered. Are you sure you want to continue?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('PROCEED'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _licenseImagePath = image.path;
          _licenseImage = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New license image selected')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick license image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final providerId = widget.provider.id;
      String? profileImageUrl;
      String? licenseImageUrl;
      List<String> updatedCertifications = [];
      List<String> updatedGallery = [];

      // Upload profile image
      try {
        if (_profileImagePath != null) {
          profileImageUrl = await _appwriteProviderService.uploadFileforURL(
            _profileImagePath!,
            'profile_images'
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile image: $e')),
          );
          return;
        }
      }

      // Upload license image
      try {
        if (_licenseImagePath != null) {
          licenseImageUrl = await _appwriteProviderService.uploadFileforURL(
            _licenseImagePath!,
            'license_documents'
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload license image: $e')),
          );
          return;
        }
      }

      // Process certifications
      try {
        for (var cert in _certifications) {
          if (cert.isDeleted) continue;
          
          if (cert.isLocal) {
            final uploadedUrl = await _appwriteProviderService.uploadFileforURL(
              cert.uploadFile!.path, 
              'certifications'
            );
            updatedCertifications.add(uploadedUrl);
          } else if (cert.displayUrl != null) {
            updatedCertifications.add(cert.displayUrl!);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload certifications: $e')),
          );
          return;
        }
      }

      // Process gallery images
      try {
        for (var image in _gallery) {
          if (image.isDeleted) continue;
          
          if (image.isLocal) {
            final uploadedUrl = await _appwriteProviderService.uploadFileforURL(
              image.uploadFile!.path, 
              'gallery'
            );
            updatedGallery.add(uploadedUrl);
          } else if (image.displayUrl != null) {
            updatedGallery.add(image.displayUrl!);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload gallery images: $e')),
          );
          return;
        }
      }

      // Prepare license info
      final licenseInfo = {
        'licenseNumber': _licenseNumberController.text,
        'issuingAuthority': _issuingAuthorityController.text,
        'issueDate': widget.provider.licenseInfo.issueDate.toIso8601String(),
        'expiryDate': widget.provider.licenseInfo.expiryDate.toIso8601String(),
        'licenseImageUrl': licenseImageUrl ?? widget.provider.licenseInfo.licenseImageUrl,
      };

      // Prepare final update data
      final updateData = {
        'name': _nameController.text,
        'about': _aboutController.text,
        'address': _addressController.text,
        'licenseInfo': jsonEncode(licenseInfo),
        'imageUrl': profileImageUrl ?? _profileImageUrl,
        'services': _services,
        'gallery': updatedGallery,
        'certifications': updatedCertifications,
        'hourlyRate': int.parse(_hourlyRateController.text),
      };

      // Update provider profile
      try {
        final updatedProvider = await _appwriteProviderService.updateProvider(
          providerId: providerId,
          updates: updateData,
        );

        // Update local state
        _providerProvider.updateProvider(updatedProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() => _isEditing = false);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update provider profile: $e')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _appwriteProviderService.logoutProvider();
      Provider.of<ServiceProviderProvider>(context, listen: false).clearProviderData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProviderLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: $e')),
        );
      }
    }
  }

  void _addService() {
    String? selectedService;
    final List<String> serviceOptions = [
      'Nurse',
      'Physiotherapist',
      'Elderly Care',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Service'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Service',
            border: OutlineInputBorder(),
          ),
          items: serviceOptions.map((service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (value) {
            selectedService = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedService != null && selectedService!.isNotEmpty) {
                setState(() => _services.add(selectedService!));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addGalleryImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _gallery.add(ImageState(localFile: File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick gallery image: $e')),
        );
      }
    }
  }

  Future<void> _addCertification() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _certifications.add(ImageState(localFile: File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick certification: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    _isEditing = true;
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 16),
                    _buildServices(),
                    const SizedBox(height: 16),
                    if (_services.contains('Physiotherapist')) ...[
                      _buildGallerySection(),
                      const SizedBox(height: 16),
                    ],
                    _buildCertificationsSection(),
                    const SizedBox(height: 16),
                    _buildLicenseInfo(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.gradientEnd],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Profile content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!)
                                : null) as ImageProvider?,
                        child: _profileImageUrl == null && _profileImageFile == null
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _services.isNotEmpty ? _services.first : 'Healthcare Provider',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildSection(
      'Basic Information',
      Icons.person_outline,
      Column(
        children: [
          _buildTextField(
            'Full Name',
            _nameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'About',
            _aboutController,
            enabled: _isEditing,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Address',
            _addressController,
            enabled: _isEditing,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hourlyRateController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Hourly Rate (PKR)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: !_isEditing,
              fillColor: _isEditing ? null : Colors.grey.shade100,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Hourly rate is required';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (int.parse(value) <= 0) {
                return 'Hourly rate must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return _buildSection(
      'Services Offered',
      Icons.medical_services_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._services.map((service) => Chip(
                    label: Text(service),
                    deleteIcon: _isEditing ? const Icon(Icons.close, size: 18) : null,
                    onDeleted: _isEditing ? () => setState(() => _services.remove(service)) : null,
                  )),
              if (_isEditing)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service'),
                  onPressed: _addService,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return _buildSection(
      'Gallery',
      Icons.photo_library_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _gallery.length + (_isEditing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _gallery.length) {
                  return _buildAddGalleryButton();
                }
                return _buildGalleryItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGalleryButton() {
    return GestureDetector(
      onTap: _isEditing ? _addGalleryImage : null,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }

  Widget _buildGalleryItem(int index) {
    final image = _gallery[index];
    if (image.isDeleted) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          width: 120,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isLocal
                ? Image.file(image.uploadFile!, fit: BoxFit.cover)
                : Image.network(image.displayUrl!, fit: BoxFit.cover),
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 4,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() {
                _gallery[index] = image.markDeleted();
              }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return _buildSection(
      'Certifications',
      Icons.verified_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _certifications.length + (_isEditing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _certifications.length) {
                  return _buildAddCertificationButton();
                }
                return _buildCertificationItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCertificationButton() {
    return GestureDetector(
      onTap: _isEditing ? _addCertification : null,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined),
            SizedBox(height: 8),
            Text('Add Certificate'),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationItem(int index) {
    final cert = _certifications[index];
    if (cert.isDeleted) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          width: 140,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: cert.isLocal
              ? Image.file(cert.uploadFile!, fit: BoxFit.cover)
              : Image.network(cert.displayUrl!, fit: BoxFit.cover),
        ),
        if (_isEditing)
          Positioned(
            top: 4,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() {
                _certifications[index] = cert.markDeleted();
              }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLicenseInfo() {
    return _buildSection(
      'License Information',
      Icons.badge_outlined,
      Column(
        children: [
          _buildTextField(
            'License Number',
            _licenseNumberController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Issuing Authority',
            _issuingAuthorityController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isEditing ? _pickLicenseImage : null,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _licenseImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_licenseImage!, fit: BoxFit.cover),
                    )
                  : widget.provider.licenseInfo.licenseImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.provider.licenseInfo.licenseImageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload License Image',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
