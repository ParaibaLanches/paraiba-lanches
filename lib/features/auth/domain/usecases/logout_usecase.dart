import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Result<void>> call(NoParams params) async {
    return await repository.logout();
  }
}
