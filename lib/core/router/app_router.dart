import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/add_transaction_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/addTransaction',
      builder: (context, state) => const AddTransactionPage(),
    ),
    // Später: weitere Pages wie /addTransaction, /settings
  ],
);
