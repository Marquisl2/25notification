// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  recipientId: json['recipientId'] as String,
  priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
  status: $enumDecode(_$NotificationStatusEnumMap, json['status']),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  data: json['data'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'title': instance.title,
      'body': instance.body,
      'recipientId': instance.recipientId,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'status': _$NotificationStatusEnumMap[instance.status]!,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.scheduled: 'scheduled',
  NotificationStatus.unread: 'unread',
  NotificationStatus.read: 'read',
};
