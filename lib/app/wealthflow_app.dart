import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_page.dart';
import 'app_shell.dart';
import 'app_theme.dart';

class WealthFlowApp extends ConsumerWidget {
  const WealthFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'WealthFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: switch (auth.status) {
          AuthStatus.loading => const _AppLoading(key: ValueKey('loading')),
          AuthStatus.signedOut => const AuthPage(key: ValueKey('auth')),
          AuthStatus.signedIn => const AppShell(key: ValueKey('shell')),
        },
      ),
    );
  }
}

class _AppLoading extends StatelessWidget {
  const _AppLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
