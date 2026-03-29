import '../repositories/i_auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call(String email) => _repository.sendPasswordReset(email);
}
