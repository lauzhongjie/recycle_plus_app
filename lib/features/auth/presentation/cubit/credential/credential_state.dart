part of 'credential_cubit.dart';

abstract class CredentialState extends Equatable {
  const CredentialState();
}

final class CredentialInitial extends CredentialState {
  @override
  List<Object> get props => [];
}

final class CredentialLoading extends CredentialState {
  @override
  List<Object> get props => [];
}

final class CredentialSuccess extends CredentialState {
  @override
  List<Object> get props => [];
}

class CredentialFailure extends CredentialState {
  final String errorMessage;

  const CredentialFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

