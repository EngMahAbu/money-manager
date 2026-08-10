import 'package:drift/drift.dart';
import '../data/daos.dart';
import '../data/database.dart';

class CategoryRepository {
  final AppDao _dao;

  CategoryRepository(this._dao);

  Stream<List<Category>> watchCategoriesByType(CategoryType type) => _dao.watchCategoriesByType(type);
  Stream<List<Category>> watchAllCategories() => _dao.watchAllCategories();
  
  Future<Category> getCategoryById(int id) => _dao.getCategoryById(id);

  Future<void> createCategory(CategoriesCompanion category) async {
    final name = category.name.value.trim();
    if (name.isEmpty) {
      throw Exception('Category name cannot be empty');
    }

    // Get the max sort order for this type to append at the end
    final currentCategories = await _dao.watchCategoriesByType(category.type.value).first;
    final maxSortOrder = currentCategories.isEmpty 
        ? -1 
        : currentCategories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);

    await _dao.insertCategory(category.copyWith(
      name: Value(name),
      sortOrder: Value(maxSortOrder + 1),
    ));
  }

  Future<void> updateCategory(Category category) async {
    final name = category.name.trim();
    if (name.isEmpty) {
      throw Exception('Category name cannot be empty');
    }

    final existingCategory = await _dao.getCategoryById(category.id);
    if (existingCategory.type != category.type) {
      final hasTransactions = await _dao.categoryHasTransactions(category.id);
      if (hasTransactions) {
        throw Exception('Category type is locked because it has transactions');
      }
    }

    await _dao.updateCategory(category.copyWith(name: name));
  }

  Future<void> archiveCategory(int id) async {
    final category = await _dao.getCategoryById(id);
    await _dao.updateCategory(category.copyWith(isArchived: true));
  }

  Future<void> restoreCategory(int id) async {
    final category = await _dao.getCategoryById(id);
    await _dao.updateCategory(category.copyWith(isArchived: false));
  }

  Future<void> reorderCategories(List<int> categoryIdsInOrder, CategoryType type) async {
    // We update all categories of this type with their new sort order
    // Scoped within type is handled by the UI providing the list of IDs for that type.
    // But we should verify they all match the type? Maybe overkill if we trust the UI/Cubit.
    
    await _dao.transaction(() async {
      for (int i = 0; i < categoryIdsInOrder.length; i++) {
        final id = categoryIdsInOrder[i];
        final cat = await _dao.getCategoryById(id);
        if (cat.type != type) continue; // Skip if type mismatch
        await _dao.updateCategory(cat.copyWith(sortOrder: i));
      }
    });
  }
}
