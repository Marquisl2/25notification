import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart' as models;
import '../../models/notification_priority.dart';
import '../../models/notification_status.dart';
import '../../utils/theme.dart';
import '../../utils/date_formatter.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final notification = provider.findById(notificationId);

          if (notification == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notification_important_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notificación no encontrada',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return _buildContent(context, notification);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, models.Notification notification) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            notification.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Metadata bar: prioridad + fecha
          Row(
            children: [
              _buildPriorityChip(notification.priority),
              const SizedBox(width: 12),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatDateTime(notification.createdAt),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Body completo
          Text(
            notification.body,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Info técnica
          _buildInfoCard(
            context,
            title: 'Información técnica',
            children: [
              _buildInfoRow(
                context,
                label: 'ID',
                value: notification.id,
              ),
              _buildInfoRow(
                context,
                label: 'Destinatario',
                value: notification.recipientId,
              ),
              _buildInfoRow(
                context,
                label: 'Estado',
                value: notification.status.displayName,
                valueColor: _getStatusColor(notification.status),
              ),
              _buildInfoRow(
                context,
                label: 'Prioridad',
                value: notification.priority.displayName,
              ),
              if (notification.scheduledAt != null)
                _buildInfoRow(
                  context,
                  label: 'Programada para',
                  value: DateFormatter.formatDateTime(notification.scheduledAt!),
                ),
              if (notification.readAt != null)
                _buildInfoRow(
                  context,
                  label: 'Leída el',
                  value: DateFormatter.formatDateTime(notification.readAt!),
                ),
            ],
          ),

          // Datos adicionales
          if (notification.data != null && notification.data!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Datos adicionales',
              children: [
                _buildExpandableJson(context, notification.data!),
              ],
            ),
          ],

          // Deep link (si existe)
          if (notification.data?['deepLink'] != null) ...[
            const SizedBox(height: 16),
            _buildDeepLinkCard(context, notification.data!['deepLink'] as String),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableJson(BuildContext context, Map<String, dynamic> data) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        jsonString,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
      ),
    );
  }

  Widget _buildDeepLinkCard(BuildContext context, String deepLink) {
    // Lista cerrada de rutas soportadas por la app
    const supportedRoutes = {
      'profile',
      'orders',
      'chat',
      'billing',
      'promotions',
    };

    // Parseo real del deep link
    Uri? uri;
    String? scheme;
    String? resource;
    String? parameter;
    String? queryParams;
    String? resolvedRoute;
    String? errorMessage;
    bool isRouteSupported = false;

    try {
      uri = Uri.parse(deepLink);
      scheme = uri.scheme;
      resource = uri.host.isNotEmpty ? uri.host : null;
      
      // Extraer parámetro del path
      if (uri.pathSegments.isNotEmpty) {
        parameter = uri.pathSegments.first;
      } else if (uri.path.isNotEmpty && uri.path != '/') {
        parameter = uri.path.replaceFirst('/', '');
      }

      // Query parameters (si existen)
      if (uri.queryParameters.isNotEmpty) {
        queryParams = uri.queryParameters.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
      }

      // Validación y mapeo a rutas de go_router
      if (scheme == 'app' && resource != null && resource.isNotEmpty) {
        // Verificar si la ruta está soportada
        if (supportedRoutes.contains(resource)) {
          isRouteSupported = true;
          if (parameter != null && parameter.isNotEmpty) {
            resolvedRoute = '/$resource/$parameter';
          } else {
            resolvedRoute = '/$resource';
          }
          
          // Agregar query params si existen
          if (queryParams != null) {
            resolvedRoute = '$resolvedRoute?$queryParams';
          }
        } else {
          // Ruta no mapeada en la app
          resolvedRoute = 'No hay una pantalla mapeada para "$resource"';
        }
      } else {
        resolvedRoute = 'Esquema no soportado o formato inválido';
      }
    } catch (e) {
      errorMessage = 'Error al parsear el deep link';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.link,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Deep Link',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // URL original
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deepLink,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Resultado del parseo
          if (errorMessage != null) ...[
            Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Análisis técnico:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            _buildParseItem(
              context, 
              'Esquema', 
              (scheme != null && scheme.isNotEmpty) ? scheme : '-',
            ),
            _buildParseItem(
              context, 
              'Recurso', 
              (resource != null && resource.isNotEmpty) ? resource : '-',
            ),
            _buildParseItem(
              context, 
              'Parámetro', 
              (parameter != null && parameter.isNotEmpty) ? parameter : '-',
            ),
            if (queryParams != null && queryParams.isNotEmpty)
              _buildParseItem(context, 'Query', queryParams),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Ruta resuelta
            Text(
              'Mapeo a go_router:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRouteSupported
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isRouteSupported
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.neutral,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isRouteSupported ? Icons.check_circle : Icons.warning_amber,
                    size: 16,
                    color: isRouteSupported 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRouteSupported
                              ? 'context.push("$resolvedRoute")'
                              : resolvedRoute!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: isRouteSupported ? 'monospace' : null,
                                fontSize: 11,
                              ),
                        ),
                        if (!isRouteSupported && resolvedRoute!.contains('mapeada')) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Rutas soportadas: profile, orders, chat, billing, promotions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParseItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.unread:
        return AppColors.primary;
      case NotificationStatus.read:
        return AppColors.textSecondary;
      case NotificationStatus.scheduled:
        return AppColors.textSecondary;
    }
  }
}
