import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String name;
  final int id;
  final String email;

  const User({
    required this.name,
    required this.id,
    required this.email,
  });

  @override
  List<Object?> get props => [name, id, email];
}