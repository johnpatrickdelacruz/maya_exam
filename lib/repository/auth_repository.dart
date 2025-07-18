import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/debug_utils.dart';

abstract class AuthRepositoryInterface {
  Stream<User?> get authStateChanges;
  UserModel? getCurrentUser();
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserModel?> findUserByEmail(String email);
}

class AuthRepository implements AuthRepositoryInterface {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = credential.user!;

        // Save/update user data in Firestore for user lookup
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email?.toLowerCase(),
          'displayName': user.displayName,
          'emailVerified': user.emailVerified,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return UserModel.fromFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      DebugUtils.debugPrint('Searching for user with email: $normalizedEmail',
          tag: 'AuthRepository');
      // Query Firestore to find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      DebugUtils.debugPrint(
          'Query returned ${querySnapshot.docs.length} documents',
          tag: 'AuthRepository');

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        DebugUtils.debugPrint('Found user data: $data', tag: 'AuthRepository');
        return UserModel(
          uid: doc.id,
          email: data['email'] ?? '',
          displayName: data['displayName'],
          emailVerified: data['emailVerified'] ?? false,
        );
      }
      DebugUtils.debugPrint('No user found with email: $normalizedEmail',
          tag: 'AuthRepository');
      return null;
    } catch (e) {
      DebugUtils.errorPrint('Error finding user by email: $e',
          tag: 'AuthRepository');
      return null;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
