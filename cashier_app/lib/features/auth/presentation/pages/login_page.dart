import 'package:cashier_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  String _pin = '';
  static const _pinLength = 4;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onClear() => setState(() => _pin = '');

  void _submit() {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty || _pin.isEmpty) return;
    context.read<AuthCubit>().login(username, _pin);
    setState(() => _pin = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outlined, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Portculis POS',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (_, curr) => curr is AuthLocked,
                    builder: (context, state) {
                      final error =
                          state is AuthLocked ? state.error : null;
                      return Column(
                        children: [
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          TextField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 16),

                          // PIN dots
                          _PinDots(
                            length: _pinLength,
                            filled: _pin.length,
                          ),
                          const SizedBox(height: 16),

                          // Numeric keypad
                          _NumericKeypad(
                            onDigit: _onDigit,
                            onBackspace: _onBackspace,
                            onClear: _onClear,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submit,
                              child: const Text('Sign In'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN dot indicator
// ---------------------------------------------------------------------------

class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Numeric keypad (1-9, clear, 0, backspace)
// ---------------------------------------------------------------------------

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['1', '2', '3']),
        const SizedBox(height: 8),
        _row(['4', '5', '6']),
        const SizedBox(height: 8),
        _row(['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _keyButton(
              child: const Text('C'),
              onTap: onClear,
            ),
            const SizedBox(width: 12),
            _keyButton(
              child: const Text('0', style: TextStyle(fontSize: 20)),
              onTap: () => onDigit('0'),
            ),
            const SizedBox(width: 12),
            _keyButton(
              child: const Icon(Icons.backspace_outlined, size: 20),
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          _keyButton(
            child: Text(digits[i], style: const TextStyle(fontSize: 20)),
            onTap: () => onDigit(digits[i]),
          ),
        ],
      ],
    );
  }

  Widget _keyButton({required Widget child, required VoidCallback onTap}) {
    return SizedBox(
      width: 64,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
