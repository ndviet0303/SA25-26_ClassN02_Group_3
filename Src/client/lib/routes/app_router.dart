import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/forgot_password_new_pass_screen.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/forgot_password_otp_screen.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/forgot_password_screen.dart';
import 'package:movie_fe/features/auth/login/presentation/login_screen.dart';
import 'package:movie_fe/features/auth/register/presentation/screen/signup_flow_screen.dart';
import 'package:movie_fe/features/discover/presentation/screens/discover_screen.dart';
import 'package:movie_fe/features/genre/presentation/screens/explore_genre.dart';
import 'package:movie_fe/features/genre/presentation/screens/explore_genre_details.dart';
import 'package:movie_fe/features/home/presentation/screens/home_screen.dart';
import 'package:movie_fe/features/home/presentation/screens/movie_type_screen.dart';
import 'package:movie_fe/features/notification/presentation/notification_screen.dart';
import 'package:movie_fe/features/profile/presentation/help_center_screen.dart';
import 'package:movie_fe/features/profile/presentation/language_screen.dart';
import 'package:movie_fe/features/profile/presentation/personal_info_screen.dart';
import 'package:movie_fe/features/profile/presentation/preferences_screen.dart';
import 'package:movie_fe/features/profile/presentation/profile_screen.dart';
import 'package:movie_fe/features/profile/presentation/security_screen.dart';
import 'package:movie_fe/features/profile/presentation/notification_screen.dart'
    as profile_notification;
import 'package:movie_fe/features/purchase/presentation/purchase_screen.dart';
import 'package:movie_fe/features/search/presentation/screens/search_screen.dart';
import 'package:movie_fe/features/setting/presentation/screens/setting_screen.dart';
import 'package:movie_fe/features/welcome/welcome_screen.dart';
import 'package:movie_fe/features/wishlist/presentation/wishlist_screen.dart';
import 'package:movie_fe/features/movie/presentation/screens/movie_detail_screen.dart';
import 'package:movie_fe/features/movie/presentation/screens/video_player_screen.dart';
import 'package:movie_fe/features/movie/presentation/screens/movie_info_screen.dart';
import 'package:movie_fe/features/movie/presentation/screens/ratings_detail_screen.dart';
import 'package:movie_fe/core/models/movie.dart';
import 'package:movie_fe/features/subscription/presentation/subscription_screen.dart';
import 'package:movie_fe/features/subscription/presentation/payment_success_screen.dart';
import '../core/auth/auth_providers.dart';
import '../core/auth/auth_state_notifier.dart';
import '../core/layouts/main_layout.dart';
import '../core/services/locale_setting.dart';
import 'transition_page.dart';
import 'auth_guard.dart';

/// Provides the GoRouter instance configured with auth state from AuthStateNotifier
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

class AppRouter {
  static const welcome = '/';
  static const signup = '/signup';
  static const signIn = '/sign-in';
  static const home = '/home';
  static const discover = '/discover';
  static const wishlist = '/wishlist';
  static const purchase = '/purchase';
  static const profile = '/profile';
  static const settings = '/settings';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';
  static const search = '/search';
  static const notification = '/notification';
  static const notificationSettings = '/notification-settings';
  static const paymentMethods = '/payment-methods';
  static const personalInfo = '/personal-info';
  static const preferences = '/preferences';
  static const language = '/language';
  static const security = '/security';
  static const helpCenter = '/help-center';
  static const explore = '/explore';
  static const movieCarouselGenre = '/movie-carousel-genre/';
  static const movieCarouselCountry = '/movie-carousel-country/';
  static const movieCarouselYear = '/movie-carousel-year/';
  static const movie = '/movie';
  static const videoPlayer = '/video-player';
  static const movieInfo = '/movie-info';
  static const ratings = '/ratings';
  static const movieType = '/movie-type';
  static const subscription = '/subscription';
  static const paymentSuccess = '/payment/success';
  static const paymentCancel = '/payment/cancel';

  static const _publicPaths = {
    welcome,
    signup,
    signIn,
    forgotPassword,
    otpVerification,
    resetPassword,
  };

  static const _authRedirectWhitelist = {
    welcome,
    signIn,
    signup,
  };

  /// Create router with auth state from Riverpod
  static GoRouter createRouter(Ref ref) {
    // Watch auth state notifier for state changes
    final authNotifier = ref.watch(authStateNotifierProvider.notifier);
    
    // Create auth guard with callback to check login state
    final guard = AuthGuard(
      isLoggedIn: () => ref.read(authStateNotifierProvider).isLoggedIn,
    );

    return GoRouter(
      initialLocation: welcome,
      refreshListenable: _AuthStateRefreshNotifier(authNotifier),
      redirect: guard.redirect,
      routes: _buildRoutes(),
      errorBuilder: (context, state) {
        debugPrint('GoRouter Error: Route not found -> ${state.uri}');
        return const Scaffold(body: Center(child: Text('Route not found')));
      },
    );
  }

  static List<RouteBase> _buildRoutes() {
    return [
      GoRoute(path: welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: signup, builder: (_, __) => const SignupFlowScreen()),
      GoRoute(path: signIn, builder: (_, __) => const LoginScreen()),
      GoRoute(path: forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: otpVerification, builder: (_, state) {
        final email = state.extra as String?;
        return ForgotPasswordOtpScreen(email: email ?? '');
      }),
      GoRoute(path: '${movieCarouselGenre}:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        return ExploreGenreDetails(query: id);
      }),
      GoRoute(path: '${movieCarouselCountry}:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        return ExploreGenreDetails(query: id); // Reuse for country filtering
      }),
      GoRoute(path: '${movieCarouselYear}:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        return ExploreGenreDetails(query: id); // Reuse for year filtering
      }),
      GoRoute(path: '$explore/:name', builder: (_, state) {
        final name = state.pathParameters['name']!;
        return ExploreGenre(query: name);
      }),
      GoRoute(path: '$movie/:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        return MovieDetailScreen(movieId: id);
      }),
      GoRoute(path: '$videoPlayer/:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        Movie? movie;
        String? videoUrl;
        
        if (extra is Map) {
          movie = extra['movie'] as Movie?;
          videoUrl = extra['videoUrl'] as String?;
        } else if (extra is Movie) {
          movie = extra;
        }
        
        if (movie == null) {
          return Scaffold(
            body: Center(
              child: Text('Movie not found: $id'),
            ),
          );
        }
        
        return VideoPlayerScreen(
          movie: movie,
          videoUrl: videoUrl,
        );
      }),
      GoRoute(path: '$movieInfo/:id', builder: (_, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        Movie? movie;
        if (extra is Map) {
          movie = extra['movie'] as Movie?;
        } else if (extra is Movie) {
          movie = extra;
        }

        if (movie == null) {
          return Scaffold(
            body: Center(
              child: Text('Movie not found: $id'),
            ),
          );
        }

        return MovieInfoScreen(movie: movie);
      }),
      GoRoute(path: '$ratings/:id', builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        String? title;
        if (extra is Map) {
          title = extra['title'] as String?;
        } else if (extra is String) {
          title = extra;
        }
        return RatingsDetailScreen(movieId: id, movieTitle: title ?? id);
      }),
      GoRoute(path: '$movieType/:type', builder: (_, state) {
        final typeStr = state.pathParameters['type']!;
        MovieListType type;
        switch (typeStr) {
          case 'wishlist':
            type = MovieListType.wishlist;
            break;
          case 'recent':
            type = MovieListType.recent;
            break;
          case 'recommended':
          default:
            type = MovieListType.recommended;
            break;
        }
        return MovieTypeScreen(type: type);
      }),
      GoRoute(path: resetPassword, builder: (_, state) {
        final extra = state.extra;
        String? email;
        String? resetToken;
        if (extra is Map) {
          email = extra['email'] as String?;
          resetToken = extra['resetToken'] as String?;
        }
        return ForgotPasswordNewPassScreen(email: email, resetToken: resetToken);
      }),
      GoRoute(path: notification, builder: (_, __) => const NotificationScreen()),
      GoRoute(
        path: notificationSettings,
        builder: (_, __) => const profile_notification.NotificationSettingsScreen(),
      ),
      GoRoute(path: personalInfo, builder: (_, __) => const PersonalInfoScreen()),
      GoRoute(path: security, builder: (_, __) => const SecurityScreen()),
      GoRoute(path: preferences, builder: (_, __) => const PreferencesScreen()),
      GoRoute(path: language, builder: (_, __) => const LanguageScreen()),
      GoRoute(path: helpCenter, builder: (_, __) => const HelpCenterScreen()),
      GoRoute(path: subscription, builder: (_, __) => const SubscriptionScreen()),
      GoRoute(path: paymentSuccess, builder: (_, __) => const PaymentSuccessScreen()),
      GoRoute(path: paymentCancel, builder: (_, __) => const SubscriptionScreen()),
      GoRoute(path: search, builder: (_, state) {
        final extra = state.extra;
        SearchSource searchSource = SearchSource.all;
        
        if (extra is Map) {
          final source = extra['searchSource'] as String?;
          if (source == 'wishlist') {
            searchSource = SearchSource.wishlist;
          }
        }
        
        return SearchScreen(searchSource: searchSource);
      }),
      ShellRoute(
        builder: (context, state, child) =>
            MainLayout(showAppBar: true, showBottomNav: true, child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (_, __) => TransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: discover,
            pageBuilder: (_, __) => TransitionPage(child: const DiscoverScreen()),
          ),
          GoRoute(
            path: wishlist,
            pageBuilder: (_, __) => TransitionPage(child: const WishlistScreen()),
          ),
          GoRoute(
            path: purchase,
            pageBuilder: (_, __) => TransitionPage(child: const PurchaseScreen()),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (_, __) => TransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
    ];
  }

  static String _normalize(String location) {
    if (location.isEmpty) return welcome;
    final uri = Uri.parse(location);
    final path = uri.path;
    return path.isEmpty ? welcome : path;
  }
}

/// Listens to AuthStateNotifier's auth state changes stream and notifies GoRouter
class _AuthStateRefreshNotifier extends ChangeNotifier {
  _AuthStateRefreshNotifier(AuthStateNotifier notifier) {
    _subscription = notifier.authStateChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<bool> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
