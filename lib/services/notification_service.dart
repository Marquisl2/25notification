import 'package:dio/dio.dart';
import '../models/notification.dart' as models;
import '../models/notification_list_dto.dart';
import '../models/create_notification_dto.dart';
import '../models/notification_status.dart';
import '../models/notification_priority.dart';
import 'api_client.dart';
import 'api_exceptions.dart';

/// Servicio para interactuar con la API de notificaciones
class NotificationService {
  final Dio _dio = ApiClient().dio;

  /// GET /notifications con filtros opcionales.
  /// Nota: includeScheduled=false por defecto (sin UI según enunciado).
  Future<NotificationListDto> getNotifications({
    String? recipientId,
    NotificationStatus? status,
    NotificationPriority? priority,
    bool includeScheduled = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Construir query params (omitir los null)
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'includeScheduled': includeScheduled,
      };

      if (recipientId != null) {
        queryParams['recipientId'] = recipientId;
      }

      if (status != null) {
        queryParams['status'] = status.name; // 'unread', 'read', 'scheduled'
      }

      if (priority != null) {
        queryParams['priority'] = priority.name; // 'low', 'normal', 'high'
      }

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      return NotificationListDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException('Error al cargar notificaciones');
    }
  }

  /// POST /notifications
  /// 
  /// Fan-out: devuelve un array de notificaciones creadas (una por recipientId)
  Future<List<models.Notification>> createNotification(
    CreateNotificationDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/notifications',
        data: dto.toJson(),
      );

      // La API devuelve un array de NotificationDto
      final List<dynamic> dataList = response.data as List;
      return dataList
          .map((json) => models.Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      if (e.error is NetworkException) {
        rethrow;
      }
      throw NetworkException('Error al crear notificación');
    }
  }
}
