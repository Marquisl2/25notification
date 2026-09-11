import 'package:json_annotation/json_annotation.dart';

/// Estado de la notificación (valores del Swagger).
/// scheduled: programada a futuro
/// unread: visible y sin leer
/// read: leída
@JsonEnum()
enum NotificationStatus {
  @JsonValue('scheduled')
  scheduled,
  
  @JsonValue('unread')
  unread,
  
  @JsonValue('read')
  read;

  String get displayName {
    switch (this) {
      case NotificationStatus.scheduled:
        return 'Programada';
      case NotificationStatus.unread:
        return 'No leída';
      case NotificationStatus.read:
        return 'Leída';
    }
  }
}
