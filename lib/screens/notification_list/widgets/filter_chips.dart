import 'package:flutter/material.dart';
import '../../../models/notification_status.dart';
import '../../../models/notification_priority.dart';
import '../../../utils/theme.dart';

/// Chips horizontales para filtrar notificaciones
class FilterChips extends StatelessWidget {
  final NotificationStatus? selectedStatus;
  final NotificationPriority? selectedPriority;
  final Function(NotificationStatus?) onStatusChanged;
  final Function(NotificationPriority?) onPriorityChanged;

  const FilterChips({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtros de estado (nunca incluye 'scheduled')
            _buildChip(
              label: 'Todas',
              isSelected: selectedStatus == null && selectedPriority == null,
              onTap: () {
                onStatusChanged(null);
                onPriorityChanged(null);
              },
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'No leídas',
              isSelected: selectedStatus == NotificationStatus.unread,
              onTap: () {
                onStatusChanged(NotificationStatus.unread);
                onPriorityChanged(null);
              },
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Leídas',
              isSelected: selectedStatus == NotificationStatus.read,
              onTap: () {
                onStatusChanged(NotificationStatus.read);
                onPriorityChanged(null);
              },
            ),
            const SizedBox(width: 16),
            
            // Separador visual
            Container(
              width: 1,
              height: 24,
              color: AppColors.neutral,
            ),
            const SizedBox(width: 16),
            
            // Filtros de prioridad
            _buildChip(
              label: 'Alta',
              isSelected: selectedPriority == NotificationPriority.high,
              onTap: () {
                onStatusChanged(null);
                onPriorityChanged(NotificationPriority.high);
              },
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Normal',
              isSelected: selectedPriority == NotificationPriority.normal,
              onTap: () {
                onStatusChanged(null);
                onPriorityChanged(NotificationPriority.normal);
              },
            ),
            const SizedBox(width: 8),
            _buildChip(
              label: 'Baja',
              isSelected: selectedPriority == NotificationPriority.low,
              onTap: () {
                onStatusChanged(null);
                onPriorityChanged(NotificationPriority.low);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
