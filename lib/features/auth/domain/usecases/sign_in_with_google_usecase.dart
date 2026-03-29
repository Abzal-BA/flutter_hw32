import '../repositories/i_auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}
