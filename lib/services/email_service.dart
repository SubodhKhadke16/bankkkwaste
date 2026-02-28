import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmailService {
  // ======================================
  // EmailJS Credentials - Configured ✅
  // ======================================
  static const String _serviceId = 'service_7iutvac';
  static const String _templateId = 'template_15w25ei';
  static const String _publicKey = 'LESwencpSnlezJOsi';
  
  /// Generate a 6-digit OTP
  static String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  /// Send OTP via email using EmailJS
  /// 
  /// Returns the OTP if successful, null otherwise
  static Future<String?> sendOTPEmail({
    required String email,
  }) async {
    try {
      final otp = _generateOTP();
      
      print('📧 Sending OTP to: $email');
      print('   OTP: $otp');
      
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': email,
            'otp_code': otp,
            'app_name': 'Wastec Bank',
          },
        }),
      );
      
      print('📡 EmailJS Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ OTP sent successfully via email');
        return otp;
      } else if (response.statusCode == 400) {
        print('❌ EmailJS Error: Bad request - Check credentials');
        return null;
      } else if (response.statusCode == 403) {
        print('❌ EmailJS Error: Invalid public key');
        return null;
      } else {
        print('❌ EmailJS Error: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Exception sending email OTP: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
