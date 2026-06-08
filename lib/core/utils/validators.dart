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

  /// Validates CPF (11 digits + mathematical verification)
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Ignore known invalid sequences
    if (RegExp(r'^(\d)\1*$').hasMatch(digits)) {
      return 'CPF inválido';
    }

    // Validação matemática do CPF (Dígitos verificadores)
    List<int> numbers = digits.split('').map((e) => int.parse(e)).toList();

    int sum1 = 0;
    for (int i = 0; i < 9; i++) {
      sum1 += numbers[i] * (10 - i);
    }
    int digit1 = 11 - (sum1 % 11);
    if (digit1 >= 10) digit1 = 0;

    int sum2 = 0;
    for (int i = 0; i < 10; i++) {
      sum2 += numbers[i] * (11 - i);
    }
    int digit2 = 11 - (sum2 % 11);
    if (digit2 >= 10) digit2 = 0;

    if (numbers[9] != digit1 || numbers[10] != digit2) {
      return 'CPF inválido';
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
