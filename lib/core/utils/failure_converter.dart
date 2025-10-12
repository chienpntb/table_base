import '../errors/failures.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure _:
      return "Server Failure";
    case CacheFailure _:
      return "Cache Failure";
    case EmptyFailure _:
      return "Empty Failure";
    case CredentialFailure _:
      return "Wrong Email or Password";
    case DuplicateEmailFailure _:
      return "Email already taken";
    case PasswordNotMatchFailure _:
      return "Password not match";
    case InvalidEmailFailure _:
      return "Invalid email format";
    case InvalidPasswordFailure _:
      return "Invalid password format";
    default:
      return "Unexpected error";
  }
}
