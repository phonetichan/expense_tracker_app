import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserRepository {
  final FirebaseFirestore _firestore;
  UserRepository(this._firestore);

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String themeMode, // Added themeMode parameter
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'themeMode': themeMode, // Use the provided theme mode
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateTheme({
    required String uid,
    required String themeMode,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'themeMode': themeMode,
    });
  }
}
