import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/contact_viewmodel.dart';
import 'components/custom_text_field.dart';

class ContactView extends StatefulWidget {
  const ContactView({Key? key}) : super(key: key);

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();

  bool _acceptTerms = false;
  bool _isNotRobot = false;
  bool _isVerifyingCaptcha = false;

  late final WebViewController? _mapController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _mapController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(_getMapHtml());
    } else {
      _mapController = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept terms of use')),
        );
        return;
      }
      if (!_isNotRobot) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify you are not a robot')),
        );
        return;
      }

      final viewModel = Provider.of<ContactViewModel>(context, listen: false);
      
      final success = await viewModel.submitContactForm(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.successMessage ?? 'Success'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form
          _nameController.clear();
          _emailController.clear();
          _mobileController.clear();
          _messageController.clear();
          setState(() {
            _acceptTerms = false;
            _isNotRobot = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to submit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormContent(),

                const SizedBox(height: 24),
                _buildContactDetailsContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF333333), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Get in Touch',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name Field
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),

            // Email Field
            CustomTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Mobile Field
            CustomTextField(
              controller: _mobileController,
              hintText: 'Mobile No.',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? 'Please enter your mobile number' : null,
            ),
            const SizedBox(height: 14),

            // Message Field
            CustomTextField(
              controller: _messageController,
              hintText: 'Type message here...',
              prefixIcon: Icons.message_outlined,
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 20),

            // Terms Checkbox
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() => _acceptTerms = value ?? false);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primaryButton,
                    side: const BorderSide(color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'I have read and accept terms of use.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // reCAPTCHA
            GestureDetector(
              onTap: () async {
                if (_isNotRobot || _isVerifyingCaptcha) return;
                setState(() => _isVerifyingCaptcha = true);
                await Future.delayed(const Duration(milliseconds: 1000));
                if (mounted) {
                  setState(() {
                    _isVerifyingCaptcha = false;
                    _isNotRobot = true;
                  });
                }
              },
              child: Container(
                width: double.infinity,
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
                              color: _isNotRobot ? Colors.transparent : const Color(0xFFC1C1C1),
                              width: 2,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: _isVerifyingCaptcha
                              ? const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : _isNotRobot
                                  ? const Center(child: Icon(Icons.check, size: 24, color: Colors.green))
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        const Text("I'm not a robot", style: TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                          width: 32,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.sync, color: Colors.blue.shade600, size: 28),
                        ),
                        const SizedBox(height: 4),
                        const Text('reCAPTCHA', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
                        const SizedBox(height: 2),
                        const Text('Privacy - Terms', style: TextStyle(fontSize: 8, color: Color(0xFF555555))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Send Button
            Consumer<ContactViewModel>(
              builder: (context, viewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: viewModel.isLoading ? null : _submitForm,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'SEND MESSAGE',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
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


  String _getMapHtml() {
    return '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; padding: 0; overflow: hidden; background-color: #f5f5f5; }
          iframe { 
            border: none; 
            width: 100vw; 
            height: 100vh; 
            pointer-events: none; /* Allows the Flutter GestureDetector to catch the tap */
          }
        </style>
      </head>
      <body>
        <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3022.2302699939346!2d-73.98202298428656!3d40.756959842800065!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c258fe546a63d1%3A0x5cf7574acba19823!2swickersham_jewelers!5e0!3m2!1sen!2sin!4v1556287471849!5m2!1sen!2sin" width="100%" height="500" frameborder="0" style="border:0" allowfullscreen=""></iframe>
      </body>
    </html>
  ''';
  }

  Widget _buildMapContent() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: kIsWeb
          ? HtmlWidget(_getMapHtml())
          : WebViewWidget(controller: _mapController!),
    );
  }

  Widget _buildContactDetailsContent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF000000), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Our team at Wickersham Jewelers is glad to help you out with your questions and feedback. To get in touch, fill the form above or reach us via the options below.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.6),
          ),
          const SizedBox(height: 20),
          Text(
            'Wickersham Jewelers',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          _buildContactCard(Icons.access_time_rounded, 'Monday through Friday, 10am - 6pm EST', const Color(0xFFF5F5F5), const Color(0xFF333333)),
          _buildContactCard(Icons.email_outlined, 'jeff@wickershamjewelry.com', const Color(0xFFF5F5F5), const Color(0xFF333333)),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String text, Color iconBg, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
