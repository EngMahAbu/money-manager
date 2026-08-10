// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get accounts => 'Accounts';

  @override
  String get categories => 'Categories';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get defaultCurrency => 'Default currency';

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get manage => 'Manage';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get data => 'Data';

  @override
  String get exportData => 'Export data';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get totalNetWorth => 'Total net worth';

  @override
  String get netWorth => 'Net worth';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get seeAll => 'See all';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String archivedWithCount(Object count) {
    return 'Archived ($count)';
  }

  @override
  String get restore => 'Restore';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get accountName => 'Account Name';

  @override
  String get categoryName => 'Category Name';

  @override
  String get type => 'Type';

  @override
  String get currency => 'Currency';

  @override
  String get balance => 'Balance';

  @override
  String get startingBalance => 'Starting balance';

  @override
  String get balanceHelper =>
      'Negative means money owed — matches how it\'s shown across the app';

  @override
  String get iconAndColor => 'Icon and color';

  @override
  String get archiveAccount => 'Archive account';

  @override
  String get archiveCategory => 'Archive category';

  @override
  String get bankAccount => 'Bank account';

  @override
  String get cashAccount => 'Cash';

  @override
  String get creditCardAccount => 'Credit card';

  @override
  String get savingsAccount => 'Savings';

  @override
  String get welcomeTitle => 'Welcome to Money Manager';

  @override
  String get onboardingSubtitle =>
      'To get started, you need to add your first account. This could be your cash wallet, bank account, or a credit card.';

  @override
  String get addFirstAccount => 'Add My First Account';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get incomeVsExpense => 'Income vs expense';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get balanceTrend => 'Balance trend';

  @override
  String get total => 'total';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get filters => 'Filters';

  @override
  String get reset => 'Reset';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get dateRange => 'Date range';

  @override
  String get allAccounts => 'All accounts';

  @override
  String results(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get chooseDateRange => 'Choose date range';

  @override
  String get filterByAccount => 'Filter by account';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get chooseAccount => 'Choose account';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get account => 'Account';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get apply => 'Apply';

  @override
  String get addNote => 'Add a note';

  @override
  String get receipts => 'Receipts';

  @override
  String get addAccountAction => 'Add account';

  @override
  String get addCategoryAction => 'Add category';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get clearToAccountMessage =>
      'Clear \"To\" account before changing type';

  @override
  String get clearCategoryMessage => 'Clear category before changing type';

  @override
  String get errorEmptyName => 'Name cannot be empty';

  @override
  String get errorDuplicateAccountName => 'Account name must be unique';

  @override
  String get errorLockedCurrency =>
      'Currency is locked because this account has transactions';

  @override
  String get errorLastAccount => 'Cannot archive the last active account';

  @override
  String get errorLockedCategoryType =>
      'Category type is locked because it has transactions';

  @override
  String get errorAmountZero => 'Amount must be greater than 0';

  @override
  String get errorFutureDate => 'Future dates are not allowed';

  @override
  String get errorTransferNoCategory => 'Transfers cannot have a category';

  @override
  String get errorTransferSameAccount => 'Cannot transfer to the same account';

  @override
  String get errorNoteLimit => 'Note cannot exceed 150 characters';

  @override
  String get errorReceiptLimit => 'Maximum 5 receipts allowed';
}
