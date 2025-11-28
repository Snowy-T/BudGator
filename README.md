# BudGator

A modern Flutter budgeting app with a clean, green-themed UI for tracking expenses, managing budgets, and achieving financial goals.

## Features

- **Onboarding Flow**: Beautiful introduction screens for new users
- **User Authentication**: Login screen with demo account option
- **Dashboard**: Overview of finances with charts and summaries
- **Budget Management**: Create and track budgets by category
- **Transaction Tracking**: Add, view, and categorize transactions
- **Expense Charts**: Visual breakdown of spending by category
- **Modern UI**: Green nature-inspired theme with Material 3 design

## Project Structure

The app follows a **feature-first architecture**:

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality
│   ├── constants/           # App colors, constants
│   ├── services/            # Database & sample data
│   ├── theme/               # App theme configuration
│   └── utils/               # Utility functions
├── features/                 # Feature modules
│   ├── auth/                # Authentication feature
│   │   ├── providers/       # Auth state management
│   │   └── screens/         # Login, Onboarding screens
│   ├── budget/              # Budget feature
│   │   ├── providers/       # Budget state management
│   │   ├── screens/         # Budget overview screen
│   │   └── widgets/         # Budget-specific widgets
│   ├── dashboard/           # Dashboard feature
│   │   ├── providers/       # Dashboard state
│   │   ├── screens/         # Main dashboard screen
│   │   └── widgets/         # Dashboard cards & charts
│   └── transactions/        # Transactions feature
│       ├── providers/       # Transaction state
│       ├── screens/         # Transaction list, add screen
│       └── widgets/         # Transaction widgets
├── models/                   # Data models
│   ├── user.dart
│   ├── budget.dart
│   └── transaction.dart
├── routes/                   # Navigation configuration
│   └── app_router.dart      # GoRouter setup
└── widgets/                  # Shared/reusable widgets
    ├── custom_button.dart
    ├── custom_text_field.dart
    └── loading_overlay.dart
```

## Tech Stack

- **State Management**: [Riverpod](https://pub.dev/packages/flutter_riverpod)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage**: [sqflite](https://pub.dev/packages/sqflite)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Formatting**: [intl](https://pub.dev/packages/intl)
- **UUIDs**: [uuid](https://pub.dev/packages/uuid)

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/budgator.git
cd budgator
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Desktop (macOS)
flutter run -d macos
```

## Models

### User
```dart
User(
  id: String,
  name: String,
  email: String,
  avatarUrl: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
  hasCompletedOnboarding: bool,
)
```

### Budget
```dart
Budget(
  id: String,
  userId: String,
  name: String,
  category: String,
  amount: double,
  spent: double,
  startDate: DateTime,
  endDate: DateTime,
  createdAt: DateTime,
  updatedAt: DateTime,
)
```

### Transaction
```dart
Transaction(
  id: String,
  userId: String,
  budgetId: String?,
  title: String,
  category: String,
  amount: double,
  type: TransactionType (income/expense),
  date: DateTime,
  notes: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
)
```

## Sample Data

The app includes sample data for demonstration:
- Demo user account
- 5 sample budgets (Food, Transportation, Entertainment, Shopping, Bills)
- 10 sample transactions (mix of income and expenses)

## Theme

The app uses a modern green nature-inspired theme:
- **Primary**: #2E7D32 (Forest Green)
- **Primary Light**: #4CAF50 (Green)
- **Secondary**: #81C784 (Light Green)
- **Background**: #F5F9F5 (Mint White)

## Screens

1. **Onboarding Screen**: 3-page introduction with skip option
2. **Login Screen**: Email/password login with demo account
3. **Dashboard Screen**: Balance card, quick actions, budget summary, expense chart, recent transactions
4. **Budget Overview Screen**: List of all budgets with progress bars
5. **Transactions Screen**: List of all transactions with filtering
6. **Add Transaction Screen**: Form to add new income/expense

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

