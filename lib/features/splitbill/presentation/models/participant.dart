import 'package:pocketree/core/utils/string_utils.dart';

enum AssignMode { equal, byItem }

class Participant {
  final String name;
  final bool isPayer;
  final int? userId;

  const Participant({required this.name, this.isPayer = false, this.userId});

  String get initials => nameToInitials(name);

  Participant copyWith({bool? isPayer}) {
    return Participant(
      name: name,
      isPayer: isPayer ?? this.isPayer,
      userId: userId,
    );
  }
}
