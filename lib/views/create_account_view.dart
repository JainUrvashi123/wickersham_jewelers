import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:csc_picker/csc_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';
import 'components/video_background.dart';
import '../../core/providers/global_loader_provider.dart';


class CreateAccountView extends StatefulWidget {
  const CreateAccountView({Key? key}) : super(key: key);

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;

  bool _obscurePassword = true;
  bool _acceptTerms = false;


  final _formKey = GlobalKey<FormState>();

  bool _isVerified = false;
  bool _isVerifyingCaptcha = false;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required';
    }
    // Basic phone validation
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _unitController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    if (_formKey.currentState == null) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar("Please fill all required fields correctly.");
      return;
    }

    if (_selectedCountry == null || _selectedCountry!.isEmpty || _selectedCountry!.contains('Select')) {
      _showErrorSnackBar("Please select a country.");
      return;
    }

    if (_selectedState == null || _selectedState!.isEmpty || _selectedState!.contains('Select')) {
      _showErrorSnackBar("Please select a state.");
      return;
    }

    if (!_acceptTerms) {
      _showErrorSnackBar("Please accept the terms of use.");
      return;
    }

    // Check if Captcha is verified
    if (!_isVerified) {
      _showErrorSnackBar("Please verify that you are not a robot.");
      return;
    }

    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final globalLoader = Provider.of<GlobalLoaderProvider>(context, listen: false);

    globalLoader.show();
    final successMessage = await viewModel.register({
      'email': _emailController.text,
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'password': _passwordController.text,
      'company': _companyController.text,
      'address': _addressController.text,
      'unit': _unitController.text,
      'city': _cityController.text,
      'countries': _selectedCountry ?? '',
      'state': _selectedState ?? '',
      'zipcode': _zipcodeController.text,
      'phone': _phoneController.text,
      'website': _websiteController.text,
    });
    globalLoader.hide();

    if (successMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      // Navigate to login screen after account creation
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else if (mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBackground(
        // videoUrl: AppAssets.backgroundVideo,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double logoWidth = screenWidth >= 1200
                  ? 240.0
                  : (screenWidth >= 600 ? 180.0 : 140.0);
              final double logoHeight = screenWidth >= 1200
                  ? 140.0
                  : (screenWidth >= 600 ? 110.0 : 90.0);
              final double textFontSize = screenWidth >= 1200
                  ? 36.0
                  : (screenWidth >= 600 ? 30.0 : 26.0);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: logoHeight,
                                width: logoWidth,
                                child: OverflowBox(
                                  maxHeight: logoWidth,
                                  maxWidth: logoWidth,
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                    AppAssets.logoEmail,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Text(
                                      'Wickersham Jewelers',
                                      style: GoogleFonts.cormorantUpright(
                                        fontSize: textFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        // Main Content
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 400),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Create Account',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.cormorantUpright(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Enter your account details to sign up',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          
                                          // Make inputs mobile friendly (vertical instead of Row)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: CustomTextField(
                                                controller: _firstNameController, 
                                                hintText: 'First Name',
                                                validator: (v) => _validateRequired(v, 'First Name'),
                                              )),
                                              const SizedBox(width: 16),
                                              Expanded(child: CustomTextField(
                                                controller: _lastNameController, 
                                                hintText: 'Last Name',
                                                validator: (v) => _validateRequired(v, 'Last Name'),
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            controller: _emailController, 
                                            hintText: 'Email', 
                                            keyboardType: TextInputType.emailAddress,
                                            validator: _validateEmail,
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            controller: _passwordController,
                                            hintText: 'Password',
                                            obscureText: _obscurePassword,
                                            validator: _validatePassword,
                                            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            onSuffixTap: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            }
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            controller: _companyController, 
                                            hintText: 'Company',
                                            validator: (v) => _validateRequired(v, 'Company'),
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            controller: _addressController, 
                                            hintText: 'Street Address',
                                            validator: (v) => _validateRequired(v, 'Address'),
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(controller: _unitController, hintText: 'Unit #'),
                                          const SizedBox(height: 16),
                                          CSCPicker(
                                            showStates: true,
                                            showCities: false,
                                            flagState: CountryFlag.DISABLE,
                                            dropdownDecoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                color: const Color(0xFFF7F8FA),
                                                border: Border.all(color: Colors.transparent, width: 0)),
                                            disabledDropdownDecoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                color: const Color(0xFFF7F8FA),
                                                border: Border.all(color: Colors.transparent, width: 0)),
                                            countrySearchPlaceholder: "Country",
                                            stateSearchPlaceholder: "State",
                                            citySearchPlaceholder: "City",
                                            countryDropdownLabel: "Select Country",
                                            stateDropdownLabel: "Select State",
                                            cityDropdownLabel: "Select City",
                                            selectedItemStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            dropdownHeadingStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                            dropdownItemStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            onCountryChanged: (value) {
                                              setState(() {
                                                _selectedCountry = value;
                                              });
                                            },
                                            onStateChanged: (value) {
                                              setState(() {
                                                _selectedState = value;
                                              });
                                            },
                                            onCityChanged: (value) {},
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: CustomTextField(
                                                controller: _cityController, 
                                                hintText: 'City',
                                                validator: (v) => _validateRequired(v, 'City'),
                                              )),
                                              const SizedBox(width: 16),
                                              Expanded(child: CustomTextField(
                                                controller: _zipcodeController, 
                                                hintText: 'ZIP/Postal',
                                                validator: (v) => _validateRequired(v, 'ZIP code'),
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            controller: _phoneController, 
                                            hintText: 'Phone', 
                                            keyboardType: TextInputType.phone,
                                            validator: _validatePhone,
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(controller: _websiteController, hintText: 'Website', keyboardType: TextInputType.url),
                                          
                                          const SizedBox(height: 24),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: _acceptTerms,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _acceptTerms = val ?? false;
                                                    });
                                                  },
                                                  activeColor: AppColors.primaryButton,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Wrap(
                                                  children: [
                                                    const Text(
                                                      'I have read and accept ',
                                                      style: TextStyle(
                                                        color: AppColors.textSecondary,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(context, '/terms_conditions');
                                                      },
                                                      child: const Text(
                                                        'terms of use.',
                                                        style: TextStyle(
                                                          color: AppColors.primaryButton,
                                                          fontSize: 13,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 16),
                                          // Fake ReCaptcha, adapted to fit within mobile box
                                          GestureDetector(
                                            onTap: () async {
                                              if (_isVerified || _isVerifyingCaptcha) return;

                                              setState(() => _isVerifyingCaptcha = true);
                                              // Simulate verification delay
                                              await Future.delayed(const Duration(milliseconds: 1000));

                                              if (mounted) {
                                                setState(() {
                                                  _isVerifyingCaptcha = false;
                                                  _isVerified = true;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 74,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(3),
                                                color: const Color(0xFFF9F9F9),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 28, height: 28,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: _isVerified ? Colors.transparent : const Color(0xFFC1C1C1),
                                                              width: 2
                                                          ),
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(2),
                                                        ),
                                                        child: _isVerifyingCaptcha
                                                            ? const Padding(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: CircularProgressIndicator(strokeWidth: 2,),
                                                        )
                                                            : _isVerified ? const Center(child: Icon(Icons.check, size: 24, color: Colors.green)) : null,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                          "I'm not a robot",
                                                          style: const TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.w500)
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.network(
                                                        'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                                                        width: 32,
                                                        errorBuilder: (context, error, stackTrace) =>
                                                            Icon(Icons.sync, color: Colors.blue.shade600, size: 28),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text('reCAPTCHA', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
                                                      const SizedBox(height: 2),
                                                      const Text('Privacy - Terms', style: TextStyle(fontSize: 8, color: Color(0xFF555555))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 24),
                                           Consumer<AuthViewModel>(
                                            builder: (context, viewModel, child) {
                                              return CustomButton(
                                                text: 'SIGN UP',
                                                isLoading: viewModel.isLoading,
                                                onPressed: _onSignUp,
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: const [
                                              Expanded(child: Divider()),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                                child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
                                              ),
                                              Expanded(child: Divider()),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context); // Go back to login
                                                },
                                                child: const Text('Login', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
