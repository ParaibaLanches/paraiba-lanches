abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocorreu um erro no servidor.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// A simple Result class for Clean Architecture returns, avoiding heavy dependencies like dartz.
class Result<T> {
  final T? _value;
  final Failure? _failure;

  const Result.success(this._value) : _failure = null;
  const Result.failure(this._failure) : _value = null;

  bool get isSuccess => _value != null;
  bool get isFailure => _failure != null;

  T get value => _value!;
  Failure get failure => _failure!;

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) {
    if (isFailure) {
      return onFailure(failure);
    } else {
      return onSuccess(value);
    }
  }
}
