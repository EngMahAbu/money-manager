import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/categories/cubit/categories_cubit.dart';
import 'package:money_manager/features/categories/cubit/categories_state.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/data/database.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late CategoryRepository repository;
  late CategoriesCubit cubit;

  setUp(() {
    repository = MockCategoryRepository();
    cubit = CategoriesCubit(repository);
  });

  final mockCategories = [
    Category(id: 1, name: 'Income', type: CategoryType.income, isArchived: false, sortOrder: 0),
    Category(id: 2, name: 'Expense', type: CategoryType.expense, isArchived: false, sortOrder: 0),
    Category(id: 3, name: 'Archived', type: CategoryType.expense, isArchived: true, sortOrder: 1),
  ];

  group('CategoriesCubit', () {
    blocTest<CategoriesCubit, CategoriesState>(
      'loadCategories emits [CategoriesLoading, CategoriesLoaded] on success',
      build: () {
        when(() => repository.watchAllCategories()).thenAnswer((_) => Stream.value(mockCategories));
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        CategoriesLoading(),
        CategoriesLoaded(
          incomeCategories: [mockCategories[0]],
          expenseCategories: [mockCategories[1]],
          archivedCategories: [mockCategories[2]],
        ),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'loadCategories emits [CategoriesLoading, CategoriesError] on error',
      build: () {
        when(() => repository.watchAllCategories()).thenAnswer((_) => Stream.error('Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        CategoriesLoading(),
        const CategoriesError('Error'),
      ],
    );
  });
}
