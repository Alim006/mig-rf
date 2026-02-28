import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

// ==================== ADMIN LOGIN ====================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _loginCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: 'admin');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Администратор')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: AppTheme.primary),
            const SizedBox(height: 24),
            const Text('Вход для администратора', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextFormField(controller: _loginCtrl, decoration: const InputDecoration(labelText: 'Логин', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 16),
            TextFormField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль', prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      // Mock login - in production use real API
      await Future.delayed(const Duration(milliseconds: 500));
      if (_loginCtrl.text == 'admin' && _passCtrl.text == 'admin') {
        if (mounted) context.go('/admin/dashboard');
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа'), backgroundColor: AppTheme.error),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
}

// ==================== ADMIN DASHBOARD ====================
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель управления'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => context.go('/admin/qr-verify')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => context.go('/welcome')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            Row(children: [
              _statCard('Всего', '128', Icons.people, AppTheme.primary),
              const SizedBox(width: 12),
              _statCard('В норме', '89', Icons.check_circle, AppTheme.success),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statCard('Внимание', '24', Icons.warning, AppTheme.warning),
              const SizedBox(width: 12),
              _statCard('Нарушение', '15', Icons.cancel, AppTheme.error),
            ]),
            const SizedBox(height: 24),
            const Text('Пользователи', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _chip('Все', true),
                _chip('GREEN', false),
                _chip('YELLOW', false),
                _chip('RED', false),
              ]),
            ),
            const SizedBox(height: 12),
            // Mock users list
            ...List.generate(5, (i) => _userTile(context, i)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppTheme.primary : const Color(0xFFDADCE0)),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : AppTheme.textSecondary, fontSize: 12)),
    );
  }

  Widget _userTile(BuildContext context, int i) {
    final statuses = ['GREEN', 'GREEN', 'YELLOW', 'RED', 'PENDING'];
    final names = ['Ахмадов Шерзод', 'Алиев Комил', 'Турсунов Бехруз', 'Раимов Икром', 'Дусматов Одил'];
    final status = statuses[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: StatusColors.fromStatus(status).withOpacity(0.2),
          child: Text(names[i][0], style: TextStyle(color: StatusColors.fromStatus(status))),
        ),
        title: Text(names[i], style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: const Text('Узбекистан · Работа'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: StatusColors.backgroundFromStatus(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: StatusColors.fromStatus(status), fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        onTap: () => context.go('/admin/user/mock-$i'),
      ),
    );
  }
}

// ==================== ADMIN USER DETAIL ====================
class AdminUserDetailScreen extends StatelessWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточка пользователя')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                    const SizedBox(height: 12),
                    const Text('Ахмадов Шерзод', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Узбекистан', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('GREEN — Всё в порядке', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Паспорт', 'AB1234567'),
                    const Divider(),
                    _row('Миграционная карта', 'MK-2024-001'),
                    const Divider(),
                    _row('Цель', 'Работа'),
                    const Divider(),
                    _row('Действует до', '01.01.2025'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
              child: const Text('Установить статус YELLOW'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('Заблокировать пользователя'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==================== ADMIN QR VERIFY ====================
class AdminQrVerifyScreen extends StatefulWidget {
  const AdminQrVerifyScreen({super.key});

  @override
  State<AdminQrVerifyScreen> createState() => _AdminQrVerifyScreenState();
}

class _AdminQrVerifyScreenState extends State<AdminQrVerifyScreen> {
  final _ctrl = TextEditingController();
  Map<String, dynamic>? _result;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка QR-кода')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _ctrl,
              decoration: const InputDecoration(
                labelText: 'Вставьте токен из QR',
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _verify,
              icon: const Icon(Icons.search),
              label: const Text('Проверить'),
            ),
            const SizedBox(height: 24),
            if (_result != null) _buildResult(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(Map<String, dynamic> result) {
    final valid = result['valid'] == true;
    if (!valid) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFFCE8E6), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.cancel, color: AppTheme.error, size: 40),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QR недействителен', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error)),
              Text(result['error'] ?? '', style: const TextStyle(color: AppTheme.error)),
            ],
          )),
        ]),
      );
    }
    final user = result['user'] as Map<String, dynamic>;
    final status = user['status'] ?? 'PENDING';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StatusColors.backgroundFromStatus(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(_statusIcon(status), color: StatusColors.fromStatus(status), size: 32),
                const SizedBox(width: 12),
                Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: StatusColors.fromStatus(status), fontSize: 18)),
              ]),
            ),
            const SizedBox(height: 16),
            _row('ФИО', user['fullName'] ?? '—'),
            _row('Гражданство', user['citizenship'] ?? '—'),
            _row('Статус', user['status'] ?? '—'),
            _row('Нарушения', user['hasViolations'] == true ? 'Есть' : 'Нет'),
            _row('Действует до', user['stayUntil'] ?? '—'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'GREEN': return Icons.check_circle;
      case 'YELLOW': return Icons.warning;
      case 'RED': return Icons.cancel;
      default: return Icons.pending;
    }
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _result = null; });
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock result - replace with real API call
    setState(() {
      _result = {
        'valid': true,
        'user': {
          'fullName': 'Ахмадов Шерзод',
          'citizenship': 'Узбекистан',
          'status': 'GREEN',
          'hasViolations': false,
          'stayUntil': '2025-01-01',
        }
      };
      _loading = false;
    });
  }
}
