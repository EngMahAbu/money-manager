import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/main.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/settings_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MockAccountRepository extends Mock implements AccountRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  testWidgets('Smoke test - App starts', (WidgetTester tester) async {
    final accountRepository = MockAccountRepository();
    final categoryRepository = MockCategoryRepository();
    final transactionRepository = MockTransactionRepository();
    final settingsRepository = MockSettingsRepository();

    when(() => accountRepository.watchAllAccounts()).thenAnswer((_) => Stream.value([]));
    when(() => settingsRepository.getDefaultCurrency()).thenReturn('USD');
    when(() => settingsRepository.getAppearance()).thenReturn(null);
    when(() => settingsRepository.getAppLockEnabled()).thenReturn(false);
    when(() => settingsRepository.getDailyReminderEnabled()).thenReturn(false);
    
    await tester.pumpWidget(MyApp(
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
      settingsRepository: settingsRepository,
    ));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
