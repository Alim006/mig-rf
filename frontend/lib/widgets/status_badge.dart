import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double size;

  const StatusBadge({super.key, required this.status, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final color = StatusColors.fromStatus(status);
    final icon = _icon();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  IconData _icon() {
    switch (status.toUpperCase()) {
      case 'GREEN': return Icons.check_circle;
      case 'YELLOW': return Icons.warning;
      case 'RED': return Icons.cancel;
      default: return Icons.pending;
    }
  }
}
