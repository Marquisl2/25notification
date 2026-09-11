import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

/// Selector de bandeja (recipientId) con opciones dinámicas
class RecipientSelector extends StatelessWidget {
  final String? currentRecipientId;
  final List<String> knownRecipientIds;
  final Function(String?) onChanged;

  const RecipientSelector({
    super.key,
    required this.currentRecipientId,
    required this.knownRecipientIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Bandeja:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _showSelector(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentRecipientId ?? 'Todos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Opción "Todos"
            ListTile(
              leading: Icon(
                Icons.people_outline,
                color: currentRecipientId == null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: Text(
                'Todos',
                style: TextStyle(
                  color: currentRecipientId == null
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: currentRecipientId == null
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onChanged(null);
              },
            ),
            const Divider(),
            // Opciones de recipientIds conocidos
            ...knownRecipientIds.map((id) {
              final isSelected = currentRecipientId == id;
              return ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  id,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onChanged(id);
                },
              );
            }),
            if (knownRecipientIds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No hay bandejas cargadas aún',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
