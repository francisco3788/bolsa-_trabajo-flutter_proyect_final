class Validators {
  static String? required(String? value, {String message = 'Campo requerido'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, {String message = 'Correo inválido'}) {
    final baseValidation = required(value, message: 'El correo es obligatorio');
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
      message: 'La contraseña es obligatoria',
    );
    if (baseValidation != null) {
      return baseValidation;
    }
    if (value!.trim().length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    if (value.length < 6) return 'Mínimo 6 caracteres';

    return null;
  }
}
