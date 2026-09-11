import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

/// Badge circular rojo con cantidad de notificaciones no leídas
class UnreadBadge extends StatelessWidget {
  final int count;
  final double size;

  const UnreadBadge({
    super.key,
    required this.count,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
