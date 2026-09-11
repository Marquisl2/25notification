import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/create_notification_dto.dart';
import '../../models/notification_priority.dart';
import '../../services/api_exceptions.dart';
import '../../utils/theme.dart';
import 'widgets/priority_selector.dart';

class NotificationFormScreen extends StatefulWidget {
  const NotificationFormScreen({super.key});

  @override
  State<NotificationFormScreen> createState() => _NotificationFormScreenState();
}

class _NotificationFormScreenState extends State<NotificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _recipientsController = TextEditingController();
  final _dataController = TextEditingController();

  NotificationPriority _selectedPriority = NotificationPriority.normal;
  DateTime? _scheduledAt;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _recipientsController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Notificación'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: Tu pedido fue enviado',
                counterText: '${_titleController.text.length}/120',
              ),
              maxLength: 120,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                if (value.length > 120) {
                  return 'Máximo 120 caracteres';
                }
                return null;
              },
              onChanged: (_) => setState(() {}), // Para actualizar el contador
            ),
            const SizedBox(height: 16),

            // Cuerpo
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Cuerpo *',
                hintText: 'Mensaje completo de la notificación',
                counterText: '${_bodyController.text.length}/500',
                alignLabelWithHint: true,
              ),
              maxLength: 500,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El cuerpo es obligatorio';
                }
                if (value.length > 500) {
                  return 'Máximo 500 caracteres';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Destinatarios
            TextFormField(
              controller: _recipientsController,
              decoration: const InputDecoration(
                labelText: 'Destinatarios (recipientIds) *',
                hintText: 'usr_9a1f2c, usr_4b7d0e',
                helperText: 'IDs separados por coma. Se crea una notificación por cada uno.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Al menos un destinatario es obligatorio';
                }
                final ids = _parseRecipientIds(value);
                if (ids.isEmpty) {
                  return 'Formato inválido. Ej: usr_9a1f2c, usr_xxx';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Selector de prioridad
            Text(
              'Prioridad *',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onChanged: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),
            const SizedBox(height: 24),

            // Programar envío (opcional)
            Text(
              'Programar envío (opcional)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickScheduledDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _scheduledAt == null
                            ? 'Envío inmediato'
                            : 'Programada: ${_scheduledAt!.toLocal()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (_scheduledAt != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _scheduledAt = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Datos adicionales (opcional, JSON)
            TextFormField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Datos adicionales (opcional, JSON)',
                hintText: '{"orderId": "1234", "deepLink": "app://orders/1234"}',
                helperText: 'JSON válido o dejar vacío',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // Opcional
                }
                try {
                  jsonDecode(value);
                  return null;
                } catch (e) {
                  return 'JSON inválido';
                }
              },
            ),
            const SizedBox(height: 32),

            // Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Crear Notificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseRecipientIds(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? _parseData() {
    final text = _dataController.text.trim();
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dto = CreateNotificationDto(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        recipientIds: _parseRecipientIds(_recipientsController.text),
        priority: _selectedPriority,
        scheduledAt: _scheduledAt,
        data: _parseData(),
      );

      await context.read<NotificationProvider>().createNotification(dto);

      if (mounted) {
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación creada con éxito'),
            backgroundColor: AppColors.success,
          ),
        );

        // Volver al listado (que se auto-refresca)
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.userMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on NetworkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
