import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _register = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: EdgeInsets.all(viewport.maxWidth < 480 ? 12 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    viewport.maxHeight - (viewport.maxWidth < 480 ? 24 : 48),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 760;
                        final form = _buildForm(
                          context,
                          auth.isBusy,
                          auth.error,
                        );
                        return wide
                            ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: _HeroPanel(colors: colors)),
                                    Expanded(child: form),
                                  ],
                                ),
                              )
                            : form;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool busy, String? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded),
                ),
                const SizedBox(width: 12),
                Text(
                  'WealthFlow',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Text(
              _register ? 'Konto erstellen' : 'Willkommen zurück',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _register
                  ? 'Deine Finanzdaten bleiben lokal und gehören nur dir.'
                  : 'Melde dich an, um deine Finanzen zu verwalten.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            if (_register) ...[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Bitte gib deinen Namen ein.'
                    : null,
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) =>
                  (value?.contains('@') ?? false) ? null : 'Ungültige E-Mail.',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: [
                _register ? AutofillHints.newPassword : AutofillHints.password,
              ],
              onFieldSubmitted: (_) => busy ? null : _submit(),
              decoration: InputDecoration(
                labelText: 'Passwort',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? 'Passwort anzeigen'
                      : 'Passwort verbergen',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => _register && (value?.length ?? 0) < 10
                  ? 'Mindestens 10 Zeichen.'
                  : (value?.isEmpty ?? true)
                  ? 'Bitte gib dein Passwort ein.'
                  : null,
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: busy ? null : _submit,
              icon: busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _register
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                    ),
              label: Text(_register ? 'Sicher registrieren' : 'Anmelden'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: busy
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).clearError();
                      setState(() => _register = !_register);
                    },
              child: Text(
                _register
                    ? 'Ich habe bereits ein Konto'
                    : 'Noch kein Konto? Jetzt registrieren',
              ),
            ),
            if (!_register)
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Passwort vergessen'),
                    content: Text(
                      'Im lokalen Modus gibt es aus Sicherheitsgründen keine '
                      'Hintertür. Stelle ein verschlüsseltes Backup wieder her '
                      'oder lege ein neues lokales Profil an.',
                    ),
                  ),
                ),
                child: const Text('Passwort vergessen?'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(authControllerProvider.notifier);
    if (_register) {
      await controller.register(
        displayName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await controller.login(_emailController.text, _passwordController.text);
    }
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 650),
      padding: const EdgeInsets.all(44),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_rounded, size: 72, color: colors.onPrimary),
          const SizedBox(height: 30),
          Text(
            'Alle Finanzen.\nEin klarer Überblick.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Konten, Investments, Haushalt und Fahrzeuge – lokal, sicher und '
            'auf jedem Bildschirm zu Hause.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: .82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
