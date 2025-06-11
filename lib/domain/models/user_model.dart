import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? fullName;
  final String? housing;
  final String? phone;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.fullName,
    this.housing,
    this.phone,
  });
  // Factory constructor from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  // fromJson
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      fullName: json['fullName'] as String?,
      housing: json['housing'] as String?,
      phone: json['phone'] as String?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'housing': housing,
      'phone': phone,
    };
  }
}
