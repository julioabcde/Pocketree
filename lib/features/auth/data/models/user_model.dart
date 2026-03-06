

import 'package:pocketree/features/auth/domain/entities/user.dart';

class UserModel {
  final String name;
  final int id;
  final String email;

  UserModel({
    required this.name,
    required this.id,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String, 
    );
  }

  User toEntity(){
    return User(
      name: name,
      id: id,
      email: email,
    );
  }
}