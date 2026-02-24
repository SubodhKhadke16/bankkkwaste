import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/email_service.dart';
import '../services/otp_service.dart';
import '../services/user_service.dart';
import 'auth/profile_setup_screen.dart';
import 'home_clean.dart';

/// Email OTP Login Screen
/// 
/// Flow:
/// 1. User enters email
/// 2. OTP sent via email (EmailJS)
/// 3. User enters OTP
/// 4. OTP verified from Firestore
/// 5. User authenticated with Firebase
class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({Key? key}) : super(key: key);

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _sentOtp; // Store OTP for debugging (remove in production)

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!EmailService.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  /// Send OTP via email using EmailJS
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    // Send OTP via email
    final otp = await EmailService.sendOTPEmail(email: email);

    if (otp == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please check your email and EmailJS setup.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Store OTP in Firestore
    final stored = await OtpService.storeOTP(
      email: email,
      otp: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!stored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to store OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _otpSent = true;
      _sentOtp = otp; // For debugging
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to $email\nCheck your inbox/spam folder'),
        backgroundColor: WastecColors.primaryGreen,
        duration: const Duration(seconds: 5),
      ),
    );

    // Debug: Print OTP to console
    print('🔑 OTP sent: $otp (5 min expiry)');
  }

  /// Verify OTP and authenticate user
  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    // Verify OTP from Firestore
    final verified = await OtpService.verifyOTP(
      email: email,
      otp: otp,
    );

    if (!verified) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or expired OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Authenticate user with Firebase
    print('🔐 Starting authentication process...');
    final user = await OtpService.authenticateUser(email: email);

    if (!mounted) return;

    if (user == null) {
      setState(() => _isLoading = false);
      print('❌ Authentication returned null user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Authentication failed!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Please ensure Email/Password authentication is enabled in Firebase Console.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Check if user profile exists in Firestore
    final userId = user.uid;
    print('\n👤 ========== POST-AUTHENTICATION FLOW ==========');
    print('   Authenticated user ID: $userId');
    print('   User email: ${user.email}');
    print('   Now checking if profile is complete...');
    
    final profileExists = await UserService.userProfileExists(userId);
    
    print('📊 Profile completeness result: $profileExists');
    print('================================================\n');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!profileExists) {
      // New user - Show profile setup screen
      print('🎯 DECISION: Show PROFILE SETUP screen');
      print('   Reason: Profile incomplete (missing name/phone)');
      print('   User ID: $userId');
      print('   Email: $email\n');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Verification successful! Complete your profile.'),
            ],
          ),
          backgroundColor: WastecColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );

      print('🚀 Navigating to ProfileSetupScreen...\n');
      
      // Use post-frame callback to ensure navigation happens after widget tree updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ProfileSetupScreen(
                userId: userId,
                email: email,
              ),
            ),
            (route) => false,
          );
        }
      });
    } else {
      // Existing user - Navigate to home
      print('🎯 DECISION: Navigate to HOME screen');
      print('   Reason: Profile complete (has name & phone)');
      print('   User ID: $userId\n');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Welcome back!'),
            ],
          ),
          backgroundColor: WastecColors.primaryGreen,
        ),
      );

      print('🚀 Navigating to HomeScreen...\n');
      
      // Use post-frame callback to ensure navigation happens after widget tree updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(isLoggedIn: true),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Email Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the OTP sent to your email'
                      : 'Enter your email to receive OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_otpSent,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'your.email@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: WastecColors.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: WastecColors.primaryGreen, width: 2),
                    ),
                    filled: _otpSent,
                    fillColor: _otpSent ? Colors.grey[100] : null,
                  ),
                ),
                const SizedBox(height: 24),

                // OTP Field (shown after OTP sent)
                if (_otpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: _validateOTP,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '6-digit code',
                      prefixIcon: const Icon(Icons.lock_outline, color: WastecColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: WastecColors.primaryGreen, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Debug info (remove in production)
                  if (_sentOtp != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Debug: Your OTP is $_sentOtp (check email too)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Send/Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent ? _verifyOTP : _sendOTP),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WastecColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _otpSent ? 'Verify OTP' : 'Send OTP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Resend OTP (shown after OTP sent)
                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                      child: const Text(
                        'Change Email',
                        style: TextStyle(
                          color: WastecColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Enter your email address\n'
                        '2. You\'ll receive a 6-digit OTP\n'
                        '3. Enter the OTP to login\n'
                        '4. OTP expires in 5 minutes',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
