class Validators {
  static String? required(String? value, {String message = 'Required field'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, {String message = 'Invalid email'}) {
    final baseValidation = required(value, message: 'Email is required');
    if (baseValidation != null) {
      return baseValidation;
    }
    const emailPattern = r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$";
    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(value!.trim())) {
      return message;
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final baseValidation = required(
      value,
      message: 'Password is required',
    );
    if (baseValidation != null) {
      return baseValidation;
    }
    if (value!.trim().length < minLength) {
      return 'Must be at least $minLength characters';
    }
    if (value.length < 6) return 'Minimum 6 characters';

    return null;
  }
}
