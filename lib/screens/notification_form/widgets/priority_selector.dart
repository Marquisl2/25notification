import 'package:flutter/material.dart';
import '../../../models/notification_priority.dart';
import '../../../utils/theme.dart';

/// Selector visual de prioridad con chips exclusivos
class PrioritySelector extends StatelessWidget {
  final NotificationPriority selectedPriority;
  final Function(NotificationPriority) onChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildChip(
            context,
            priority: NotificationPriority.high,
            label: 'Alta',
            icon: Icons.priority_high,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildChip(
            context,
            priority: NotificationPriority.normal,
            label: 'Normal',
            icon: Icons.remove,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildChip(
            context,
            priority: NotificationPriority.low,
            label: 'Baja',
            icon: Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required NotificationPriority priority,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedPriority == priority;
    
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      switch (priority) {
        case NotificationPriority.high:
          bgColor = AppColors.primary;
          textColor = Colors.white;
          borderColor = AppColors.primary;
          break;
        case NotificationPriority.normal:
          bgColor = AppColors.neutral;
          textColor = AppColors.textPrimary;
          borderColor = AppColors.neutral;
          break;
        case NotificationPriority.low:
          bgColor = AppColors.neutral.withValues(alpha: 0.5);
          textColor = AppColors.textSecondary;
          borderColor = AppColors.neutral;
          break;
      }
    } else {
      bgColor = AppColors.surface;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.neutral;
    }

    return InkWell(
      onTap: () => onChanged(priority),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
