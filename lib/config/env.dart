import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Wrapper para acceder a variables de entorno desde .env
class Env {
  static String get apiToken => dotenv.env['API_BEARER_TOKEN'] ?? '';
  
  static bool get hasToken => apiToken.isNotEmpty;
}
