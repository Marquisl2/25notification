// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationListDto _$NotificationListDtoFromJson(Map<String, dynamic> json) =>
    NotificationListDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationListDtoToJson(
  NotificationListDto instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
