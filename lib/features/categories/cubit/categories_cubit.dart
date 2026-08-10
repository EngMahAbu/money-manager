import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/category_repository.dart';
import '../../../data/database.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;
  StreamSubscription? _subscription;

  CategoriesCubit(this._repository) : super(CategoriesInitial());

  void loadCategories() {
    emit(CategoriesLoading());
    _subscription?.cancel();
    _subscription = _repository.watchAllCategories().listen(
      (categories) {
        final income = categories.where((c) => !c.isArchived && c.type == CategoryType.income).toList();
        final expense = categories.where((c) => !c.isArchived && c.type == CategoryType.expense).toList();
        final archived = categories.where((c) => c.isArchived).toList();
        emit(CategoriesLoaded(
          incomeCategories: income,
          expenseCategories: expense,
          archivedCategories: archived,
        ));
      },
      onError: (error) {
        emit(CategoriesError(error.toString()));
      },
    );
  }

  Future<void> addCategory(CategoriesCompanion category) async {
    try {
      await _repository.createCategory(category);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> archiveCategory(int id) async {
    try {
      await _repository.archiveCategory(id);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> restoreCategory(int id) async {
    try {
      await _repository.restoreCategory(id);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> reorderCategories(List<int> categoryIdsInOrder, CategoryType type) async {
    try {
      await _repository.reorderCategories(categoryIdsInOrder, type);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
