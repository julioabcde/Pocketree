

import 'package:pocketree/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;

  UserModel({
    required this.id,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String, 
    );
  }

  User toEntity(){
    return User(
      id: id,
      email: email,
    );
  }
}