
# BudGator

Budgeting, one bite at a time.

BudGator is a Flutter personal finance app for tracking income and expenses, setting category budgets, and monitoring savings goals. The app is currently built as a local-first mobile experience using Riverpod for state management and SharedPreferences for persistence.

## What it does

- Add income and expense transactions
- Browse all transactions, or filter by income and expenses
- Group spending by category
- Set monthly category budgets
- Track one or more savings goals
- View summary statistics and spending trends
- Persist data locally on-device

## Tech stack

- Flutter
- Dart 3.10+
- flutter_riverpod
- go_router
- shared_preferences
- intl

## Project status

BudGator is an actively evolving app prototype. It already includes core budgeting workflows, but it is still a local-only app with no backend, sync, authentication, or cloud backup.

## Getting started

### Prerequisites

- Flutter SDK installed
- Dart SDK included with Flutter
- One of: Android Studio, VS Code, or Xcode depending on target platform
- A connected emulator, simulator, or physical device

Check your environment:

```bash
flutter doctor
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run tests

```bash
flutter test
```

## App structure

```text
lib/
	core/
		router/        App routing
		theme/         Global app theme
	data/
		datasources/   Local persistence
		models/        Domain models
	presentation/
		controllers/   Riverpod state notifiers and derived providers
		pages/         Screens
		theme/         UI-specific theming helpers
		widgets/       Reusable UI components
	main.dart        App bootstrap
```

## Main screens

- Home: balance overview, weekly expenses, top categories, recent transactions, savings summary
- Transactions: tabbed list for all entries, income, and expenses
- Budget: category-based monthly limits and savings goals
- Statistics: KPIs, weekly trends, category breakdowns, and weekday patterns
- Add Transaction: form for creating a new income or expense entry

## Data and persistence

BudGator stores app data locally with SharedPreferences.

- Transactions are stored as JSON
- Savings goals are stored as JSON
- Category budgets are stored as JSON
- App state is initialized at startup before the widget tree is built

This means data survives app restarts on the same device, but it is not synced across devices.

## Supported platforms

This Flutter project includes platform folders for:

- Android
- iOS
- Web
- Windows
- macOS
- Linux

The current UX is primarily tailored to mobile usage.

## Development notes

- State management is handled with Riverpod StateNotifiers and Providers
- Navigation currently uses GoRouter with a small route surface
- The app title is set to `BudGator`
- SharedPreferences is injected at startup through a Riverpod provider override

## Build an IPA for Sideloadly

Sideloadly installs `.ipa` files on iPhone, but Flutter iOS builds require macOS and Xcode.

1. Make sure your iOS bundle ID is unique in `ios/Runner.xcodeproj/project.pbxproj`.
2. On a Mac with Flutter and Xcode installed, run:

```bash
chmod +x scripts/build_ipa_for_sideloadly.sh
./scripts/build_ipa_for_sideloadly.sh
```

3. The generated IPA will be located at:

```text
build/ios/iphoneos/Budgator.ipa
```

4. Open Sideloadly on Windows, select your iPhone and Apple ID, then choose that IPA file.

### Notes

- IPA generation cannot be done natively on Windows for Flutter iOS targets
- If you use a free Apple ID, the app signature usually expires after 7 days

## Build with Codemagic

This repository includes `codemagic.yaml` with these workflows:

- `sideloadly_ipa`
- `sideloadly_ipa_auto_build_number`

Recommended flow:

1. Connect the repository in Codemagic.
2. Run the `sideloadly_ipa_auto_build_number` workflow.
3. Download the generated artifact:

```text
build/ios/iphoneos/Budgator.ipa
```

4. Install it through Sideloadly on Windows.

Using the auto build number workflow helps avoid iOS install failures caused by reusing the same build number.

## Next improvements

- Edit and delete flows across all entities
- Better onboarding and empty states
- Export and backup options
- Recurring transactions
- Cloud sync and account support
- More detailed budgeting analytics

