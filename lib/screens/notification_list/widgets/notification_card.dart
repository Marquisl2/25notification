import 'package:flutter/material.dart';
import '../../../models/notification.dart' as models;
import '../../../models/notification_priority.dart';
import '../../../utils/theme.dart';
import '../../../utils/date_formatter.dart';

/// Tarjeta de notificación con diferenciación visual leída/no leída
class NotificationCard extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: isUnread
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                )
              : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot rojo para no leídas
            if (isUnread) ...[
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ] else
              const SizedBox(width: 20),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          color: isUnread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Body (2 líneas)
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Metadata: prioridad + fecha
                  Row(
                    children: [
                      _buildPriorityChip(notification.priority),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRelative(notification.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildPriorityChip(NotificationPriority priority) {
    Color bgColor;
    Color textColor;

    switch (priority) {
      case NotificationPriority.high:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case NotificationPriority.normal:
        bgColor = AppColors.neutral;
        textColor = AppColors.textPrimary;
        break;
      case NotificationPriority.low:
        bgColor = AppColors.neutral.withValues(alpha: 0.5);
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
