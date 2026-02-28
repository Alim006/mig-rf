import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../screens/language/language_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/sms_code_screen.dart';
import '../screens/auth/pin_setup_screen.dart';
import '../screens/auth/pin_login_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/workflow/visit_type_screen.dart';
import '../screens/workflow/tourism_screen.dart';
import '../screens/workflow/study_screen.dart';
import '../screens/workflow/work_screen.dart';
import '../screens/workflow/document_upload_screen.dart';
import '../screens/qr/qr_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_user_detail_screen.dart';
import '../screens/admin/admin_qr_verify_screen.dart';

class AppRouter {
  final StorageService storageService;

  AppRouter({required this.storageService});

  late final router = GoRouter(
    initialLocation: _initialRoute(),
    routes: [
      GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/sms-code',
        builder: (_, state) => SmsCodeScreen(phone: state.extra as String),
      ),
      GoRoute(path: '/pin-setup', builder: (_, __) => const PinSetupScreen()),
      GoRoute(path: '/pin-login', builder: (_, __) => const PinLoginScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/visit-type', builder: (_, __) => const VisitTypeScreen()),
      GoRoute(path: '/workflow/tourism', builder: (_, __) => const TourismScreen()),
      GoRoute(path: '/workflow/study', builder: (_, __) => const StudyScreen()),
      GoRoute(path: '/workflow/work', builder: (_, __) => const WorkScreen()),
      GoRoute(
        path: '/document-upload',
        builder: (_, state) => DocumentUploadScreen(
          docType: (state.extra as Map)['type'] as String,
          title: (state.extra as Map)['title'] as String,
        ),
      ),
      GoRoute(path: '/qr', builder: (_, __) => const QrScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/user/:id',
        builder: (_, state) => AdminUserDetailScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/admin/qr-verify', builder: (_, __) => const AdminQrVerifyScreen()),
    ],
  );

  String _initialRoute() {
    if (storageService.getLocale() == null) return '/language';
    if (!storageService.isLoggedIn()) return '/welcome';
    if (storageService.hasPinSet()) return '/pin-login';
    return '/profile';
  }
}
