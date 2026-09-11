import 'package:json_annotation/json_annotation.dart';
import 'notification_priority.dart';

part 'create_notification_dto.g.dart';

/// DTO para crear notificaciones (POST /notifications).
/// Contenedor tipado puro, sin validación (los assert se desactivan en release).
/// Las validaciones (maxLength: 120/500 del Swagger, campos requeridos) viven
/// en los TextFormField validators de la UI.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CreateNotificationDto {
  final String title;
  final String body;
  
  /// Fan-out: la API crea una notificación por cada recipientId,
  /// todas con el mismo groupId.
  final List<String> recipientIds;
  
  @JsonKey(defaultValue: NotificationPriority.normal)
  final NotificationPriority priority;
  
  /// ISO 8601. Si se omite, la notificación queda visible (unread) de inmediato.
  final DateTime? scheduledAt;
  
  /// JSON arbitrario (deepLink, orderId, etc).
  /// Map<String, dynamic> es la única excepción legítima: el Swagger
  /// lo define como additionalProperties: true.
  final Map<String, dynamic>? data;

  const CreateNotificationDto({
    required this.title,
    required this.body,
    required this.recipientIds,
    this.priority = NotificationPriority.normal,
    this.scheduledAt,
    this.data,
  });

  factory CreateNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateNotificationDtoToJson(this);
}
