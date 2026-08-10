import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'daos.dart';

part 'database.g.dart';

enum AccountType { cash, bank, creditCard, savings }
enum CategoryType { income, expense }
enum TransactionType { income, expense, transfer }

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<AccountType>()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  RealColumn get startingBalance => real().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<CategoryType>()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get type => intEnum<TransactionType>()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get receipts => text().nullable()(); // Changed from receiptPhotoPath to receipts to support multiple
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get month => dateTime()(); // stored as first-of-month
  RealColumn get limitAmount => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, month}
  ];
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets], daos: [AppDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Seed default categories
          final expenseCategories = [
            'Groceries',
            'Rent & housing',
            'Utilities',
            'Transport',
            'Dining out',
            'Entertainment',
            'Health',
            'Shopping',
            'Subscriptions',
            'Travel',
            'Education',
            'Other',
          ];

          final expenseIcons = [
            'shopping-cart',
            'home',
            'bolt',
            'car',
            'tools-kitchen-2',
            'movie',
            'heartbeat',
            'shopping-bag',
            'repeat',
            'plane',
            'book',
            'dots',
          ];

          for (var i = 0; i < expenseCategories.length; i++) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                name: expenseCategories[i],
                type: CategoryType.expense,
                icon: Value(expenseIcons[i]),
                sortOrder: Value(i),
              ),
            );
          }

          final incomeCategories = [
            'Salary',
            'Freelance',
            'Gifts',
            'Investments',
            'Other income',
          ];

          final incomeIcons = [
            'briefcase',
            'laptop',
            'gift',
            'trending-up',
            'dots',
          ];

          for (var i = 0; i < incomeCategories.length; i++) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                name: incomeCategories[i],
                type: CategoryType.income,
                icon: Value(incomeIcons[i]),
                sortOrder: Value(i),
              ),
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
