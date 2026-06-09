import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class UpdateProfileParams {
  final Map<String, dynamic> data;

  const UpdateProfileParams(this.data);
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final IAuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Result<UserEntity>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.data);
  }
}
