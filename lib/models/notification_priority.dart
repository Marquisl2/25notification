import 'package:json_annotation/json_annotation.dart';

/// Prioridad de la notificación (valores del Swagger)
@JsonEnum()
enum NotificationPriority {
  @JsonValue('low')
  low,
  
  @JsonValue('normal')
  normal,
  
  @JsonValue('high')
  high;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Baja';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'Alta';
    }
  }
}
