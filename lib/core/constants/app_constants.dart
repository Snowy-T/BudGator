class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'BudGator';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Budgeting Made Simple';

  // Database
  static const String databaseName = 'budgator.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String usersTable = 'users';
  static const String budgetsTable = 'budgets';
  static const String transactionsTable = 'transactions';

  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Track Your Spending',
      'description': 'Keep an eye on where your money goes with easy-to-use expense tracking.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Set Smart Budgets',
      'description': 'Create budgets for different categories and stay on top of your finances.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Achieve Your Goals',
      'description': 'Save money effectively and reach your financial goals faster.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  // Categories
  static const List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 0xFF4CAF50},
    {'name': 'Transportation', 'icon': 'directions_car', 'color': 0xFF2196F3},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFE91E63},
    {'name': 'Entertainment', 'icon': 'movie', 'color': 0xFF9C27B0},
    {'name': 'Bills & Utilities', 'icon': 'receipt', 'color': 0xFFFF9800},
    {'name': 'Healthcare', 'icon': 'local_hospital', 'color': 0xFFF44336},
    {'name': 'Education', 'icon': 'school', 'color': 0xFF3F51B5},
    {'name': 'Other', 'icon': 'more_horiz', 'color': 0xFF607D8B},
  ];

  static const List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Salary', 'icon': 'work', 'color': 0xFF4CAF50},
    {'name': 'Freelance', 'icon': 'laptop', 'color': 0xFF2196F3},
    {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFF9C27B0},
    {'name': 'Gift', 'icon': 'card_giftcard', 'color': 0xFFE91E63},
    {'name': 'Other', 'icon': 'more_horiz', 'color': 0xFF607D8B},
  ];
}
