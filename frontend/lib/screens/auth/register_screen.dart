import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

// ==================== REGISTER SCREEN ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _useSms = true;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/welcome')),
        title: const Text('Регистрация'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthSuccess) context.go('/pin-setup');
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Row(children: [
                Expanded(child: _tab('По SMS', _useSms, () => setState(() => _useSms = true))),
                Expanded(child: _tab('Пароль', !_useSms, () => setState(() => _useSms = false))),
              ]),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Номер телефона',
                hintText: '+7 XXX XXX XX XX',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            if (!_useSms) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
              final loading = state is AuthLoading;
              return ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Зарегистрироваться'),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(color: active ? Colors.white : AppTheme.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }

  void _submit() {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    if (_useSms) {
      context.read<AuthBloc>().add(SendSmsEvent(phone));
      context.push('/sms-code', extra: phone);
    } else {
      if (_passCtrl.text != _confirmCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароли не совпадают')),
        );
        return;
      }
      context.read<AuthBloc>().add(RegisterPasswordEvent(phone, _passCtrl.text));
    }
  }
}

// ==================== SMS CODE SCREEN ====================
class SmsCodeScreen extends StatefulWidget {
  final String phone;
  const SmsCodeScreen({super.key, required this.phone});

  @override
  State<SmsCodeScreen> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends State<SmsCodeScreen> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Код из SMS')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthSuccess) context.go('/pin-setup');
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('Код отправлен на\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: AppTheme.textPrimary)),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 4,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: AppTheme.primary,
                  selectedColor: AppTheme.primary,
                  inactiveColor: const Color(0xFFDADCE0),
                ),
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() => _code = val),
                onCompleted: (val) {
                  _code = val;
                  _verify();
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
                return ElevatedButton(
                  onPressed: _code.length == 4 ? _verify : null,
                  child: const Text('Подтвердить'),
                );
              }),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(SendSmsEvent(widget.phone)),
                child: const Text('Отправить повторно'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verify() {
    context.read<AuthBloc>().add(LoginSmsEvent(widget.phone, _code));
  }
}

// ==================== PIN SETUP SCREEN ====================
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создайте PIN-код')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(_confirming ? Icons.lock_reset : Icons.lock_outline,
              size: 60, color: AppTheme.primary),
            const SizedBox(height: 24),
            Text(
              _confirming ? 'Повторите PIN-код' : 'Введите 4-значный PIN',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            PinCodeTextField(
              appContext: context,
              length: 4,
              obscureText: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.circle,
                fieldHeight: 20,
                fieldWidth: 20,
                activeColor: AppTheme.primary,
                selectedColor: AppTheme.primary,
                inactiveColor: const Color(0xFFDADCE0),
                activeFillColor: AppTheme.primary,
                selectedFillColor: AppTheme.primary,
                inactiveFillColor: const Color(0xFFDADCE0),
              ),
              enableActiveFill: true,
              keyboardType: TextInputType.number,
              onChanged: (_) {},
              onCompleted: (val) {
                if (!_confirming) {
                  setState(() { _pin = val; _confirming = true; });
                } else {
                  if (val == _pin) {
                    context.read<AuthBloc>().add(SetPinEvent(_pin, _pin));
                    context.go('/profile');
                  } else {
                    setState(() { _confirming = false; _pin = ''; });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN не совпадает, попробуйте снова')),
                    );
                  }
                }
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/profile'),
              child: Text('Пропустить', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PIN LOGIN SCREEN ====================
class PinLoginScreen extends StatelessWidget {
  const PinLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthSuccess) context.go('/profile');
            if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const Text('mig.rf', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                const SizedBox(height: 8),
                Text('Введите PIN-код', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 40),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: true,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    fieldHeight: 24,
                    fieldWidth: 24,
                    activeColor: AppTheme.primary,
                    selectedColor: AppTheme.primary,
                    inactiveColor: const Color(0xFFDADCE0),
                    activeFillColor: AppTheme.primary,
                    selectedFillColor: AppTheme.primary,
                    inactiveFillColor: const Color(0xFFDADCE0),
                  ),
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {},
                  onCompleted: (pin) => context.read<AuthBloc>().add(LoginPinEvent(pin)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Войти другим способом'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
