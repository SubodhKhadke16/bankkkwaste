import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP Verification Service
/// Handles OTP storage, verification, and user authentication
class OtpService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Store OTP in Firestore with 5-minute expiry
  /// 
  /// Uses email as document ID for easy lookup
  static Future<bool> storeOTP({
    required String email,
    required String otp,
  }) async {
    try {
      print('💾 Storing OTP in Firestore');
      print('   Email: $email');
      print('   OTP: $otp');
      
      final expiryTime = DateTime.now().add(const Duration(minutes: 5));
      
      await _firestore.collection('otp_verifications').doc(email).set({
        'otp': otp,
        'email': email,
        'expiryTime': Timestamp.fromDate(expiryTime),
        'used': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ OTP stored successfully');
      print('   Expires at: ${expiryTime.toLocal()}');
      
      return true;
    } catch (e, stackTrace) {
      print('❌ Error storing OTP: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Verify OTP from Firestore
  /// 
  /// Checks:
  /// 1. OTP exists
  /// 2. OTP matches
  /// 3. OTP not expired
  /// 4. OTP not already used
  static Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔍 Verifying OTP from Firestore');
      print('   Email: $email');
      print('   Entered OTP: $otp');
      
      final doc = await _firestore.collection('otp_verifications').doc(email).get();
      
      if (!doc.exists) {
        print('❌ No OTP found for this email');
        return false;
      }
      
      final data = doc.data()!;
      final storedOtp = data['otp'];
      final expiryTime = (data['expiryTime'] as Timestamp).toDate();
      final used = data['used'] ?? false;
      
      print('   Stored OTP: $storedOtp');
      print('   Expiry: ${expiryTime.toLocal()}');
      print('   Used: $used');
      
      // Check if already used
      if (used) {
        print('❌ OTP already used');
        return false;
      }
      
      // Check expiry
      if (DateTime.now().isAfter(expiryTime)) {
        print('❌ OTP expired');
        return false;
      }
      
      // Check OTP match
      if (storedOtp != otp) {
        print('❌ OTP mismatch');
        return false;
      }
      
      // Mark as used
      await _firestore.collection('otp_verifications').doc(email).update({
        'used': true,
        'usedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ OTP verified successfully');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error verifying OTP: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Authenticate user after OTP verification
  /// 
  /// Checks if user exists by email, reuses existing account or creates new one
  static Future<User?> authenticateUser({
    required String email,
  }) async {
    try {
      print('🔐 Authenticating user with Firebase');
      print('   Email: $email');
      
      // Generate consistent password for this email
      final dummyPassword = _generateDummyPassword(email);
      User? user;
      
      // Try to sign in first (for existing users)
      try {
        print('🔑 Attempting to sign in existing user...');
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: dummyPassword,
        );
        user = credential.user;
        print('✅ Signed in existing user!');
        print('   User ID: ${user?.uid}');
        
        // Update last login time
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'updatedAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
          print('✅ Updated last login timestamp');
        }
        
        return user;
      } on FirebaseAuthException catch (signInError) {
        print('⚠️ Sign in failed: ${signInError.code}');
        
        // If user-not-found, create new account
        if (signInError.code == 'user-not-found' || 
            signInError.code == 'invalid-credential' ||
            signInError.code == 'invalid-email') {
          print('📝 User not found, creating new account...');
          
          try {
            // Create new user with email/password
            final credential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: dummyPassword,
            );
            user = credential.user;
            
            if (user != null) {
              print('✅ New Firebase Auth user created!');
              print('   User ID: ${user.uid}');
              print('   Email: ${user.email}');
              print('   This is a NEW user - profile will be incomplete');
              
              // Create minimal Firestore document (NO name or phone)
              // This ensures userProfileExists() returns false
              await _firestore.collection('users').doc(user.uid).set({
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
                'loginMethod': 'email_otp',
              }, SetOptions(merge: false)); // Don't merge, create new
              
              print('✅ Minimal user document created in Firestore');
              print('   Document will be completed in profile setup');
              
              // Verify document was created
              final doc = await _firestore.collection('users').doc(user.uid).get();
              print('🔍 Verification: Document exists = ${doc.exists}');
              if (doc.exists) {
                final data = doc.data();
                print('   Has name field: ${data?.containsKey('name')}');
                print('   Has phone field: ${data?.containsKey('phone')}');
              }
            }
            
            return user;
          } on FirebaseAuthException catch (createError) {
            print('❌ Failed to create user: ${createError.code}');
            print('   Error message: ${createError.message}');
            
            // Check if it's because email/password is not enabled
            if (createError.code == 'operation-not-allowed') {
              print('⚠️⚠️⚠️ CRITICAL ERROR ⚠️⚠️⚠️');
              print('Email/Password authentication is NOT enabled in Firebase Console!');
              print('Go to: Firebase Console > Authentication > Sign-in method');
              print('Enable: Email/Password provider');
            }
            
            return null;
          } catch (e) {
            // Handle type casting error (Pigeon SDK issue)
            print('⚠️ Caught general error during user creation: $e');
            print('   This might be a Firebase SDK serialization issue');
            print('   Checking if user was actually created...');
            
            // Wait for Firebase to process the auth state change
            // Increased delay to ensure everything settles
            await Future.delayed(const Duration(milliseconds: 1000));
            
            // Check if current user is now set
            final currentUser = _auth.currentUser;
            if (currentUser != null && currentUser.email == email) {
              print('✅ User WAS created despite error!');
              print('   User ID: ${currentUser.uid}');
              print('   Email: ${currentUser.email}');
              
              // Create minimal Firestore document
              try {
                await _firestore.collection('users').doc(currentUser.uid).set({
                  'email': email,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                  'loginMethod': 'email_otp',
                }, SetOptions(merge: false));
                
                print('✅ Minimal user document created in Firestore');
                
                // Wait a bit more for Firestore to sync
                await Future.delayed(const Duration(milliseconds: 300));
                
                // Verify document
                final doc = await _firestore.collection('users').doc(currentUser.uid).get();
                print('🔍 Verification: Document exists = ${doc.exists}');
                if (doc.exists) {
                  final data = doc.data();
                  print('   Has name field: ${data?.containsKey('name')}');
                  print('   Has phone field: ${data?.containsKey('phone')}');
                } else {
                  print('⚠️ Document not found yet, might need time to sync');
                }
              } catch (firestoreError) {
                print('⚠️ Error creating Firestore document: $firestoreError');
              }
              
              print('✅ Returning user object for profile check');
              return currentUser;
            } else {
              print('❌ User was NOT created');
              return null;
            }
          }
        } else {
          // Other sign-in errors
          print('❌ Unexpected sign-in error: ${signInError.code}');
          print('   Message: ${signInError.message}');
          return null;
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error in authenticateUser: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Generate a consistent dummy password for OTP-based email accounts
  /// This allows users to login with the same account each time
  static String _generateDummyPassword(String email) {
    // Use a hash of the email + a secret salt for consistency
    // In production, you might want to use a more secure method
    return 'OTP_${email.hashCode.abs()}_SECURE_2026';
  }

  /// Delete OTP document (cleanup)
  static Future<void> deleteOTP(String email) async {
    try {
      await _firestore.collection('otp_verifications').doc(email).delete();
      print('🗑️ OTP document deleted for: $email');
    } catch (e) {
      print('⚠️ Error deleting OTP: $e');
    }
  }
}
