import '../repositories/i_auth_repository.dart';

class SignInWithEmailParams {
  const SignInWithEmailParams({required this.email, required this.password});

  final String email;
  final String password;
}

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> call(SignInWithEmailParams params) => _repository
      .signInWithEmail(email: params.email, password: params.password);
}
