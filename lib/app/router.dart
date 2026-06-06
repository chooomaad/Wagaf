import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/requests/domain/entities/import_request_entity.dart';
import '../features/requests/presentation/screens/request_submit_screen.dart';
import '../features/requests/presentation/screens/request_confirmation_screen.dart';
import '../features/requests/presentation/screens/my_requests_screen.dart';
import '../features/requests/presentation/screens/request_detail_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/tracking/presentation/screens/tracking_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.initial;
      final location = state.matchedLocation;

      final publicRoutes = ['/', '/onboarding', '/login', '/register', '/forgot-password'];
      final isPublic = publicRoutes.contains(location);

      if (isLoading) return '/';
      if (!isAuth && !isPublic) return '/login';
      if (isAuth && isPublic && location != '/') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (ctx, state) => _fadeTransition(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (ctx, state) => _fadeTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (ctx, state) => _fadeTransition(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/product-detail',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const RequestSubmitScreen(),
        ),
      ),
      GoRoute(
        path: '/request-confirmation',
        redirect: (ctx, state) =>
            state.extra == null ? '/my-requests' : null,
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: RequestConfirmationScreen(
            request: state.extra! as ImportRequest,
          ),
        ),
      ),
      GoRoute(
        path: '/my-requests',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const MyRequestsScreen(),
        ),
      ),
      GoRoute(
        path: '/request-detail',
        redirect: (ctx, state) =>
            state.extra == null ? '/my-requests' : null,
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: RequestDetailScreen(
            request: state.extra! as ImportRequest,
          ),
        ),
      ),
      GoRoute(
        path: '/orders',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/order-detail',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const TrackingScreen(),
        ),
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const CartScreen(),
        ),
      ),
      GoRoute(
        path: '/tracking/:orderId',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const TrackingScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        redirect: (ctx, state) {
          if (!authState.isAdmin) return '/home';
          return null;
        },
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
        ),
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page introuvable: ${state.uri}'),
            TextButton(
              onPressed: () => ctx.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _fadeTransition({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );

CustomTransitionPage<void> _slideTransition({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
