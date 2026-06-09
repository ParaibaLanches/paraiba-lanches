import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class CheckAuthUseCase implements UseCase<UserEntity?, NoParams> {
  final IAuthRepository repository;

  CheckAuthUseCase(this.repository);

  @override
  Future<Result<UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
