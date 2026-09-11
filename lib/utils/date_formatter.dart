import 'package:intl/intl.dart';

/// Utilidades para formatear fechas
class DateFormatter {
  /// Formato: "11 sep 2026, 12:30" (convierte UTC a local)
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM y, HH:mm', 'es').format(date.toLocal());
  }

  /// Formato: "11 sep 2026" (convierte UTC a local)
  static String formatDate(DateTime date) {
    return DateFormat('d MMM y', 'es').format(date.toLocal());
  }

  /// Formato: "12:30" (convierte UTC a local)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'es').format(date.toLocal());
  }

  /// Formato relativo: "Hace 5 minutos", "Hace 2 horas", "Ayer", etc.
  static String formatRelative(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDate);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return formatDate(localDate);
    }
  }
}
