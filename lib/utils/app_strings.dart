/// Central repository for all application strings
/// This class contains all hardcoded strings used throughout the app
/// to enable easy localization and maintenance
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // App Navigation & Routes
  static const String routeLogin = '/';
  static const String routeWallet = '/wallet';
  static const String routeTransaction = '/transaction';
  static const String routeHistory = '/history';

  // Page Titles
  static const String titleLogin = 'Login';
  static const String titleWallet = 'Wallet';
  static const String titleSendMoney = 'Send Money';
  static const String titleTransactionHistory = 'Transaction History';
  static const String titleMenu = 'Menu';
  static const String appTitle = 'Maya Exam';

  // Button Labels
  static const String buttonLogin = 'Login';
  static const String buttonSendMoney = 'Send Money';
  static const String buttonViewTransactions = 'View Transactions';
  static const String buttonRetry = 'Retry';
  static const String buttonCancel = 'Cancel';
  static const String buttonLogout = 'Logout';

  // Form Labels
  static const String labelEmail = 'Email';
  static const String labelPassword = 'Password';
  static const String labelRecipientEmail = 'Recipient Email';
  static const String labelEnterAmount = 'Enter Amount';

  // Currency & Formatting
  static const String currencySymbol = '₱';
  static const String balanceHidden = '••••••';

  // Error Messages
  static const String errorLoginFailed = 'Login failed';
  static const String errorEnterEmailPassword =
      'Please enter both email and password';
  static const String errorEnterRecipientEmail =
      'Please enter recipient email address.';
  static const String errorEnterValidAmount = 'Please enter a valid amount.';
  static const String errorUserNotAuthenticated = 'User not authenticated.';
  static const String errorLoadingTransactions = 'Error loading transactions';
  static const String errorBalanceNotFound = 'User balance not found';
  static const String errorInsufficientBalance = 'Insufficient balance';
  static const String errorFailedCreateBalance = 'Failed to create balance';
  static const String errorAmountGreaterThanZero =
      'Amount must be greater than zero';
  static const String errorSenderBalanceNotFound = 'Sender balance not found';
  static const String errorRecipientNotFound =
      'Recipient with email "{email}" not found.';
  static const String errorCannotSendToSelf = 'Cannot send money to yourself';
  static const String errorFailedCreateRecipientBalance =
      'Failed to create recipient balance';
  static const String errorTransactionFailed = 'Transaction failed: {error}';
  static const String errorFailedLoadTransactionHistory =
      'Failed to load transaction history: {error}';
  static const String errorPrefix = 'Error: ';

  // Success Messages
  static const String successTransactionSent =
      'Successfully sent {currency}{amount} to {email}';

  // Info Messages
  static const String noBalanceData = 'No balance data';
  static const String noTransactionsFound = 'No transactions found';
  static const String noEmailAvailable = 'No email available';
  static const String transactionHistoryHint =
      'Your transaction history will appear here';
  static const String loadingTransactions =
      'Please wait while we load your transactions...';

  // Transaction Types & Status
  static const String transactionTypeReceived = 'Received';
  static const String transactionTypeSent = 'Sent';

  // Date Formatting
  static const String dateToday = 'Today at {time}';
  static const String dateYesterday = 'Yesterday at {time}';

  // Transaction Descriptions
  static const String transactionDescriptionDefault = 'Money transfer';
  static const String transactionDescriptionSent =
      'Sent to {email}: {description}';
  static const String transactionDescriptionReceived =
      'Received from {email}: {description}';

  // Dialog Messages
  static const String dialogLogoutTitle = 'Logout';
  static const String dialogLogoutContent = 'Are you sure you want to logout?';

  // Menu Items
  static const String menuTransactionHistory = 'Transaction History';

  // Regex Patterns
  static const String regexAmountPattern = r'^\d*\.?\d{0,2}';

  // Debug/Log Tags
  static const String tagAppRouter = 'AppRouter';
  static const String tagBalanceBloc = 'BalanceBloc';
  static const String tagTransactionBloc = 'TransactionBloc';

  // Router Messages
  static const String routerRedirectingToLogin = 'Redirecting to login';
  static const String routerRedirectingToWallet = 'Redirecting to wallet';
  static const String routerNoRedirectNeeded = 'No redirect needed';
  static const String routerLocationAuth =
      'Router redirect - Location: {location}, Auth Status: {status}';

  // Balance Messages
  static const String balanceNoBalanceFound =
      'No balance found for user: {uid}';
  static const String balanceGettingCurrent =
      'Getting current balance for UID: {uid}';
  static const String balanceFoundExisting = 'Found existing balance: {amount}';
  static const String balanceCreatingInitial =
      'No balance found for user: {uid}, creating initial balance';
  static const String balanceSuccessfullyCreated =
      'Successfully created balance: {amount}';
  static const String balanceStartingWatch =
      'Starting WatchBalance for UID: {uid}';
  static const String balanceCheckingExists =
      'Checking if balance exists for UID: {uid}';
  static const String balanceNoExistingFound =
      'No existing balance found, creating new balance';
  static const String balanceStartingRealTime =
      'Starting real-time balance watcher';
  static const String balanceReceivedUpdate =
      'Received balance update: {amount}';
  static const String balanceReceivedNull =
      'Received null balance from watcher';

  // Transaction Messages
  static const String transactionLookingForRecipient =
      'Looking for recipient with email: {email}';
  static const String transactionRecipientNotFound =
      'Recipient not found in database';
  static const String transactionFoundRecipient = 'Found recipient: {uid}';

  // Helper method to replace placeholders in strings
  static String formatString(String template, Map<String, String> values) {
    String result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  // Commonly used formatted strings
  static String formatCurrency(double amount) =>
      '$currencySymbol${amount.toStringAsFixed(2)}';

  static String formatError(String message) => '$errorPrefix$message';

  static String formatRecipientNotFound(String email) =>
      formatString(errorRecipientNotFound, {'email': email});

  static String formatTransactionSent(double amount, String email) =>
      formatString(successTransactionSent, {
        'currency': currencySymbol,
        'amount': amount.toStringAsFixed(2),
        'email': email,
      });

  static String formatTransactionFailed(String error) =>
      formatString(errorTransactionFailed, {'error': error});

  static String formatTransactionHistoryFailed(String error) =>
      formatString(errorFailedLoadTransactionHistory, {'error': error});

  static String formatDateToday(String time) =>
      formatString(dateToday, {'time': time});

  static String formatDateYesterday(String time) =>
      formatString(dateYesterday, {'time': time});
}
