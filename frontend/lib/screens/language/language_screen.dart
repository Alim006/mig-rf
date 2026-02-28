import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'ru';

  final List<_Language> _languages = [
    _Language('ru', 'Русский', '🇷🇺'),
    _Language('en', 'English', '🇬🇧'),
    _Language('uz', "O'zbek", '🇺🇿'),
    _Language('tg', 'Тоҷикӣ', '🇹🇯'),
    _Language('ky', 'Кыргызча', '🇰🇬'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('🌍', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Выберите язык\nSelect language',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Тилди тандаңыз / Забонро интихоб кунед',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final lang = _languages[i];
                    final isSelected = _selected == lang.code;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = lang.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : const Color(0xFFDADCE0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang.flag, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Text(
                              lang.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Save locale
                  context.go('/welcome');
                },
                child: const Text('Продолжить / Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Language {
  final String code, name, flag;
  _Language(this.code, this.name, this.flag);
}
