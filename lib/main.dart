import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/map/point_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'services/notification_service.dart';
import 'services/token_storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize token storage
  final tokenStorage = TokenStorageService();
  await tokenStorage.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool _isShowingSplash = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkAuthOnStartup();
  }

  void _checkAuthOnStartup() async {
    // Wait a bit for the UI to settle
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      await ref.read(authProvider.notifier).restoreSession();

      if (mounted) {
        setState(() => _isShowingSplash = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Nomad GIS',
      theme: AppTheme.darkTheme,
      scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
      home: _buildHome(authState),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildHome(AuthState authState) {
    // Show splash screen while checking auth
    if (_isShowingSplash || authState.isRestoringSession) {
      return const SplashScreen();
    }

    // Show auth screens if not authenticated
    if (!authState.isAuthenticated) {
      return const _AuthNavigator();
    }

    // Show main app if authenticated
    return _MainNavigator(
      pageController: _pageController,
      currentPageIndex: _currentPageIndex,
      onPageChanged: (index) => setState(() => _currentPageIndex = index),
    );
  }
}

class _AuthNavigator extends StatefulWidget {
  const _AuthNavigator();

  @override
  State<_AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<_AuthNavigator> {
  bool _isLoginPage = true;

  @override
  Widget build(BuildContext context) {
    return _isLoginPage
        ? LoginScreen(
            onRegistrationTap: () => setState(() => _isLoginPage = false),
          )
        : RegisterScreen(onLoginTap: () => setState(() => _isLoginPage = true));
  }
}

class _MainNavigator extends StatelessWidget {
  final PageController pageController;
  final int currentPageIndex;
  final Function(int) onPageChanged;

  const _MainNavigator({
    required this.pageController,
    required this.currentPageIndex,
    required this.onPageChanged,
  });

  void _openPointDetail(BuildContext context, String pointId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PointDetailScreen(pointId: pointId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // Map Screen
          MapScreen(
            onProfileTap: () => pageController.jumpToPage(1),
            onLeaderboardTap: () => pageController.jumpToPage(3),
            onPointTap: (pointId) => _openPointDetail(context, pointId),
          ),
          // Profile Screen
          ProfileScreen(onLogout: () {}),
          // Achievements Screen
          AchievementsScreen(),
          // Leaderboard Screen
          LeaderboardScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => pageController.jumpToPage(index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Карта'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Достижения'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Лидерборд',
          ),
        ],
      ),
    );
  }
}
