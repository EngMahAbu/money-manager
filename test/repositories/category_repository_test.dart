import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/database.dart';
import 'package:money_manager/data/daos.dart';
import 'package:money_manager/repositories/category_repository.dart';

void main() {
  late AppDatabase db;
  late AppDao dao;
  late CategoryRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    dao = AppDao(db);
    repository = CategoryRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepository', () {
    test('createCategory sets correct sort order', () async {
      final initialCategories = await repository.watchCategoriesByType(CategoryType.expense).first;
      final initialCount = initialCategories.length;
      final maxSortOrder = initialCategories.isEmpty 
          ? -1 
          : initialCategories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);

      await repository.createCategory(CategoriesCompanion.insert(
        name: 'First',
        type: CategoryType.expense,
      ));
      await repository.createCategory(CategoriesCompanion.insert(
        name: 'Second',
        type: CategoryType.expense,
      ));

      final categories = await repository.watchCategoriesByType(CategoryType.expense).first;
      expect(categories.length, initialCount + 2);
      
      final first = categories.firstWhere((c) => c.name == 'First');
      final second = categories.firstWhere((c) => c.name == 'Second');
      
      expect(first.sortOrder, maxSortOrder + 1);
      expect(second.sortOrder, maxSortOrder + 2);
    });

    test('updateCategory locks type if transactions exist', () async {
      await repository.createCategory(CategoriesCompanion.insert(
        name: 'Food',
        type: CategoryType.expense,
      ));

      final category = (await repository.watchCategoriesByType(CategoryType.expense).first).first;

      // Add a transaction
      await dao.insertTransaction(TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.expense,
        amount: 50.0,
        date: DateTime.now(),
        categoryId: Value(category.id),
      ));

      final updatedCategory = category.copyWith(type: CategoryType.income);
      expect(() => repository.updateCategory(updatedCategory), throwsException);
    });
  });
}
