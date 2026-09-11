/// Excepción de la API con código de estado y mensaje
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException(this.statusCode, this.message, [this.data]);

  /// Factory para parsear errores 400/401 de la API
  factory ApiException.fromResponse(int statusCode, dynamic responseData) {
    if (statusCode == 400) {
      if (responseData is Map && responseData['message'] != null) {
        final message = responseData['message'];
        if (message is List) {
          final messages = message.map((e) => e.toString()).join('\n• ');
          return ApiException(400, 'Errores de validación:\n• $messages', responseData);
        } else if (message is String) {
          return ApiException(400, message, responseData);
        }
      }
      return ApiException(400, 'Request inválido', responseData);
    }
    
    if (statusCode == 401) {
      final serverMessage = responseData is Map && responseData['message'] is String
          ? responseData['message'] as String
          : 'Token ausente o inválido';
      return ApiException(
        401,
        '$serverMessage. Revisá la configuración en .env',
        responseData,
      );
    }

    // Otros códigos
    final message = responseData is Map && responseData['message'] != null
        ? responseData['message'].toString()
        : 'Error HTTP $statusCode';
    
    return ApiException(statusCode, message, responseData);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
  
  /// Mensaje legible para mostrar al usuario
  String get userMessage {
    if (statusCode == 401) {
      return 'Error de autenticación. Verificá el token en .env';
    }
    if (statusCode == 400) {
      return message;
    }
    if (statusCode >= 500) {
      return 'El servidor no está disponible. Intentá más tarde.';
    }
    return message;
  }
}

/// Excepción de red (timeout, sin conexión, etc)
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Error de conexión. Verificá tu red.']);

  @override
  String toString() => 'NetworkException: $message';
}
