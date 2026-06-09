import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_auth_repository.dart';

class UpdateAvatarParams {
  final String filePath;

  const UpdateAvatarParams(this.filePath);
}

class UpdateAvatarUseCase implements UseCase<String, UpdateAvatarParams> {
  final IAuthRepository repository;

  UpdateAvatarUseCase(this.repository);

  @override
  Future<Result<String>> call(UpdateAvatarParams params) async {
    return await repository.updateAvatar(params.filePath);
  }
}
