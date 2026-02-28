import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  String? _token;
  DateTime? _expiresAt;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr() async {
    setState(() => _loading = true);
    _timer?.cancel();
    try {
      // TODO: inject ApiService properly
      // final data = await api.generateQr();
      // Mock QR data
      final mockToken = 'mock_qr_token_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _token = mockToken;
        _expiresAt = DateTime.now().add(const Duration(seconds: 60));
        _secondsLeft = 60;
        _loading = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) {
          t.cancel();
          _loadQr();
        }
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR-код для проверки')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Покажите этот QR-код сотруднику',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),

            if (_loading)
              const CircularProgressIndicator()
            else if (_token != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                ),
                child: QrImageView(data: _token!, version: QrVersions.auto, size: 250),
              ),
              const SizedBox(height: 24),

              // Countdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _secondsLeft <= 10
                      ? const Color(0xFFFCE8E6)
                      : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: _secondsLeft <= 10 ? AppTheme.error : AppTheme.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Обновится через $_secondsLeft сек',
                      style: TextStyle(
                        color: _secondsLeft <= 10 ? AppTheme.error : AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _loadQr,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить QR'),
            ),
          ],
        ),
      ),
    );
  }
}
