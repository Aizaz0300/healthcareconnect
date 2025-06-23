import 'package:flutter/material.dart';
import 'package:healthcare/screens/auth/provider/provider_signup_failure_screen.dart';
import '/models/service_provider.dart';
import '/services/appwrite_provider_service.dart';
import '/constants/app_colors.dart';
import '/utils/validators.dart';
import '/widgets/password_strength_indicator.dart';
import 'provider_login_screen.dart';
import 'provider_signup_success_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '/widgets/profile_image_picker.dart';
import '/widgets/custom_input_field.dart';
import '/widgets/section_title.dart';
import '/widgets/date_selector.dart';
import '/utils/availability_helper.dart';
import '/widgets/day_schedule_card.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // Basic Info Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Male';
  File? _profileImage;
  String? _profileImagePath;

  // CNIC Images
  File? _cnicFront;
  String? _cnicFrontPath;
  File? _cnicBack;
  String? _cnicBackPath;

  // Service Info
  final List<String> _availableServices = [
    'Nurse',
    'Physiotherapist',
    'Elderly Care'
  ];
  List<String> _selectedServices = [];
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();

  // License Info
  final _licenseNumberController = TextEditingController();
  final _issuingAuthorityController = TextEditingController();
  DateTime? _licenseIssueDate;
  DateTime? _licenseExpiryDate;
  File? _licenseDocument;
  String? _licenseDocumentPath;

  // Gallery (for Physiotherapists)
  List<File> _galleryImages = [];
  List<String> _galleryImagepath = [];
  List<File> _certifications = [];
  List<String> _certificationPaths = [];

  // Social Media Links
  List<Map<String, dynamic>> _socialLinks = [];

  // Availability
  Map<String, DaySchedule> _availability =
      AvailabilityHelper.getInitialAvailability();

  // Social Media Dialog
  String _selectedPlatform = '';
  final _socialLinkController = TextEditingController();

  final _appwriteProviderService = AppwriteProviderService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _hourlyRateController.dispose();
    _licenseNumberController.dispose();
    _issuingAuthorityController.dispose();
    _socialLinkController.dispose();
    _profileImage = null;
    _cnicFront = null;
    _cnicBack = null;
    _licenseDocument = null;
    _galleryImages.clear();
    _certifications.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderLoginScreen(),
                ),
              );
            },
          ),
          title: const Text(
            'Provider Registration',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 44, 44, 44)),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    secondary: AppColors.primary.withOpacity(0.1),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  cardTheme: CardTheme(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProgressIndicator(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildCurrentStep(),
                        ),
                      ),
                      _buildStepNavigation(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            flex: _currentStep + 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 117, 233),
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(6),
                    right: Radius.circular(_currentStep == 4 ? 6 : 0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 5 - _currentStep,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildProfessionalStep();
      case 2:
        return _buildLicenseStep();
      case 3:
        return _buildAvailabilityStep();
      case 4:
        return _buildAdditionalStep();
      default:
        return Container();
    }
  }

  Widget _buildStepNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton.icon(
              onPressed: _handleStepCancel,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton.icon(
            onPressed: _handleStepContinue,
            icon: _currentStep < 4
                ? const Icon(Icons.arrow_forward)
                : const Icon(Icons.check),
            label: Text(_currentStep < 4 ? 'Continue' : 'Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        const SizedBox(height: 24),
        Center(
          child: ProfileImagePicker(
            profileImage: _profileImage,
            onPickImage: _pickProfileImage,
          ),
        ),
        const SizedBox(height: 32),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _addressController,
                  label: 'Coverage Areas e.g Johar Town',
                  icon: Icons.location_on,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildPasswordField(),
              ],
            ),
          ),
        ),
        _buildCnicUpload(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCnicUpload() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('CNIC Images',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            MediaQuery.of(context).size.width > 600
                ? Row(
                    children: [
                      Expanded(
                          child: _buildImageUploader(
                              'Front Side', _cnicFront, true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildImageUploader(
                              'Back Side', _cnicBack, false)),
                    ],
                  )
                : Column(
                    children: [
                      _buildImageUploader('Front Side', _cnicFront, true),
                      const SizedBox(height: 12),
                      _buildImageUploader('Back Side', _cnicBack, false),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploader(String title, File? image, bool isFront) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          image != null
              ? Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(image,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        if (isFront) {
                          _cnicFront = null;
                          _cnicFrontPath = null;
                        } else {
                          _cnicBack = null;
                          _cnicBackPath = null;
                        }
                      }),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 16,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () => _pickCNICImage(isFront),
                  child: Container(
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(height: 4),
                        Text('Upload',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Male', Icons.male),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Female', Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          validator: Validators.password,
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        PasswordStrengthIndicator(password: _passwordController.text),
      ],
    );
  }

  Widget _buildProfessionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Professional Details'),
        const SizedBox(height: 24),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Your Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                _buildServiceSelection(),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _experienceController,
                  label: 'Years of Experience',
                  icon: Icons.work,
                  validator: Validators.required,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _aboutController,
                      decoration: InputDecoration(
                        hintText:
                            'Describe your professional background and expertise',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 5,
                      validator: Validators.required,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _hourlyRateController,
                  label: 'Set Your Hourly Rate in PKR',
                  icon: Icons.payments,
                  validator: (value) {
                    final numericValue = value?.replaceAll('PKR ', '') ?? '';
                    if (numericValue.isEmpty) return 'Hourly rate is required';
                    if (double.tryParse(numericValue) == null) return 'Enter a valid number';
                    return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableServices.map((service) {
        final isSelected = _selectedServices.contains(service);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedServices.remove(service);
                if (service == 'Physiotherapist') {
                  _galleryImages.clear();
                }
              } else {
                _selectedServices.add(service);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getServiceIcon(service),
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  service,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'Nurse':
        return Icons.medical_services;
      case 'Physiotherapist':
        return Icons.accessibility_new;
      case 'Elderly Care':
        return Icons.elderly;
      default:
        return Icons.healing;
    }
  }

  Widget _buildLicenseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'License Information'),
        const SizedBox(height: 24),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInputField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  icon: Icons.badge,
                  validator: Validators.required,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _issuingAuthorityController,
                  label: 'Issuing Authority',
                  icon: Icons.business,
                  validator: Validators.required,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DateSelector(
                        label: 'Issue Date',
                        selectedDate: _licenseIssueDate,
                        onSelect: (date) =>
                            setState(() => _licenseIssueDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DateSelector(
                        label: 'Expiry Date',
                        selectedDate: _licenseExpiryDate,
                        onSelect: (date) =>
                            setState(() => _licenseExpiryDate = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDocumentUploader(), // Add this line back
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Document',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        if (_licenseDocument == null)
          InkWell(
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                );

                if (result != null) {
                  setState(() {
                    _licenseDocument = File(result.files.single.path!);
                    _licenseDocumentPath = result.files.single.path;
                  });
                }
              } catch (e) {
                _showError('Error picking file: ${e.toString()}');
              }
            },
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
                    'Upload License Document',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF, JPG, JPEG or PNG',
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
                _licenseDocument!.path.endsWith('.pdf')
                    ? Icons.picture_as_pdf
                    : Icons.image,
                color: AppColors.primary,
              ),
              title: Text(
                _licenseDocument!.path.split('/').last,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() => _licenseDocument = null),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityStep() {
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Your Availability'),
        const SizedBox(height: 24),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: weekDays.map((day) {
                return DayScheduleCard(
                  day: day,
                  schedule: _availability[day]!,
                  onAvailabilityChanged: (day, value) {
                    setState(() {
                      _availability[day] =
                          AvailabilityHelper.updateAvailability(
                              _availability[day]!, value);
                      if (value && _availability[day]!.timeWindows.isEmpty) {
                        _addTimeWindow(day);
                      }
                    });
                  },
                  onAddTimeWindow: _addTimeWindow,
                  onTimeSelect: _selectTime,
                  onRemoveTimeWindow: _removeTimeWindow,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _addTimeWindow(String day) {
    final schedule = _availability[day]!;
    setState(() {
      _availability[day] = AvailabilityHelper.addTimeWindow(schedule);
    });
  }

  void _removeTimeWindow(String day, TimeWindow window) {
    final schedule = _availability[day]!;
    setState(() {
      _availability[day] =
          AvailabilityHelper.removeTimeWindow(schedule, window);
    });
  }

  Widget _buildAdditionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Additional Information'),
        const SizedBox(height: 24),
        if (_selectedServices.contains('Physiotherapist')) ...[
          _buildGallerySection(),
          const SizedBox(height: 24),
        ],
        _buildCertificationsSection(),
        const SizedBox(height: 24),
        _buildSocialLinksSection(),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Equipment Gallery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickGalleryImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_galleryImages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Add photos of your physiotherapy equipment',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._galleryImages.map((image) => _buildImagePreview(
                        image,
                        onRemove: () =>
                            setState(() => _galleryImages.remove(image)),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Certifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickCertifications,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_certifications.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Upload your certification documents',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _certifications.length,
                itemBuilder: (context, index) {
                  final file = _certifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        file.path.endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        file.path.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade400),
                        onPressed: () =>
                            setState(() => _certifications.remove(file)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Social Media Links',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSocialLink,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add Link'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_socialLinks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Add your social media profiles',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _socialLinks.length,
                itemBuilder: (context, index) {
                  final link = _socialLinks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(link['icon'] as IconData,
                          color: AppColors.primary),
                      title: Text(link['platform'] as String),
                      subtitle: Text(link['url'] as String),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade400),
                        onPressed: () =>
                            setState(() => _socialLinks.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _handleStepContinue() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!_formKey.currentState!.validate() ||
            _profileImage == null ||
            _cnicFront == null ||
            _cnicBack == null ||
            _nameController.text.isEmpty ||
            _emailController.text.isEmpty ||
            _phoneController.text.isEmpty ||
            _addressController.text.isEmpty ||
            _passwordController.text.isEmpty) {
          _showError(
              'Please fill all required fields and upload all required images');
          return false;
        }
        return true;

      case 1:
        if (_selectedServices.isEmpty ||
            _experienceController.text.isEmpty ||
            _aboutController.text.isEmpty) {
          _showError('Please fill all professional details');
          return false;
        }
        return true;

      case 2:
        if (_formKey.currentState?.validate() != true ||
            _licenseIssueDate == null ||
            _licenseExpiryDate == null ||
            _licenseDocument == null) {
          _showError('Please fill all license information');
          return false;
        }
        return true;

      case 3:
        bool hasAvailability = false;
        _availability.forEach((_, schedule) {
          if (schedule.isAvailable && schedule.timeWindows.isNotEmpty) {
            hasAvailability = true;
          }
        });
        if (!hasAvailability) {
          _showError('Please set at least one day of availability');
          return false;
        }
        return true;

      case 4:
        if (_certifications.isEmpty) {
          _showError('Please upload at least one certification');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _handleStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      _showError('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _pickCNICImage(bool isFront) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isFront) {
            _cnicFront = File(image.path);
            _cnicFrontPath = image.path;
          } else {
            _cnicBack = File(image.path);
            _cnicBackPath = image.path;
          }
        });
      }
    } catch (e) {
      _showError('Error picking CNIC image: ${e.toString()}');
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _galleryImages.add(File(image.path));
            _galleryImagepath.add(image.path);
          }
        });
      }
    } catch (e) {
      _showError('Error picking images: ${e.toString()}');
    }
  }

  Future<void> _pickCertifications() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _certifications.add(File(file.path!));
              _certificationPaths.add(file.path!);
            }
          }
        });
      }
    } catch (e) {
      _showError('Error picking files: ${e.toString()}');
    }
  }

  void _addSocialLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Social Media Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Platform'),
              items: const [
                DropdownMenuItem(value: 'Facebook', child: Text('Facebook')),
                DropdownMenuItem(value: 'Twitter', child: Text('Twitter')),
                DropdownMenuItem(value: 'LinkedIn', child: Text('LinkedIn')),
                DropdownMenuItem(value: 'Instagram', child: Text('Instagram')),
              ],
              onChanged: (value) => setState(() {
                _selectedPlatform = value!;
              }),
            ),
            TextField(
              controller: _socialLinkController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedPlatform.isNotEmpty &&
                  _socialLinkController.text.isNotEmpty) {
                setState(() {
                  _socialLinks.add({
                    'platform': _selectedPlatform,
                    'url': _socialLinkController.text,
                    'icon': _getSocialIcon(_selectedPlatform),
                  });
                });
                _socialLinkController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform) {
      case 'Facebook':
        return Icons.facebook;
      case 'Twitter':
        return Icons.switch_access_shortcut;
      case 'LinkedIn':
        return Icons.link;
      case 'Instagram':
        return Icons.camera_alt;
      default:
        return Icons.link;
    }
  }

  Future<void> _selectTime(String day, TimeWindow window, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? window.start : window.end,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final schedule = _availability[day]!;
        final index = schedule.timeWindows.indexOf(window);
        final updatedWindow = TimeWindow(
          start: isStart ? picked : window.start,
          end: isStart ? window.end : picked,
        );
        final updatedWindows = List<TimeWindow>.from(schedule.timeWindows);
        updatedWindows[index] = updatedWindow;
        _availability[day] = DaySchedule(
          isAvailable: true,
          timeWindows: updatedWindows,
        );
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      return false;
    }
    // Show confirmation dialog before leaving
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'Are you sure you want to leave? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_validateCurrentStep()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl;
      if (_profileImagePath != null) {
        profileImageUrl = await _appwriteProviderService.uploadFileforURL(
          _profileImagePath!,
          'profile_images',
        );
      }

      List<String> cnicUrls = [];
      if (_cnicFrontPath != null && _cnicBackPath != null) {
        cnicUrls = await Future.wait([
          _appwriteProviderService.uploadFileforURL(
              _cnicFrontPath!, 'cnic_images'),
          _appwriteProviderService.uploadFileforURL(
              _cnicBackPath!, 'cnic_images'),
        ]);
      }

      String? licenseImageUrl;
      if (_licenseDocumentPath != null) {
        licenseImageUrl = await _appwriteProviderService.uploadFileforURL(
          _licenseDocumentPath!,
          'license_documents',
        );
      }

      List<String> galleryUrls = [];
      if (_galleryImagepath.isNotEmpty) {
        galleryUrls = await Future.wait(
          _galleryImagepath
              .map((file) => _appwriteProviderService.uploadFileforURL(
                    file,
                    'gallery_images',
                  )),
        );
      }

      List<String> certificationUrls = [];
      if (_certificationPaths.isNotEmpty) {
        certificationUrls = await Future.wait(
          _certificationPaths
              .map((file) => _appwriteProviderService.uploadFileforURL(
                    file,
                    'certifications',
                  )),
        );
      }

      // 2. Create ServiceProvider object with null-safe values
      final serviceProvider = ServiceProvider(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGender,
        phone: _phoneController.text,
        imageUrl: profileImageUrl ?? '', // Provide default empty string if null
        services: _selectedServices,
        rating: 0,
        reviewCount: 0,
        experience: int.parse(_experienceController.text),
        about: _aboutController.text,
        availability: Availability(
          monday: _availability['Monday']!,
          tuesday: _availability['Tuesday']!,
          wednesday: _availability['Wednesday']!,
          thursday: _availability['Thursday']!,
          friday: _availability['Friday']!,
          saturday: _availability['Saturday']!,
          sunday: _availability['Sunday']!,
        ),
        address: _addressController.text,
        cnic: cnicUrls,
        gallery: galleryUrls,
        certifications: certificationUrls,
        socialLinks: _socialLinks
            .map((link) => SocialMedia(
                  platform: link['platform'],
                  url: link['url'],
                  icon: link['icon'],
                ))
            .toList(),
        licenseInfo: LicenseInfo(
          licenseNumber: _licenseNumberController.text,
          issuingAuthority: _issuingAuthorityController.text,
          issueDate: _licenseIssueDate!,
          expiryDate: _licenseExpiryDate!,
          licenseImageUrl:
              licenseImageUrl ?? '', // Provide default empty string if null
        ),
        reviewList: [],
        hourlyRate: double.parse(_hourlyRateController.text.replaceAll('PKR ', ''),).toInt(),
      );

      // 3. Create provider account
      await _appwriteProviderService.createProvider(
        provider: serviceProvider,
        password: _passwordController.text,
      );

      if (mounted) {
        // Clear the provider data in case there was any
        // context.read<ServiceProviderProvider>().clearProviderData();

        // 4. Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProviderSignupSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        bool isEmailConflict = false;

        if (e.toString().contains('email already exists')) {
          errorMessage =
              'An account with this email already exists. Please login or use a different email.';
          isEmailConflict = true;
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error occurred. Please check your internet connection and try again.';
        } else {
          errorMessage =
              'Registration failed. Please try again later.\n\nError: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: isEmailConflict ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
