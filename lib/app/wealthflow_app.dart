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
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'WealthFlow',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Sichere lokale Daten werden geladen …'),
              const SizedBox(height: 20),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    ),
  );
}
