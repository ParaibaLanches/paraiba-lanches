class AppValidators {
  /// Validates if a field is not null or empty
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  /// Validates phone number (DDD + 9 digits)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 11) {
      return 'Informe um telefone válido com DDD';
    }
    return null;
  }

  /// Validates CPF (11 digits)
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Allow standard placeholder if needed (based on previous logic)
    if (digits == '00000000000') return null;

    if (digits.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  /// Validates full name (min 3 characters)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Informe seu nome completo';
    }
    return null;
  }

  /// Validates password strength (min characters)
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < minLength) {
      return 'A senha deve ter pelo menos $minLength caracteres';
    }
    return null;
  }
}
