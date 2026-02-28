import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/user/user_bloc.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

// ==================== TOURISM ====================
class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Туризм')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserLoaded) {
            context.read<UserBloc>().add(LoadProfileEvent());
            return const Center(child: CircularProgressIndicator());
          }
          final p = state.profile;
          final status = p['status'] ?? 'PENDING';
          final stayUntil = p['stayUntil'];
          final entryDate = p['entryDate'];

          final daysLeft = stayUntil != null
              ? DateTime.parse(stayUntil).difference(DateTime.now()).inDays
              : null;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: StatusColors.backgroundFromStatus(status),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StatusColors.fromStatus(status).withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      StatusBadge(status: status, size: 64),
                      const SizedBox(height: 16),
                      if (daysLeft != null) ...[
                        Text('$daysLeft дней',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,
                            color: StatusColors.fromStatus(status))),
                        Text('осталось находиться', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow('Дата въезда', _formatDate(entryDate)),
                        const Divider(),
                        _infoRow('Разрешено дней', '90'),
                        const Divider(),
                        _infoRow('Действует до', _formatDate(stayUntil)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (status == 'RED')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE8E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning, color: AppTheme.error),
                      SizedBox(width: 8),
                      Expanded(child: Text('Срок пребывания истёк! Обратитесь в миграционную службу.',
                        style: TextStyle(color: AppTheme.error))),
                    ]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

// ==================== STUDY ====================
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  static const steps = [
    _Step('UNIVERSITY_LETTER', 'Документ из вуза', '🎓'),
    _Step('MEDICAL_CERTIFICATE', 'Медицинская комиссия', '🏥'),
    _Step('DACTYLOSCOPY', 'Дактилоскопия', '👆'),
    _Step('REGISTRATION', 'Регистрация по месту пребывания', '🏠'),
  ];

  @override
  Widget build(BuildContext context) => _WorkflowBase(title: 'Учёба', steps: steps);
}

// ==================== WORK ====================
class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  static const steps = [
    _Step('WORK_CONTRACT', 'Трудовой договор', '📋'),
    _Step('MEDICAL_CERTIFICATE', 'Медицинская комиссия', '🏥'),
    _Step('DACTYLOSCOPY', 'Дактилоскопия', '👆'),
    _Step('REGISTRATION', 'Регистрация по месту пребывания', '🏠'),
  ];

  @override
  Widget build(BuildContext context) => _WorkflowBase(title: 'Работа', steps: steps);
}

// Shared workflow widget
class _WorkflowBase extends StatefulWidget {
  final String title;
  final List<_Step> steps;

  const _WorkflowBase({required this.title, required this.steps});

  @override
  State<_WorkflowBase> createState() => _WorkflowBaseState();
}

class _WorkflowBaseState extends State<_WorkflowBase> {
  List<dynamic> _stepData = [];

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    try {
      final api = context.findAncestorWidgetOfExactType<_ApiProvider>()?.api;
      // For now, reload profile
      context.read<UserBloc>().add(LoadProfileEvent());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final status = state is UserLoaded ? (state.profile['status'] ?? 'PENDING') : 'PENDING';
          final completed = _stepData.where((s) => s['status'] == 'UPLOADED' || s['status'] == 'VERIFIED').length;
          final total = widget.steps.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Прогресс', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            StatusBadge(status: status, size: 32),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0,
                          backgroundColor: const Color(0xFFDADCE0),
                          color: AppTheme.success,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text('$completed из $total шагов выполнено', style: const TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Steps
                ...widget.steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final step = entry.value;
                  final stepStatus = _stepData.isNotEmpty && i < _stepData.length
                      ? _stepData[i]['status'] : 'PENDING';
                  final done = stepStatus == 'UPLOADED' || stepStatus == 'VERIFIED';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: done ? const Color(0xFFE6F4EA) : const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check, color: AppTheme.success)
                                : Text(step.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        title: Text(step.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          done ? 'Загружено ✓' : 'Требуется загрузка',
                          style: TextStyle(color: done ? AppTheme.success : AppTheme.textSecondary, fontSize: 12),
                        ),
                        trailing: done
                            ? null
                            : ElevatedButton(
                                onPressed: () => context.go('/document-upload', extra: {
                                  'type': step.code,
                                  'title': step.label,
                                }),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: const Text('Загрузить', style: TextStyle(fontSize: 12)),
                              ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Step {
  final String code, label, emoji;
  const _Step(this.code, this.label, this.emoji);
}

class _ApiProvider extends InheritedWidget {
  final dynamic api;
  const _ApiProvider({required this.api, required super.child});

  @override
  bool updateShouldNotify(_) => false;
}

// ==================== DOCUMENT UPLOAD ====================
class DocumentUploadScreen extends StatefulWidget {
  final String docType;
  final String title;

  const DocumentUploadScreen({super.key, required this.docType, required this.title});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  XFile? _file;
  bool _uploading = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDADCE0), width: 2, style: BorderStyle.solid),
              ),
              child: _file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 60, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text('Нажмите чтобы выбрать файл', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.insert_drive_file, size: 60, color: AppTheme.primary),
                        const SizedBox(height: 8),
                        Text(_file!.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.photo),
                  label: const Text('Галерея'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Камера'),
                ),
              ),
            ]),
            const Spacer(),
            if (_done)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.check_circle, color: AppTheme.success),
                  SizedBox(width: 8),
                  Text('Документ загружен!', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                ]),
              )
            else
              ElevatedButton(
                onPressed: _file != null && !_uploading ? _upload : null,
                child: _uploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Загрузить документ'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _file = file);
  }

  Future<void> _pickCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _file = file);
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      // TODO: inject ApiService properly
      // await api.uploadDocument(_file!.path, widget.docType);
      await Future.delayed(const Duration(seconds: 1)); // Mock
      setState(() { _done = true; _uploading = false; });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}
