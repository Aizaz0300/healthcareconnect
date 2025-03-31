import 'package:flutter/material.dart';
import 'dart:io';
import '/constants/app_colors.dart';
import '/utils/validators.dart';
import '/widgets/password_strength_indicator.dart';
import 'provider_login_screen.dart';
import '/widgets/document_upload_card.dart';
import '/screens/common/terms_and_conditions_screen.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _professionalInfoFormKey = GlobalKey<FormState>();

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Professional Info Controllers
  final _specialityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _bioController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;
  int _currentStep = 0;
  List<String> _selectedServices = [];

  final List<String> _availableServices = [
    'Home Visit',
    'Video Consultation',
    'Chat Consultation',
    'Emergency Care',
    'Regular Checkup',
  ];

  File? _licenseDocument;
  File? _qualificationDocument;
  File? _identityDocument;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Registration'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _handleContinue,
          onStepCancel: _handleCancel,
          type: StepperType.vertical,

          steps: [
            Step(
              title: const Text('Basic'),
              content: _buildBasicInfoForm(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Professional'),
              content: _buildProfessionalInfoForm(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Documents'),
              content: _buildDocumentUploads(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Services'),
              content: _buildServicesForm(),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Form(
      key: _basicInfoFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.required,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: Validators.phone,
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildProfessionalInfoForm() {
    return Form(
      key: _professionalInfoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _specialityController,
            decoration: const InputDecoration(
              labelText: 'Speciality',
              prefixIcon: Icon(Icons.medical_services),
            ),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              prefixIcon: Icon(Icons.work),
              suffixText: 'years',
            ),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qualificationController,
            decoration: const InputDecoration(
              labelText: 'Highest Qualification',
              prefixIcon: Icon(Icons.school),
            ),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _licenseNumberController,
            decoration: const InputDecoration(
              labelText: 'License Number',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _consultationFeeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Consultation Fee',
              prefixIcon: Icon(Icons.attach_money),
              prefixText: '\$ ',
            ),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Professional Bio',
              prefixIcon: Icon(Icons.description),
            ),
            validator: Validators.required,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DocumentUploadCard(
          title: 'Professional License',
          description: 'Upload your valid professional license (PDF, JPG, PNG)',
          onFileSelected: (file) => _licenseDocument = file,
          onRemove: () => _licenseDocument = null,
          initialFile: _licenseDocument,
        ),
        DocumentUploadCard(
          title: 'Qualification Certificate',
          description: 'Upload your highest qualification certificate',
          onFileSelected: (file) => _qualificationDocument = file,
          onRemove: () => _qualificationDocument = null,
          initialFile: _qualificationDocument,
        ),
        DocumentUploadCard(
          title: 'Identity Document',
          description: 'Upload a government-issued ID',
          onFileSelected: (file) => _identityDocument = file,
          onRemove: () => _identityDocument = null,
          initialFile: _identityDocument,
        ),
      ],
    );
  }

  Widget _buildServicesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Services You Provide',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableServices.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildTermsAndConditions(),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) => setState(() => _acceptedTerms = value!),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showTermsAndConditions(),
            child: const Text.rich(
              TextSpan(
                text: 'I accept the ',
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleContinue() async {
    if (_currentStep == 0) {
      if (_basicInfoFormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_professionalInfoFormKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 2) {
      if (_licenseDocument == null ||
          _qualificationDocument == null ||
          _identityDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload all required documents'),
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else {
      if (_selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one service')),
        );
        return;
      }
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept terms and conditions')),
        );
        return;
      }
      _handleSignUp();
    }
  }

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual signup logic
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProviderLoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );
  }
}
