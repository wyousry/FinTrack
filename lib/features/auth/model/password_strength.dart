
import 'package:fintrack/core/utils/validators.dart';

enum PasswordStrength {
  none('None'),
  weak('Weak'),
  fair('Fair'),
  good('Good'),
  strong('Strong');

  const PasswordStrength(this.label);

  final String label;
  int get level => index;

  static PasswordStrength fromPassword(String password) {
    if (password.isEmpty) return none;
    if (password.length < Validators.minPasswordLength) return weak;

    var score = 1;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return values[score]; 
  }
}