import 'package:firebase_auth/firebase_auth.dart';
import '../screens/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if current user is a guest
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously (guest mode)
  Future<UserCredential> signInAsGuest() async {
    try {
      print('🔓 Signing in as guest...');
      final userCredential = await _auth.signInAnonymously();
      print('✅ Guest sign-in successful: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('❌ Error signing in as guest: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear guest data before signing out
      if (isGuest) {
        UserService.clearGuestData();
      }
      
      await _auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  // Convert guest account to permanent account
  Future<UserCredential> linkGuestAccountWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!isGuest) {
        throw Exception('Current user is not a guest account');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      return await _auth.currentUser!.linkWithCredential(credential);
    } catch (e) {
      print('❌ Error linking guest account: $e');
      rethrow;
    }
  }

  // Delete guest account (for cleanup)
  Future<void> deleteGuestAccount() async {
    try {
      if (isGuest) {
        await _auth.currentUser?.delete();
        print('✅ Guest account deleted');
      }
    } catch (e) {
      print('❌ Error deleting guest account: $e');
      rethrow;
    }
  }
}