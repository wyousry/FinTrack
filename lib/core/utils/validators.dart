class Validators {
  Validators._();

  static const int minPasswordLength = 8;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? termsAccepted(bool? value) {
    if (value != true) {
      return 'Please agree to the Terms of Service and Privacy Policy';
    }
    return null;
  }
static double? parseAmount(String? value) {
  final cleaned = (value ?? '').trim().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  final parsed = double.tryParse(cleaned);
  return parsed != null && parsed.isFinite ? parsed : null;
}

static const double maxAmount = 1000000000;

static String? goalName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Goal name is required';
  if (v.length > 40) return 'Name is too long (max 40 characters)';
  return null;
}

static String? positiveAmount(String? value) {
  final amount = parseAmount(value);
  if (amount == null) return 'Enter a valid amount';
  if (amount <= 0) return 'Amount must be greater than zero';
  if (amount > maxAmount) return 'Amount is too large';
  return null;
}

static String? optionalAmount(String? value) {
  if ((value ?? '').trim().isEmpty) return null;
  final amount = parseAmount(value);
  if (amount == null) return 'Enter a valid amount';
  if (amount < 0) return 'Amount cannot be negative';
  if (amount > maxAmount) return 'Amount is too large';
  return null;
}
}