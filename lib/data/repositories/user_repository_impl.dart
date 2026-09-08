import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  UserRepositoryImpl(this._firestore);

  @override
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
