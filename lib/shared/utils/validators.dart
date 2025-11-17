import '../constants/validation_messages.dart';

class Validators {
  static String? required(String? value, {String message = ValidationMessages.requiredField}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, {String message = ValidationMessages.invalidEmail}) {
    final baseValidation = required(value, message: ValidationMessages.emailRequired);
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
      message: ValidationMessages.passwordRequired,
    );
    if (baseValidation != null) {
      return baseValidation;
    }
    if (value!.trim().length < minLength) {
      return 'Must be at least $minLength characters';
    }
    if (value.length < 6) return ValidationMessages.minSixChars;

    return null;
  }
}
