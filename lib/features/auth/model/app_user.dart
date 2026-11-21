import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;
  String get firstName {
    final name = displayName?.trim() ?? '';
    if (name.isNotEmpty) return name.split(RegExp(r'\s+')).first;
    final localPart = email?.split('@').first ?? '';
    return localPart.isNotEmpty ? localPart : 'there';
  }

  String get initial => firstName.substring(0, 1).toUpperCase();

  @override
  List<Object?> get props => [uid, email, displayName];
}