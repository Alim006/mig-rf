import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mig.rf'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.go('/welcome');
            },
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserError) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(state.message),
                TextButton(onPressed: () => context.read<UserBloc>().add(LoadProfileEvent()), child: const Text('Повторить')),
              ],
            ));
          }
          if (state is UserLoaded) {
            final profile = state.profile;
            final status = profile['status'] ?? 'PENDING';
            final isVerified = profile['isVerified'] ?? false;
            final visitType = profile['visitType'];

            return RefreshIndicator(
              onRefresh: () async => context.read<UserBloc>().add(LoadProfileEvent()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Status card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: StatusColors.backgroundFromStatus(status),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: StatusColors.fromStatus(status).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          StatusBadge(status: status),
                          const SizedBox(height: 12),
                          Text(
                            _statusLabel(status),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: StatusColors.fromStatus(status),
                            ),
                          ),
                          if (profile['stayUntil'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'До: ${_formatDate(profile['stayUntil'])}',
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Личные данные', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                TextButton(
                                  onPressed: () => context.go('/profile/edit'),
                                  child: const Text('Изменить'),
                                ),
                              ],
                            ),
                            _row('ФИО', profile['fullName'] ?? '—'),
                            _row('Гражданство', profile['citizenship'] ?? '—'),
                            _row('Паспорт', profile['passportNumber'] ?? '—'),
                            _row('Миграционная карта', profile['migrationCard'] ?? '—'),
                            _row('Адрес', profile['address'] ?? '—'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    if (!isVerified || visitType == null) ...[
                      ElevatedButton.icon(
                        onPressed: () => context.go('/profile/edit'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Заполнить данные'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (isVerified && visitType == null) ...[
                      ElevatedButton.icon(
                        onPressed: () => context.go('/visit-type'),
                        icon: const Icon(Icons.flag),
                        label: const Text('Указать цель визита'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (visitType != null) ...[
                      OutlinedButton.icon(
                        onPressed: () => context.go('/workflow/${visitType.toString().toLowerCase()}'),
                        icon: const Icon(Icons.checklist),
                        label: const Text('Мои документы и статус'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton.icon(
                      onPressed: () => context.go('/qr'),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Показать QR-код'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textPrimary),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'GREEN': return 'Всё в порядке';
      case 'YELLOW': return 'Требует внимания';
      case 'RED': return 'Нарушение!';
      default: return 'Ожидает заполнения';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
