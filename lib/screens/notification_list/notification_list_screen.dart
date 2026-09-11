import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_state.dart';
import '../../utils/theme.dart';
import 'widgets/notification_card.dart';
import 'widgets/filter_chips.dart';
import 'widgets/recipient_selector.dart';
import 'widgets/unread_badge.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar notificaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
    });

    // Detectar scroll al final para paginación
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // A 200px del final, cargar más
      final provider = context.read<NotificationProvider>();
      if (provider.hasMore && !provider.isLoadingMore) {
        provider.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notificaciones'),
            const SizedBox(width: 8),
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                return UnreadBadge(count: provider.unreadCount);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/notification/new'),
            tooltip: 'Nueva notificación',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Selector de bandeja
              RecipientSelector(
                currentRecipientId: provider.recipientId,
                knownRecipientIds: provider.knownRecipientIds,
                onChanged: (id) => provider.setRecipientId(id),
              ),
              
              // Chips de filtros
              FilterChips(
                selectedStatus: provider.statusFilter,
                selectedPriority: provider.priorityFilter,
                onStatusChanged: (status) => provider.setStatusFilter(status),
                onPriorityChanged: (priority) =>
                    provider.setPriorityFilter(priority),
              ),
              
              const Divider(height: 1),
              
              // Contenido principal
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(NotificationProvider provider) {
    // Estado 1: Loading inicial
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const LoadingIndicator();
    }

    // Estado 2: Error inicial
    if (provider.error != null && provider.notifications.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => provider.loadNotifications(refresh: true),
      );
    }

    // Estado 3: Lista vacía
    if (provider.notifications.isEmpty) {
      return const EmptyState(
        message: 'No hay notificaciones',
        icon: Icons.notifications_none,
      );
    }

    // Estado 4: Lista con resultados (+ estado 5 y 6: cargando más / error al cargar más)
    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(refresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.notifications.length + 1, // +1 para footer
        itemBuilder: (context, index) {
          // Items de notificaciones
          if (index < provider.notifications.length) {
            final notification = provider.notifications[index];
            return NotificationCard(
              notification: notification,
              onTap: () => context.push('/notification/${notification.id}'),
            );
          }

          // Footer: loading more / error / nada
          return _buildFooter(provider);
        },
      ),
    );
  }

  Widget _buildFooter(NotificationProvider provider) {
    // Estado 5: Cargando nueva página
    if (provider.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Estado 6: Error al cargar más
    if (provider.loadMoreError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              provider.loadMoreError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => provider.loadMore(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Sin más resultados
    if (!provider.hasMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          'No hay más notificaciones',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
