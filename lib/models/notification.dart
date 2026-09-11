import 'package:json_annotation/json_annotation.dart';
import 'notification_priority.dart';
import 'notification_status.dart';

part 'notification.g.dart';

/// Modelo de notificación (NotificationDto del Swagger)
@JsonSerializable(explicitToJson: true)
class Notification {
  final String id;
  final String groupId;
  final String title;
  final String body;
  final String recipientId;
  final NotificationPriority priority;
  final NotificationStatus status;
  
  /// ISO 8601 o null si es inmediata
  final DateTime? scheduledAt;
  
  /// ISO 8601 o null si no fue leída
  final DateTime? readAt;
  
  /// JSON arbitrario con datos adicionales (ej: deepLink, orderId).
  /// Única excepción legítima al "nada de Map suelto": el Swagger
  /// lo define como additionalProperties: true.
  final Map<String, dynamic>? data;
  
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.groupId,
    required this.title,
    required this.body,
    required this.recipientId,
    required this.priority,
    required this.status,
    this.scheduledAt,
    this.readAt,
    this.data,
    required this.createdAt,
  });

  bool get isUnread => status == NotificationStatus.unread;
  bool get isRead => status == NotificationStatus.read;
  bool get isScheduled => status == NotificationStatus.scheduled;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
