import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/custom_design_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';

class CustomDesignView extends StatefulWidget {
  final bool showAppBar;
  const CustomDesignView({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<CustomDesignView> createState() => _CustomDesignViewState();
}

class _CustomDesignViewState extends State<CustomDesignView> {
  final _companyController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referenceController = TextEditingController();
  final _poController = TextEditingController();

  final _projectDescController = TextEditingController();
  final _timeframeController = TextEditingController();
  final _fingerSizeController = TextEditingController();
  final _metalController = TextEditingController();
  final _centerShapeController = TextEditingController();

  bool _isVerified = false;
  bool _isVerifyingCaptcha = false;
  
  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _pickedImages.addAll(images);
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          if (!mounted) return;
          setState(() {
            _pickedImages.add(image);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    _poController.dispose();
    _projectDescController.dispose();
    _timeframeController.dispose();
    _fingerSizeController.dispose();
    _metalController.dispose();
    _centerShapeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final company = _companyController.text.trim();
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final projectDesc = _projectDescController.text.trim();

    if (company.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty || projectDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)'), backgroundColor: Colors.red),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.red),
      );
      return;
    }

    final phoneRegex = RegExp(r'^[\+\(\)\s\-0-9]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify that you are not a robot.'), backgroundColor: Colors.red),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    if (authVm.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit custom design request.'), backgroundColor: Colors.red),
      );
      return;
    }

    final customDesignVm = Provider.of<CustomDesignViewModel>(context, listen: false);

    final success = await customDesignVm.submitDesignForm(
      userId: authVm.user!.userId,
      name: name,
      company: company,
      email: email,
      contact: phone,
      msg: projectDesc,
      frame: _timeframeController.text.trim(),
      budget: '', 
      referenceNumber: _referenceController.text.trim(),
      po: _poController.text.trim(),
      size: _fingerSizeController.text.trim(),
      metal: _metalController.text.trim(),
      centerDiamond: _centerShapeController.text.trim(),
      imagePaths: _pickedImages.map((e) => e.path).toList(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank You for giving us opportunity to service your company for custom design needs.'), backgroundColor: Colors.green),
      );
      _companyController.clear();
      _fullNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _referenceController.clear();
      _poController.clear();
      _projectDescController.clear();
      _timeframeController.clear();
      _fingerSizeController.clear();
      _metalController.clear();
      _centerShapeController.clear();
      setState(() {
        _pickedImages.clear();
        _isVerified = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(customDesignVm.errorMessage ?? 'Failed to submit request.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // light background matching the image
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Custom Design'),
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
        child: Column(
          children: [
            // _buildHeaderSection(),
            // const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildProjectDetailsSection(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildCaptcha(),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Design With Us',
            style: GoogleFonts.cormorantUpright(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 80,
            color: AppColors.primaryButton, // Small underline as in design
          ),
          const SizedBox(height: 20),
          Text(
            'Choosing Wickersham Jewelers means choosing a personalized experience where your ideas and values are at the forefront of our design process. Our expert team is here to guide you through every step, from the initial concept to the final creation. Design your dream engagement ring, pendant, earring or necklace with© Wickersham Jewelers today. Explore our custom options, including CAD designs and reused diamonds to create a unique and meaningful piece that will last a lifetime. Your perfect jewelry piece awaits; contact us now to start your journey!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name and Contact Info',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us about yourself',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildLabeledTextField('Company/Organization*', _companyController),
          _buildLabeledTextField('Full Name*', _fullNameController),
          _buildLabeledTextField('Email Address*', _emailController, keyboardType: TextInputType.emailAddress),
          _buildLabeledTextField('Phone Number*', _phoneController, keyboardType: TextInputType.phone),
          _buildLabeledTextField('Reference*', _referenceController),
          _buildLabeledTextField('PO', _poController),
        ],
      ),
    );
  }

  Widget _buildCaptcha() {
    return GestureDetector(
      onTap: () async {
        if (_isVerified || _isVerifyingCaptcha) return;

        setState(() => _isVerifyingCaptcha = true);
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
        width: 300,
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _isVerified ? Colors.transparent : const Color(0xFFC1C1C1),
                        width: 2),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: _isVerifyingCaptcha
                      ? const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : _isVerified
                          ? const Center(child: Icon(Icons.check, size: 24, color: Colors.green))
                          : null,
                ),
                const SizedBox(width: 12),
                const Text("I'm not a robot",
                    style: TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.w500)),
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
    );
  }

  Widget _buildProjectDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us about your project',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildLabeledTextField('Please tell us about your project*', _projectDescController),
          _buildLabeledTextField('What is your timeframe?', _timeframeController),
          _buildLabeledTextField('Finger Size', _fingerSizeController),
          _buildLabeledTextField('Metal', _metalController),
          _buildLabeledTextField('Center shape/size', _centerShapeController),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CustomDesignViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showImageSourceActionSheet,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  'Upload your images',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (_pickedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _pickedImages.map((img) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImages.remove(img);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                            ),
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send Your Project',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: '',
            controller: controller,
            keyboardType: keyboardType,
          ),
        ],
      ),
    );
  }


}
