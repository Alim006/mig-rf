import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/user/user_bloc.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _citizenshipCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _migCardCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _entryDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) {
      final p = state.profile;
      _fullNameCtrl.text = p['fullName'] ?? '';
      _birthdateCtrl.text = p['birthdate'] ?? '';
      _citizenshipCtrl.text = p['citizenship'] ?? '';
      _passportCtrl.text = p['passportNumber'] ?? '';
      _migCardCtrl.text = p['migrationCard'] ?? '';
      _addressCtrl.text = p['address'] ?? '';
      _entryDateCtrl.text = p['entryDate'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Личные данные')),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserLoaded) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Данные сохранены'), backgroundColor: AppTheme.success),
            );
            context.go('/visit-type');
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _field(_fullNameCtrl, 'ФИО', Icons.person, required: true),
                const SizedBox(height: 16),
                _field(_birthdateCtrl, 'Дата рождения (ГГГГ-ММ-ДД)', Icons.cake),
                const SizedBox(height: 16),
                _field(_citizenshipCtrl, 'Гражданство', Icons.flag),
                const SizedBox(height: 16),
                _field(_passportCtrl, 'Номер паспорта', Icons.book),
                const SizedBox(height: 16),
                _field(_migCardCtrl, 'Номер миграционной карты', Icons.credit_card),
                const SizedBox(height: 16),
                _field(_addressCtrl, 'Адрес пребывания', Icons.home),
                const SizedBox(height: 16),
                _field(_entryDateCtrl, 'Дата въезда (ГГГГ-ММ-ДД)', Icons.calendar_today),
                const SizedBox(height: 32),
                BlocBuilder<UserBloc, UserState>(builder: (ctx, state) {
                  return ElevatedButton(
                    onPressed: state is UserLoading ? null : _save,
                    child: state is UserLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Сохранить и продолжить'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      validator: required ? (v) => v?.isEmpty == true ? 'Обязательное поле' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<UserBloc>().add(UpdateProfileEvent({
      'fullName': _fullNameCtrl.text.trim(),
      'birthdate': _birthdateCtrl.text.trim(),
      'citizenship': _citizenshipCtrl.text.trim(),
      'passportNumber': _passportCtrl.text.trim(),
      'migrationCard': _migCardCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'entryDate': _entryDateCtrl.text.trim(),
    }));
  }
}
