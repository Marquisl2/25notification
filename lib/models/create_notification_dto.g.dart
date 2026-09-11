// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateNotificationDto _$CreateNotificationDtoFromJson(
  Map<String, dynamic> json,
) => CreateNotificationDto(
  title: json['title'] as String,
  body: json['body'] as String,
  recipientIds: (json['recipientIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  priority:
      $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']) ??
      NotificationPriority.normal,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CreateNotificationDtoToJson(
  CreateNotificationDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'recipientIds': instance.recipientIds,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'scheduledAt': ?instance.scheduledAt?.toIso8601String(),
  'data': ?instance.data,
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
};
