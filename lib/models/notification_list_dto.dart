import 'package:json_annotation/json_annotation.dart';
import 'notification.dart';
import 'pagination_meta.dart';

part 'notification_list_dto.g.dart';

/// Respuesta del GET /notifications
@JsonSerializable(explicitToJson: true)
class NotificationListDto {
  final List<Notification> data;
  final PaginationMeta meta;

  const NotificationListDto({
    required this.data,
    required this.meta,
  });

  factory NotificationListDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListDtoToJson(this);
}
