import 'package:go_router/go_router.dart';
import '../models/menu_item.dart';

import '../screens/main_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/electre_screen.dart';
import '../screens/topsis_screen.dart';
import '../screens/anp_screen.dart';
import '../screens/ahp_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/topsis',
        builder: (context, state) => MainScreen(
          currentItem: MenuItem.topsis,
          child: const TopsisScreen(),
        ),
      ),
      GoRoute(
        path: '/ahp',
        builder: (context, state) =>
            MainScreen(currentItem: MenuItem.ahp, child: const AhpScreen()),
      ),
      GoRoute(
        path: '/anp',
        builder: (context, state) =>
            MainScreen(currentItem: MenuItem.anp, child: const AnpScreen()),
      ),
      GoRoute(
        path: '/electre',
        builder: (context, state) => MainScreen(
          currentItem: MenuItem.electre,
          child: const ElectreScreen(),
        ),
      ),
    ],
  );
}
