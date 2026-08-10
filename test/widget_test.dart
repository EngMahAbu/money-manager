import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/main.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MockAccountRepository extends Mock implements AccountRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  testWidgets('Smoke test - App starts', (WidgetTester tester) async {
    final accountRepository = MockAccountRepository();
    final categoryRepository = MockCategoryRepository();
    final transactionRepository = MockTransactionRepository();

    when(() => accountRepository.watchAllAccounts()).thenAnswer((_) => Stream.value([]));
    
    await tester.pumpWidget(MyApp(
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
    ));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
