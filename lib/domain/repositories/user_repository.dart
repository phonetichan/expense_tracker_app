import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRepository {
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  });

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid);
}
