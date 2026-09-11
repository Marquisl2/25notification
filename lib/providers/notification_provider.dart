import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../models/pagination_meta.dart';
import '../models/create_notification_dto.dart';
import '../models/notification_status.dart';
import '../models/notification_priority.dart';
import '../services/notification_service.dart';
import '../services/api_exceptions.dart';

/// Provider para gestionar el estado de las notificaciones
class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  // Estado
  List<Notification> _notifications = [];
  PaginationMeta? _meta;
  final Set<String> _knownRecipientIds = {}; // Acumulativo, NO se vacía al filtrar
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  String? _error;
  String? _loadMoreError;

  // Filtros
  String? _recipientId; // null = "Todos" (default)
  NotificationStatus? _statusFilter;
  NotificationPriority? _priorityFilter;

  // Getters
  List<Notification> get notifications => _notifications;
  PaginationMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get loadMoreError => _loadMoreError;
  String? get recipientId => _recipientId;
  NotificationStatus? get statusFilter => _statusFilter;
  NotificationPriority? get priorityFilter => _priorityFilter;

  /// RecipientIds únicos descubiertos a lo largo de todas las cargas.
  /// Se acumulan y NO se vacían al cambiar filtros.
  /// La API no tiene endpoint de usuarios, así que extraemos los IDs
  /// de las notificaciones cargadas.
  List<String> get knownRecipientIds {
    final ids = _knownRecipientIds.toList();
    ids.sort();
    return ids;
  }

  bool get hasMore => _meta?.hasMore ?? false;
  
  /// UnreadCount de la bandeja/filtro actual (contextual)
  /// Si filtramos por "read" (leídas), el badge debe ser 0
  int get unreadCount {
    // Si filtramos explícitamente por "leídas", no hay no leídas
    if (_statusFilter == NotificationStatus.read) {
      return 0;
    }
    
    // Si filtramos por "scheduled", contar las scheduled
    if (_statusFilter == NotificationStatus.scheduled) {
      return _notifications.where((n) => n.status == NotificationStatus.scheduled).length;
    }
    
    // En cualquier otro caso (todas, no leídas, filtro por prioridad, etc.),
    // usar el unreadCount del meta de la API
    return _meta?.unreadCount ?? 0;
  }

  /// Cargar notificaciones con los filtros actuales
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications = [];
      _meta = null;
      _error = null;
      _loadMoreError = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getNotifications(
        recipientId: _recipientId,
        status: _statusFilter,
        priority: _priorityFilter,
        includeScheduled: false, // Dimensión aparte, sin UI
        limit: 20,
        offset: 0,
      );

      _notifications = result.data;
      _meta = result.meta;
      
      // Acumular recipientIds descubiertos (no se vacía al filtrar)
      for (final notification in result.data) {
        _knownRecipientIds.add(notification.recipientId);
      }
      
      _error = null;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _notifications = [];
      _meta = null;
    } on NetworkException catch (e) {
      _error = e.message;
      _notifications = [];
      _meta = null;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _notifications = [];
      _meta = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar más notificaciones (paginación)
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final currentOffset = _meta?.offset ?? 0;
      final currentLimit = _meta?.limit ?? 20;
      final newOffset = currentOffset + currentLimit;

      final result = await _service.getNotifications(
        recipientId: _recipientId,
        status: _statusFilter,
        priority: _priorityFilter,
        includeScheduled: false,
        limit: 20,
        offset: newOffset,
      );

      _notifications.addAll(result.data);
      _meta = result.meta;
      
      // Acumular recipientIds descubiertos
      for (final notification in result.data) {
        _knownRecipientIds.add(notification.recipientId);
      }
      
      _loadMoreError = null;
    } on ApiException catch (e) {
      _loadMoreError = e.userMessage;
    } on NetworkException catch (e) {
      _loadMoreError = e.message;
    } catch (e) {
      _loadMoreError = 'Error al cargar más: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Cambiar bandeja (recipientId)
  void setRecipientId(String? id) {
    if (_recipientId == id) return;
    _recipientId = id;
    loadNotifications(refresh: true);
  }

  /// Cambiar filtro de estado (nunca setea 'scheduled'; solo null/unread/read)
  void setStatusFilter(NotificationStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    loadNotifications(refresh: true);
  }

  /// Cambiar filtro de prioridad
  void setPriorityFilter(NotificationPriority? priority) {
    if (_priorityFilter == priority) return;
    _priorityFilter = priority;
    loadNotifications(refresh: true);
  }

  /// Crear una nueva notificación
  Future<void> createNotification(CreateNotificationDto dto) async {
    try {
      final createdNotifications = await _service.createNotification(dto);
      
      // Acumular recipientIds de las notificaciones creadas
      for (final notification in createdNotifications) {
        _knownRecipientIds.add(notification.recipientId);
      }
      
      // Recargar para reflejar la nueva notificación y actualizar el badge contextual
      // (El badge se actualiza automáticamente con el nuevo meta.unreadCount)
      await loadNotifications(refresh: true);
    } catch (e) {
      rethrow; // La UI maneja el error
    }
  }

  /// Buscar una notificación por ID en la lista cargada
  Notification? findById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
