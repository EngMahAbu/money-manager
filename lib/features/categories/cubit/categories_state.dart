import 'package:equatable/equatable.dart';
import '../../../data/database.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  final List<Category> archivedCategories;

  const CategoriesLoaded({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.archivedCategories,
  });

  @override
  List<Object?> get props => [incomeCategories, expenseCategories, archivedCategories];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
