import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class RegisterParams {
  final Map<String, dynamic> userData;

  const RegisterParams(this.userData);
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Result<UserEntity>> call(RegisterParams params) async {
    return await repository.register(params.userData);
  }
}
