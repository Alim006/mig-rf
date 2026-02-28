import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/user/user_bloc.dart';
import '../../theme/app_theme.dart';

class VisitTypeScreen extends StatelessWidget {
  const VisitTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const types = [
      _VType('TOURISM', 'Туризм', '🏖️', 'Временный туристический визит'),
      _VType('STUDY', 'Учёба', '🎓', 'Обучение в российском вузе'),
      _VType('WORK', 'Работа', '💼', 'Трудовая деятельность'),
      _VType('BUSINESS', 'Рабочий визит', '🤝', 'Деловые переговоры'),
      _VType('DIPLOMATIC', 'Дипломатический', '🏛️', 'Дипломатическая деятельность'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Цель визита')),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserLoaded) {
            final vt = state.profile['visitType']?.toString().toLowerCase();
            if (vt != null) context.go('/workflow/$vt');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Выберите цель вашего пребывания в России:',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: types.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final t = types[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Text(t.emoji, style: const TextStyle(fontSize: 32)),
                        title: Text(t.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: Text(t.description, style: const TextStyle(color: AppTheme.textSecondary)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
                        onTap: () => context.read<UserBloc>().add(SetVisitTypeEvent(t.code)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VType {
  final String code, label, emoji, description;
  const _VType(this.code, this.label, this.emoji, this.description);
}
