import 'package:equatable/equatable.dart';
import '../../../data/database.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> activeAccounts;
  final List<Account> archivedAccounts;

  const AccountsLoaded({
    required this.activeAccounts,
    required this.archivedAccounts,
  });

  @override
  List<Object?> get props => [activeAccounts, archivedAccounts];
}

class AccountsError extends AccountsState {
  final String message;

  const AccountsError(this.message);

  @override
  List<Object?> get props => [message];
}
