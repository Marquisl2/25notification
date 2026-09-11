import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta.g.dart';

/// Metadata de paginación (PaginationMetaDto del Swagger)
@JsonSerializable()
class PaginationMeta {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  
  /// Cantidad de notificaciones visibles y sin leer.
  /// Sirve para el badge.
  final int unreadCount;

  const PaginationMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.unreadCount,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
