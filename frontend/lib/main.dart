import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'l10n/app_localizations.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/user/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final apiService = ApiService(storageService: storageService);
  final authService = AuthService(apiService, storageService);

  runApp(MigRfApp(
    authService: authService,
    storageService: storageService,
    apiService: apiService,
  ));
}

class MigRfApp extends StatelessWidget {
  final AuthService authService;
  final StorageService storageService;
  final ApiService apiService;

  const MigRfApp({
    super.key,
    required this.authService,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService, storageService)),
        BlocProvider(create: (_) => UserBloc(apiService)),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final locale = storageService.getLocale() ?? 'ru';
          return MaterialApp.router(
            title: 'mig.rf',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: Locale(locale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru'),
              Locale('en'),
              Locale('uz'),
              Locale('tg'),
              Locale('ky'),
            ],
            routerConfig: AppRouter(storageService: storageService).router,
          );
        },
      ),
    );
  }
}
