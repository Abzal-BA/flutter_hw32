import '../repositories/i_auth_repository.dart';

class UpdateDisplayNameUseCase {
  const UpdateDisplayNameUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call(String displayName) =>
      _repository.updateDisplayName(displayName);
}
