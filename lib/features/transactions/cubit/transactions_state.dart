import 'package:equatable/equatable.dart';
import '../../../data/database.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? accountIds;
  final List<int>? categoryIds;
  final String? searchQuery;

  const TransactionsLoaded({
    required this.transactions,
    this.startDate,
    this.endDate,
    this.accountIds,
    this.categoryIds,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        transactions,
        startDate,
        endDate,
        accountIds,
        categoryIds,
        searchQuery,
      ];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
