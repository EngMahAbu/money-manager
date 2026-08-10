import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/account_repository.dart';
import '../../../data/database.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountRepository _repository;
  StreamSubscription? _subscription;

  AccountsCubit(this._repository) : super(AccountsInitial());

  void loadAccounts() {
    emit(AccountsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchAllAccounts().listen(
      (accounts) {
        final active = accounts.where((a) => !a.isArchived).toList();
        final archived = accounts.where((a) => a.isArchived).toList();
        emit(AccountsLoaded(activeAccounts: active, archivedAccounts: archived));
      },
      onError: (error) {
        emit(AccountsError(error.toString()));
      },
    );
  }

  Future<void> addAccount(AccountsCompanion account) async {
    try {
      await _repository.createAccount(account);
    } catch (e) {
      emit(AccountsError(e.toString()));
      // Optionally reload to restore previous state if needed, 
      // but stream should keep it in sync.
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _repository.updateAccount(account);
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> archiveAccount(int id) async {
    try {
      await _repository.archiveAccount(id);
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> restoreAccount(int id) async {
    try {
      await _repository.restoreAccount(id);
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
