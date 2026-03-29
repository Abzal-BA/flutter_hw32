import '../repositories/i_auth_repository.dart';

class RegisterWithEmailParams {
  const RegisterWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call(RegisterWithEmailParams params) =>
      _repository.registerWithEmail(
        email: params.email,
        password: params.password,
        displayName: params.displayName,
      );
}
