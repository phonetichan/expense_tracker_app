import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel implements UserEntity {
  const factory UserModel({
    required String uid,
    required String name,
    required String email,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
    );
  }

  factory UserModel.fromFirebaseDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;

    return UserModel(
      uid: document.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
    );
  }

  @override
  // TODO: implement email
  String get email => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement uid
  String get uid => throw UnimplementedError();
}

